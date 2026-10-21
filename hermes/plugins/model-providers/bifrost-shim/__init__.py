"""Bifrost shim — repoint bundled provider profiles at llm.sgh.ng.

CONTRACT (the whole point): to Hermes, a shimmed provider must be
indistinguishable from the native bundled provider. Transport is
intercepted and routed through the gateway; EVERYTHING ELSE stays
exactly the same — context window, capabilities, model picker,
thinking/effort wire quirks, headers. If a shim mutation ever changes
any of those, the shim is broken, and the fix belongs in the shim (or
upstream), never in per-model config metadata that users must hand-maintain.

Each shimmed profile keeps its bundled class (subclass, never replace)
and changes exactly three transport things:

  1. base_url  -> https://llm.sgh.ng/v1  (Bifrost front door; keyless)
  2. default_headers += x-bf-dim-app: hermes-<profile>   (usage attribution)
  3. wire model gets the Bifrost provider prefix (provider/model) via the
     build_api_kwargs_extras top-level merge, verified in both the main
     transport (agent/transports/chat_completions.py) and the aux client.

KNOWN VIOLATION, COMPENSATED (2026-10-21): Hermes's context-window
detection (`_endpoint_scoped_context_length` in agent/model_metadata.py)
keys metadata off the exact upstream HOST+PATH (api.kimi.com/coding), so
rewriting base_url to llm.sgh.ng silently downgraded k3 from 1,048,576 to
the 256,000 hard fallback. The shim now implements the profile hook
`get_model_context_length` and re-asks Hermes's own endpoint-scoped table
with the ORIGINAL bundled base_url — no hardcoded numbers, the table stays
the single source of truth. Anything the table doesn't know returns None
and the normal chain proceeds unchanged. The general bug (host-keyed
metadata breaks under any relay) is upstream: draft at
profiles/dev/drafts/upstream-issues/2026-10-21-endpoint-scoped-context-relay-host.md.

Model listings are deliberately NOT handled here. fetch_models returns None,
which makes Hermes's picker machinery fall back to its own static
_PROVIDER_MODELS catalog (maintained upstream, per provider). The gateway's
aggregated /v1/models (every lane, provider-prefixed) is never consulted
for picker content — no filtering, no hardcoded lists, no network
dependency in the shim.

Bundled model-provider plugins load before user plugins (source order in
hermes_cli/plugins.py: bundled < user < project < entry-point), so the
bundled profiles are always resolvable from the providers registry at shim
load time — no direct file imports.

KIMI_BASE_URL and OPENCODE_GO_BASE_URL (profile .env) must both point at
Bifrost: Hermes's HermesOverlay applies the env base_url after the profile,
and the delegation/subagent path resolves base_url from the provider's
env var / models.dev entry, NOT from this shim's base_url field — without
the env vars, delegation traffic exits direct to the upstream
(verified 2026-10-20: opencode-go delegation went to opencode.ai despite
this shim being registered). The shim's prefix/header mutations apply on
the main-model path; the delegation path additionally needs
delegation.model set to the canonical provider/model form.
"""

from __future__ import annotations

import dataclasses
import logging

from providers import get_provider_profile, register_provider

logger = logging.getLogger(__name__)

BIFROST_BASE = "https://llm.sgh.ng/v1"


def _dim_app() -> str:
    try:
        from hermes_cli.config import get_hermes_home

        name = get_hermes_home().name
        return "hermes-default" if name in (".hermes", "") else f"hermes-{name}"
    except Exception:
        return "hermes"


def _shim(name: str, *, prefix: str, aux: str | None = None, metadata_base: str | None = None):
    """Register a shim subclass of the bundled profile `name`.

    `metadata_base` is the UPSTREAM endpoint identity the shim fronts
    (e.g. the Kimi Code endpoint), used ONLY to answer host-keyed
    metadata lookups. It is provider identity, not model metadata: the
    bundled profile's base_url default (api.moonshot.ai/v1) is NOT the
    coding endpoint, and the coding endpoint URL lived in KIMI_BASE_URL,
    which we repoint at Bifrost — so the true upstream host would
    otherwise be unrecoverable at runtime.
    """
    profile = get_provider_profile(name)
    if profile is None:
        raise RuntimeError(f"bifrost-shim: bundled profile {name!r} not registered")

    base_cls = type(profile)
    orig_base_url = metadata_base or profile.base_url  # endpoint metadata stays keyed to THIS

    class _Shim(base_cls):
        _bifrost_prefix = prefix
        _bifrost_orig_base_url = orig_base_url

        def build_api_kwargs_extras(self, *, model=None, **ctx):
            body, top = super().build_api_kwargs_extras(model=model, **ctx)
            if isinstance(model, str) and model and "/" not in model:
                top = {**(top or {}), "model": f"{self._bifrost_prefix}/{model}"}
            return body, top

        def get_model_context_length(self, model: str) -> int | None:
            # Contract: metadata identical to the native provider. Hermes keys
            # endpoint-scoped context off the upstream host, which our relayed
            # base_url no longer matches — re-ask the same table with the
            # ORIGINAL base_url. Returns None for anything the table doesn't
            # know, so the normal resolution chain proceeds untouched.
            try:
                from agent.model_metadata import _endpoint_scoped_context_length

                return _endpoint_scoped_context_length(model, self._bifrost_orig_base_url)
            except Exception:  # private API moved / import context differs
                return None

        def fetch_models(self, **kwargs):  # noqa: ARG002
            # Catalogs are Hermes's job: returning None makes the picker fall
            # back to the static _PROVIDER_MODELS catalog for this provider.
            return None

    fields = {f.name: getattr(profile, f.name) for f in dataclasses.fields(profile)}
    fields["base_url"] = BIFROST_BASE
    headers = dict(fields.get("default_headers") or {})
    headers["x-bf-dim-app"] = _dim_app()
    fields["default_headers"] = headers
    if aux:
        fields["default_aux_model"] = aux
    register_provider(_Shim(**fields))
    logger.info("bifrost-shim: %s -> %s (prefix %s/)", name, BIFROST_BASE, prefix)


_shim("kimi-coding", prefix="kimi", aux="kimi-for-coding-highspeed",
      metadata_base="https://api.kimi.com/coding")
_shim("opencode-go", prefix="opencode-go")
