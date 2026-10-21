"""Bifrost provider — the gateway as a first-class Hermes provider.

One provider named `bifrost` fronts the gateway (llm.sgh.ng). The registry
below is the contract: model ids ARE canonical Bifrost `provider/model`
identifiers, so Hermes sends them verbatim — no wire mutation, no bare-name
auto-resolution, no drift risk. The picker shows exactly this list
(fetch_models returns it; the gateway's aggregated /v1/models is never
consulted for picker content).

Maintaining the registry is deliberate (user decision 2026-10-21): when a
new lane/model joins the roster, add a row. `context` is the upstream's
published window (Kimi Code live roster, 2026-10-21; DeepSeek V4.1 Flash
spec); set None to defer to Hermes's normal resolution chain.

Validated 2026-10-21 (spike 001, scratch/spikes/001-bifrost-provider):
k3 through a generic OpenAI-compatible profile is wire-compatible with the
native KimiProfile — all effort levels accepted (incl. undocumented
"medium" and "none"), thinking/effort conflicts tolerated, streaming
encoding-agnostic through the gateway, temperature omitted by both. Only
caveat: kimi-for-coding* (K2.x) drops replayed reasoning without
thinking.keep:"all" — applied below in build_api_kwargs_extras.
"""

from __future__ import annotations

from typing import Any

from providers import get_provider_profile, register_provider

GATEWAY_BASE_URL = "https://llm.sgh.ng/v1"

# Canonical Bifrost ids -> upstream context window (None = defer to Hermes).
REGISTRY: dict[str, int | None] = {
    "kimi/k3": 1_048_576,
    "kimi/k3-256k": 262_144,
    "kimi/kimi-for-coding": 1_048_576,
    "kimi/kimi-for-coding-highspeed": 262_144,
    "opencode-go/deepseek-v4.1-flash": 1_048_576,
    "opencode-go/minimax-m3.1-flash-free": None,
}


def _build() -> None:
    custom = get_provider_profile("custom")
    if custom is None:
        raise RuntimeError("bifrost-provider: bundled profile 'custom' not registered")
    base_cls = type(custom)

    class BifrostProfile(base_cls):
        def fetch_models(self, **_kwargs: Any) -> list[str]:
            # The registry IS the picker list.
            return list(REGISTRY)

        def get_model_context_length(self, model: str) -> int | None:
            return REGISTRY.get(model)  # unknown -> None -> normal chain

        def default_reasoning_config(self, model: str | None = None) -> dict | None:
            # kimi/* defers to the server default exactly like the native
            # KimiProfile (no forced effort); everything else keeps the
            # custom profile's medium default.
            if (model or "").startswith("kimi/"):
                return None
            return super().default_reasoning_config(model)

        def build_api_kwargs_extras(self, *, model: str | None = None, **ctx: Any):
            # kimi/* delegates to the registered kimi-coding profile (bundled or
            # shimmed) so Kimi's wire rules — thinking XOR effort, vocab clamping —
            # stay byte-identical to native. We pass the residual model name; a
            # shimmed profile re-adding the "kimi/" prefix is harmless (it equals
            # our registry id). Non-kimi models keep the generic custom behavior.
            if model and model.startswith("kimi/"):
                kimi = get_provider_profile("kimi-coding")
                if kimi is not None:
                    return kimi.build_api_kwargs_extras(model=model[len("kimi/"):], **ctx)
            return super().build_api_kwargs_extras(model=model, **ctx)

    fields = {f.name: getattr(custom, f.name) for f in custom.__dataclass_fields__.values()}
    fields.update(
        name="bifrost",
        aliases=(),
        env_vars=(),
        base_url=GATEWAY_BASE_URL,
        default_aux_model="kimi/kimi-for-coding-highspeed",
    )
    register_provider(BifrostProfile(**fields))


_build()
