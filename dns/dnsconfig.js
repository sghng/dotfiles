// @ts-check
/// <reference path="types-dnscontrol.d.ts" />

var REG_NONE = NewRegistrar("none");
var DSP_CLOUDFLARE = NewDnsProvider("cloudflare", {
  manage_redirects: true,
});

/* Primary domain */

D(
  "sghuang.com",
  REG_NONE,
  DnsProvider(DSP_CLOUDFLARE),

  CNAME("www", "@"),
  ALIAS("@", "apex-loadbalancer.netlify.com."), // CNAME flattening
  MX("@", 10, "mx01.mail.icloud.com."),
  MX("@", 10, "mx02.mail.icloud.com."),

  // subdomains
  CNAME("naive", "cname.vercel-dns.com."),
  // proxy needed for Obsidian
  CNAME("notes", "publish-main.obsidian.md.", { cloudflare_proxy: "on" }),

  // redirections
  A("in", "192.0.2.1", { cloudflare_proxy: "on" }),
  A("git", "192.0.2.1", { cloudflare_proxy: "on" }),
  // ideally we should use single redirection, but DNSControl hasn't implmeneted
  // regex replacement in conversion mode
  CF_REDIRECT("in.sghuang.com", "https://linkedin.com/in/samuel-g-huang"),
  CF_REDIRECT("git.sghuang.com", "https://github.com/sghng"),
);

/* Primary shorthand */

D(
  "sgh.ng",
  REG_NONE,
  DnsProvider(DSP_CLOUDFLARE),
  // proxy all domains
  A("@", "192.0.2.1", { cloudflare_proxy: "on" }),
  A("*", "192.0.2.1", { cloudflare_proxy: "on" }),
  MX("@", 10, "mx01.mail.icloud.com."),
  MX("@", 10, "mx02.mail.icloud.com."),
  // regex replacement is not supported in conversion mode yet
  CF_REDIRECT("*sghua.ng/*", "https://$1sghuang.com/$2"),
);

/* Other shorthands */

D(
  "sghua.ng",
  REG_NONE,
  DnsProvider(DSP_CLOUDFLARE),
  // proxy all domains
  A("@", "192.0.2.1", { cloudflare_proxy: "on" }),
  A("*", "192.0.2.1", { cloudflare_proxy: "on" }),
  // regex replacement is not supported in conversion mode yet
  CF_REDIRECT("*sghua.ng/*", "https://$1sghuang.com/$2"),
);

D(
  "sghng.com",
  REG_NONE,
  DnsProvider(DSP_CLOUDFLARE),
  // proxy all domains
  A("@", "192.0.2.1", { cloudflare_proxy: "on" }),
  A("*", "192.0.2.1", { cloudflare_proxy: "on" }),
  // regex replacement is not supported in conversion mode yet
  CF_REDIRECT("*sghng.com/*", "https://$1sghuang.com/$2"),
);
