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

The picker is kept clean by fetch_models returning a curated list instead of
the gateway's aggregated /v1/models (150+ entries from every lane).

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


def _wrap(profile, *, prefix: str, models: list[str], aux: str | None = None):
    """Return a shim subclass instance of a bundled provider profile."""
    base_cls = type(profile)

    class _Shim(base_cls):
        _bifrost_prefix = prefix

        def build_api_kwargs_extras(self, *, model=None, **ctx):
            body, top = super().build_api_kwargs_extras(model=model, **ctx)
            if isinstance(model, str) and model and "/" not in model:
                top = {**(top or {}), "model": f"{self._bifrost_prefix}/{model}"}
            return body, top

        def fetch_models(self, **kwargs):  # noqa: ARG002 - curated picker list
            return list(models)

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
        import importlib.util

        from hermes_cli.plugins import get_bundled_plugins_dir

        init = get_bundled_plugins_dir() / "model-providers" / "kimi-coding" / "__init__.py"
        spec = importlib.util.spec_from_file_location(
            "plugins.model_providers.kimi_coding_shimfb",
            init,
            submodule_search_locations=[str(init.parent)],
        )
        if spec is None or spec.loader is None:
            raise ImportError(f"cannot load bundled kimi-coding plugin from {init}")
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        return mod.kimi


_DIM = _dim_app()
_kimi = _load_bundled_kimi()
register_provider(
    _wrap(
        _kimi,
        prefix="kimi",
        models=["kimi-for-coding", "kimi-for-coding-highspeed"],
        aux="kimi-for-coding-highspeed",
    )
)
logger.info("bifrost-shim: kimi-coding -> %s (dim-app: %s)", BIFROST_BASE, _DIM)
