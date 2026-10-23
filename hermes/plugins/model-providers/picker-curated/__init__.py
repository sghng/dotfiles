"""picker-curated — lane-scoped live catalogs behind a relay.

CONTRACT: to Hermes, a relayed provider must behave like the native one.
Transport is already interposed at the profile's base_url (env override ->
the gateway); this plugin fixes the ONE thing that breaks under a relay:
model listing.

PROBLEM: the picker asks the provider's runtime endpoint for its catalog. When
that endpoint is a gateway, the answer is every lane's models (verified
2026-10-23: 746 entries under DeepSeek, 218 of them `gpt-*`). Returning None
(the static catalog) fixes the pollution but loses live ids such as the Kimi
Code endpoint's `k3-256k`, which the bundled curated list predates.

FIX: keep the live fetch, then scope it to this provider's lane. The gateway
publishes lane-namespaced ids (`kimi/k3`, `opencode-go/deepseek-v4.1-flash`),
so filtering on the prefix and stripping it yields exactly the vendor's own
list — live, unprefixed, unpolluted — which is what the picker and
`/model <id>` expect. On any failure the method returns None, so Hermes falls
back to its static catalog and the menu is never empty.

Deliberately NOT handled here: base_url, headers, wire model names, context
lengths, aux models, capabilities. Context resolution keeps using the endpoint
metadata probe; routing keeps using the env base URL. Delete this plugin when
Hermes scopes native provider discovery through a relay upstream (or honours
`discover_models: false` on the native picker path).
"""

from __future__ import annotations

import dataclasses
import logging

import httpx

from providers import get_provider_profile, register_provider

logger = logging.getLogger(__name__)

# Bundled provider -> the gateway lane that serves it. Only providers whose base
# URL is relayed belong here; a direct provider keeps its own live catalog.
LANE = {
    "kimi-coding": "kimi",
    "opencode-go": "opencode-go",
    "deepseek": "deepseek",
    "minimax-cn": "minimax",
}


def _curate(name: str, lane: str) -> None:
    profile = get_provider_profile(name)
    if profile is None:  # not registered in this build
        logger.debug("picker-curated: %s not registered, skipped", name)
        return

    base_cls = type(profile)

    class _LaneScopedCatalog(base_cls):
        def fetch_models(self, *, api_key: str | None = None, base_url: str | None = None,
                         timeout: float = 8.0, **kwargs):  # noqa: ARG002
            url = (base_url or getattr(self, "base_url", "") or "").rstrip("/")
            if not url:
                return None
            try:
                resp = httpx.get(
                    url + "/models",
                    headers={"Authorization": f"Bearer {api_key}"} if api_key else {},
                    timeout=timeout,
                    follow_redirects=True,
                )
                resp.raise_for_status()
                payload = resp.json()
            except Exception as exc:
                # None (not []) so Hermes falls back to its static catalog.
                logger.debug("picker-curated: %s live fetch failed (%s); using static catalog", name, exc)
                return None
            prefix = lane + "/"
            ids: list[str] = []
            for item in payload.get("data") or []:
                mid = item.get("id") if isinstance(item, dict) else None
                if not isinstance(mid, str):
                    continue
                if mid.startswith(prefix):
                    ids.append(mid[len(prefix):])
                # ids from another lane are deliberately dropped: they are not
                # this provider's models, and offering them here is the bug.
            return ids or None

    fields = {f.name: getattr(profile, f.name) for f in dataclasses.fields(profile)}
    register_provider(_LaneScopedCatalog(**fields))
    logger.info("picker-curated: %s lists lane %r from the relay", name, lane)


for _name, _lane in LANE.items():
    _curate(_name, _lane)
