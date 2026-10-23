"""bifrost-relay — gateway transport for native providers.

CONTRACT: every provider in Hermes stays 100% native. No base_url override, no
env vars, no config keys, no picker/catalog/metadata patching. The model
picker, live discovery, model metadata and the endpoint-scoped context table
all read the NATIVE provider base_url and therefore behave exactly like stock
Hermes — including the Kimi Code endpoint's live catalog (k3, k3-256k, ...) and
the api.kimi.com/coding context table (k3 -> 1,048,576).

Transport — and only transport — is interposed at the one seam upstream built
for this: ``ProviderProfile.create_client()`` ("a profile registered from
``~/.hermes/plugins/model-providers/`` can supply its own transport without any
core edit" — providers/base.py). The runtime consults it BEFORE the standard
client construction in both paths:

  - primary: agent/agent_runtime_helpers.create_openai_client
      -> _provider_supplied_client(agent, client_kwargs)   (full kwarg mapping)
  - auxiliary: agent/auxiliary_client._api_key_profile_supplied_client
      -> profile.create_client(api_key=..., base_url=...)  (exactly two keys)

This plugin subclasses the bundled profiles of the relayed providers and
returns the SAME client the core would build (same kwargs verbatim, same lazy
``process_bootstrap.OpenAI`` proxy for the primary path, ``AsyncOpenAI`` for
the two-key auxiliary call, same ``max_retries: 0`` convention) with exactly
one field changed: base_url -> the gateway.

Consequences, all deliberate:
  - The vendor API key travels in the Authorization header to the gateway;
    Bifrost authenticates with its own configured provider keys, so this is
    inert (llm.sgh.ng is ours).
  - Wire model names stay vendor-native; Bifrost resolves the lane from the
    request body's model field (native auto-resolution + explicit routing
    rules as the procurement ledger).
  - ``agent.base_url`` stays native, so every host-keyed heuristic (endpoint
    context table, provider-specific decoration, openrouter/copilot checks)
    behaves as if there were no gateway.
  - Failure isolation mirrors upstream: if this plugin fails to build a
    client, the core logs and falls back to the standard (native) path —
    traffic goes direct, never down.

The relay URL is overridable per-profile via BIFROST_RELAY_URL (default
https://llm.sgh.ng/v1). Delete this plugin to go back to fully direct traffic;
nothing else references it.
"""

from __future__ import annotations

import dataclasses
import logging
import os

from providers import get_provider_profile, register_provider

logger = logging.getLogger(__name__)

RELAY_BASE_URL = os.environ.get("BIFROST_RELAY_URL", "https://llm.sgh.ng/v1")

# Providers whose traffic relays through the gateway. A provider NOT listed
# here keeps fully native transport (direct to vendor).
RELAYED = ("kimi-coding", "opencode-go", "deepseek", "minimax-cn")

# The auxiliary seam calls create_client(api_key=..., base_url=...) and expects
# an AsyncOpenAI; the primary seam passes the full constructor mapping and
# expects the sync client the core would have built. The kwarg set is the only
# reliable signal distinguishing the two callers.
_AUX_SEAM_KEYS = {"api_key", "base_url"}

# ACP-style keys that are not valid for the OpenAI SDK constructor
# (providers/base.py documents command/args in client_kwargs).
_NON_SDK_KEYS = {"command", "args"}


def _relay(name: str) -> None:
    profile = get_provider_profile(name)
    if profile is None:  # provider not registered in this build
        logger.debug("bifrost-relay: %s not registered, skipped", name)
        return

    base_cls = type(profile)

    class _RelayedClient(base_cls):
        def create_client(self, **client_kwargs):
            kwargs = {k: v for k, v in client_kwargs.items() if k not in _NON_SDK_KEYS}
            kwargs["base_url"] = RELAY_BASE_URL
            # Mirror the core's single-chokepoint convention: Hermes's outer
            # loop owns retries (honours Retry-After); SDK retries double-fire.
            kwargs.setdefault("max_retries", 0)
            if set(client_kwargs) <= _AUX_SEAM_KEYS:
                from openai import AsyncOpenAI

                return AsyncOpenAI(**kwargs)
            from agent import process_bootstrap

            return process_bootstrap.OpenAI(**kwargs)

    fields = {f.name: getattr(profile, f.name) for f in dataclasses.fields(profile)}
    register_provider(_RelayedClient(**fields))
    logger.info("bifrost-relay: %s transport -> %s (provider stays native)", name, RELAY_BASE_URL)


for _name in RELAYED:
    _relay(_name)
