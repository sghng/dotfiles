"""Bifrost shim — repoint bundled provider profiles at llm.sgh.ng.

The shim is a pure transport interceptor. Doctrine: the harness owns
transport + attribution; Bifrost owns routing; Hermes owns model catalogs.
Each shimmed profile keeps its bundled class (thinking/effort wire quirks,
headers — subclass, never replace) and changes exactly three things:

  1. base_url  -> https://llm.sgh.ng/v1  (Bifrost front door; keyless)
  2. default_headers += x-bf-dim-app: hermes-<profile>   (usage attribution)
  3. wire model gets the Bifrost provider prefix (provider/model) via the
     build_api_kwargs_extras top-level merge, verified in both the main
     transport (agent/transports/chat_completions.py) and the aux client.

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

KIMI_BASE_URL (profile .env) must also point at Bifrost: Hermes's
HermesOverlay applies the env base_url after the profile, and an explicit
env value always wins over the profile default. opencode-go has no active
base-url env override, so the profile value stands.
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


def _shim(name: str, *, prefix: str, aux: str | None = None):
    """Register a shim subclass of the bundled profile `name`."""
    profile = get_provider_profile(name)
    if profile is None:
        raise RuntimeError(f"bifrost-shim: bundled profile {name!r} not registered")

    base_cls = type(profile)

    class _Shim(base_cls):
        _bifrost_prefix = prefix

        def build_api_kwargs_extras(self, *, model=None, **ctx):
            body, top = super().build_api_kwargs_extras(model=model, **ctx)
            if isinstance(model, str) and model and "/" not in model:
                top = {**(top or {}), "model": f"{self._bifrost_prefix}/{model}"}
            return body, top

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


_shim("kimi-coding", prefix="kimi", aux="kimi-for-coding-highspeed")
_shim("opencode-go", prefix="opencode-go")
