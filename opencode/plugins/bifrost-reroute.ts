// bifrost-reroute — send every known-provider request through llm.sgh.ng.
//
// Doctrine: the harness owns transport + attribution; Bifrost owns routing.
// The destination URL's host tells us which provider was intended; we preserve
// that signal by prepending it to the model name (Bifrost's canonical
// `provider/model` form), then rewrite the request to the gateway.
// Unknown hosts pass through untouched — this plugin can never break a
// provider it doesn't know about.

import { Plugin } from "@opencode/plugin"

const BIFROST_HOST = "llm.sgh.ng"

// Destination host (as configured on the native provider) -> Bifrost provider.
// Note: api.minimax.io is deliberately absent (subscription keys get HTTP 401
// there), open.bigmodel.cn is deliberately absent (Zhipu's China realm is a
// different account than Z.AI's, so its key would not serve the zai lane), and
// Anthropic-format traffic is skipped at the path level (below) because the
// gateway only fronts OpenAI-compatible lanes.
const HOST_TO_PROVIDER: Record<string, string> = {
  "api.openai.com": "openai",
  "api.deepseek.com": "deepseek",
  "api.kimi.ai": "kimi",
  "api.moonshot.cn": "kimi",
  "api.moonshot.ai": "kimi",
  "opencode.ai": "opencode-go",
  "api.minimaxi.com": "minimax",
  "api.voyageai.com": "voyage",
  // Both Z.AI OpenAI-compatible surfaces (coding plan /api/coding/paas/v4 and
  // general /api/paas/v4) land on the same Bifrost lane, which points at the
  // coding-plan endpoint — that is where the subscription quota lives.
  "api.z.ai": "zai",
}

// Map a vendor path onto the gateway's OpenAI-compatible surface.
// Order matters: "/chat/completions" must be tested before "/completions".
const OPERATION_SUFFIXES = [
  "/chat/completions",
  "/completions",
  "/responses",
  "/embeddings",
  "/models",
]

function gatewayPath(pathname: string): string {
  // Vendors that version their base path (api.openai.com/v1/...,
  // opencode.ai/zen/go/v1/...) carry the segment already.
  const v1 = pathname.indexOf("/v1/")
  if (v1 >= 0) return pathname.slice(v1)

  for (const suffix of OPERATION_SUFFIXES) {
    if (pathname.includes(suffix)) return `/v1${suffix}`
  }

  // Unknown shape: send it to the gateway and let it fail visibly rather than
  // silently keeping vendor-direct traffic.
  return `/v1${pathname}`
}

export default Plugin.define({
  id: "bifrost-reroute",
  setup(ctx) {
    ctx.session.hook("http.request", async (event) => {
      const url = new URL(event.request.url)
      const provider = HOST_TO_PROVIDER[url.host]
      if (!provider) return

      // Anthropic Messages traffic (/api/anthropic/...) is a different wire
      // format and the gateway only serves OpenAI-compatible lanes for these
      // providers — leave it on the vendor's own endpoint.
      if (url.pathname.includes("/anthropic")) return

      const req = event.request

      // Body is a one-shot stream: read it, then rebuild the Request.
      let body: unknown = null
      try {
        body = await req.json()
      } catch {
        // Non-JSON (or absent) body — pass through with headers/URL only.
      }

      const headers = new Headers(req.headers)
      headers.set("x-bf-dim-app", "opencode")

      url.host = BIFROST_HOST
      url.protocol = "https:"
      url.port = ""
      // Normalize the vendor's path to the gateway's OpenAI-compatible surface.
      // Some vendors version their base path (/v1/...) and some do not — Z.AI's
      // coding endpoint is /api/coding/paas/v4/chat/completions — so match the
      // known operation suffix instead of assuming a /v1 segment exists.
      url.pathname = gatewayPath(url.pathname)

      if (body && typeof body === "object") {
        const b = body as Record<string, unknown>
        if (typeof b.model === "string" && b.model.length > 0 && !b.model.includes("/")) {
          b.model = `${provider}/${b.model}`
        }
        event.request = new Request(url, {
          method: req.method,
          headers,
          body: JSON.stringify(b),
        })
      } else {
        event.request = new Request(url, { method: req.method, headers })
      }
    })
  },
})
