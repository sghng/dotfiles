"""picker-curated — keep the model picker on Hermes's own catalogs behind a gateway.

PROBLEM THIS SOLVES (one problem, nothing else): Hermes's model picker builds a
provider's menu from the *runtime* endpoint of that provider. When a profile
points its vendor base URLs at an LLM gateway (e.g. KIMI_BASE_URL /
DEEPSEEK_BASE_URL -> https://llm.sgh.ng/v1), the picker probes the GATEWAY's
aggregated /v1/models and adopts every lane's models as that provider's catalog:
the DeepSeek menu lists chatgpt/*, kimi/*, openrouter/* ... (verified
2026-10-23: 746 entries under every provider, 218 of them gpt-*).

Hermes has a `discover_models: false` knob, but on the native picker path
(`hermes_cli/models.py::_profile_live_catalog` -> `probe_profile_catalog`) it is
ignored — that path only asks the profile's `fetch_models()`. The supported,
provider-agnostic way to say "do not ask this endpoint for a catalog" is for the
provider profile to return None, which makes the picker machinery fall back to
Hermes's static `_PROVIDER_MODELS` catalog (maintained upstream, per provider).

SCOPE — deliberately tiny. This plugin overrides EXACTLY ONE method:

    fetch_models() -> None      # no live catalogue for the picker

It does NOT touch base_url, headers, model names, context lengths, aux models,
capabilities or anything on the wire. Routing still goes through the gateway
because the profile .env base URLs say so; context resolution still comes from
the endpoint metadata probe. If a future Hermes makes `discover_models: false`
authoritative on the native picker path (or probes the vendor catalogue while
the runtime uses the relay), DELETE this plugin — it has no other job.

Tradeoff, stated plainly: the picker then shows Hermes's curated list, which
lags new upstream releases. That is the same freshness tradeoff the picker had
before the base URLs were relayed, and new models still work on the wire via
`/model <id>` — only the menu row can lag.
"""

from __future__ import annotations

import dataclasses
import logging

from providers import get_provider_profile, register_provider

logger = logging.getLogger(__name__)

# Bundled providers whose base URL this deployment relays through the gateway.
# Add a name here only when its profile env base URL points at the gateway;
# a direct provider should keep its live, vendor-accurate catalogue.
UNDISCOVERED = ("kimi-coding", "opencode-go", "deepseek", "minimax-cn")


def _curate(name: str) -> None:
    profile = get_provider_profile(name)
    if profile is None:  # provider not registered in this build — nothing to do
        logger.debug("picker-curated: %s not registered, skipped", name)
        return

    base_cls = type(profile)

    class _CuratedPicker(base_cls):
        def fetch_models(self, **kwargs):  # noqa: ARG002
            # None => "this endpoint has no catalogue for me"; Hermes then uses
            # its static per-provider catalog. Never an empty list: that would
            # render an empty menu instead of the curated one.
            return None

    fields = {f.name: getattr(profile, f.name) for f in dataclasses.fields(profile)}
    register_provider(_CuratedPicker(**fields))
    logger.info("picker-curated: %s keeps the static picker catalog", name)


for _name in UNDISCOVERED:
    _curate(_name)
