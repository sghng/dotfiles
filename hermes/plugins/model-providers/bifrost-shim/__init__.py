"""Bifrost shim — repoint bundled provider profiles at llm.sgh.ng.

Doctrine: the harness owns transport + attribution; Bifrost owns routing.
Each shimmed profile keeps the bundled class (thinking/effort wire quirks,
headers, max-tokens all preserved — we subclass, never replace) and changes
only three things:

  1. base_url  -> https://llm.sgh.ng/v1  (Bifrost front door; keyless)
  2. default_headers += x-bf-dim-app: hermes-<profile>   (usage attribution)
  3. wire model gets the Bifrost provider prefix (provider/model) via the
     build_api_kwargs_extras top-level merge, verified in both the main
     transport (agent/transports/chat_completions.py) and the aux client.

The picker is kept clean by fetch_models: it takes Bifrost's aggregated
/v1/models and keeps only this provider's prefix, stripped back to bare
names — no hardcoded model lists.

KIMI_BASE_URL (profile .env) must also point at Bifrost: Hermes's
HermesOverlay applies the env base_url after the profile, and an explicit
env value always wins over the profile default.
"""

from __future__ import annotations

import dataclasses
import logging
import os
from pathlib import Path

from providers import register_provider

logger = logging.getLogger(__name__)

BIFROST_BASE = "https://llm.sgh.ng/v1"


def _dim_app() -> str:
    try:
        from hermes_cli.config import get_hermes_home

        name = get_hermes_home().name
        return "hermes-default" if name in (".hermes", "") else f"hermes-{name}"
    except Exception:
        return "hermes"


def _wrap(profile, *, prefix: str, aux: str | None = None):
    """Return a shim subclass instance of a bundled provider profile."""
    base_cls = type(profile)

    class _Shim(base_cls):
        _bifrost_prefix = prefix

        def build_api_kwargs_extras(self, *, model=None, **ctx):
            body, top = super().build_api_kwargs_extras(model=model, **ctx)
            if isinstance(model, str) and model and "/" not in model:
                top = {**(top or {}), "model": f"{self._bifrost_prefix}/{model}"}
            return body, top

        def fetch_models(self, **kwargs):  # noqa: ARG002
            # Bifrost's /v1/models aggregates every lane with provider/ prefixes;
            # keep only this provider's entries, stripped back to bare names.
            live = super().fetch_models(**kwargs)
            if not live:
                return live
            p = self._bifrost_prefix + "/"
            return [m[len(p):] for m in live if m.startswith(p)]

    fields = {f.name: getattr(profile, f.name) for f in dataclasses.fields(profile)}
    fields["base_url"] = BIFROST_BASE
    headers = dict(fields.get("default_headers") or {})
    headers["x-bf-dim-app"] = _dim_app()
    fields["default_headers"] = headers
    if aux:
        fields["default_aux_model"] = aux
    return _Shim(**fields)


def _load_bundled_kimi():
    """Import the bundled kimi-coding plugin, by module path or by file."""
    try:
        from plugins.model_providers.kimi_coding import kimi as bundled

        return bundled
    except Exception:
        mod = _load_bundled_plugin_module("kimi-coding", "plugins.model_providers.kimi_coding_shimfb")
        return mod.kimi


def _load_bundled_plugin_module(plugin_dir: str, mod_name: str):
    """Load a bundled model-provider plugin by file path (order-independent)."""
    import importlib.util

    from hermes_cli.plugins import get_bundled_plugins_dir

    init = get_bundled_plugins_dir() / "model-providers" / plugin_dir / "__init__.py"
    spec = importlib.util.spec_from_file_location(
        mod_name,
        init,
        submodule_search_locations=[str(init.parent)],
    )
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load bundled plugin from {init}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _load_bundled_opencode_go():
    try:
        from plugins.model_providers.opencode_zen import opencode_go as bundled

        return bundled
    except Exception:
        mod = _load_bundled_plugin_module("opencode-zen", "plugins.model_providers.opencode_zen_shimfb")
        return mod.opencode_go


_DIM = _dim_app()
_kimi = _load_bundled_kimi()
register_provider(
    _wrap(
        _kimi,
        prefix="kimi",
        aux="kimi-for-coding-highspeed",
    )
)
logger.info("bifrost-shim: kimi-coding -> %s (dim-app: %s)", BIFROST_BASE, _DIM)

_opencode_go = _load_bundled_opencode_go()
register_provider(
    _wrap(
        _opencode_go,
        prefix="opencode-go",
    )
)
logger.info("bifrost-shim: opencode-go -> %s (dim-app: %s)", BIFROST_BASE, _DIM)
