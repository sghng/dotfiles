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
// there), and Anthropic-format traffic is not mapped (we only serve
// OpenAI-compatible lanes).
const HOST_TO_PROVIDER: Record<string, string> = {
  "api.openai.com": "openai",
  "api.deepseek.com": "deepseek",
  "api.kimi.ai": "kimi",
  "api.moonshot.cn": "kimi",
  "api.moonshot.ai": "kimi",
  "opencode.ai": "opencode-go",
  "api.minimaxi.com": "minimax",
  "api.voyageai.com": "voyage",
}

export default Plugin.define({
  id: "bifrost-reroute",
  setup(ctx) {
    ctx.session.hook("http.request", async (event) => {
      const url = new URL(event.request.url)
      const provider = HOST_TO_PROVIDER[url.host]
      if (!provider) return

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
      // Normalize any versioned prefix (e.g. opencode.ai/api/v1/...) to /v1/...
      const v1 = url.pathname.indexOf("/v1")
      url.pathname = v1 >= 0 ? url.pathname.slice(v1) : `/v1${url.pathname}`

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
