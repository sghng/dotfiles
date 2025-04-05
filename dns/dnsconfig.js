// @ts-check
/// <reference path="types-dnscontrol.d.ts" />

var REG_NONE = NewRegistrar("none");
var DSP_CLOUDFLARE = NewDnsProvider("cloudflare", {
  manage_single_redirects: true,
});

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
  CNAME("notes", "publish-main.obsidian.md."),

  // redirections
  A("in", "192.0.2.1", { cloudflare_proxy: "on" }),
  A("git", "192.0.2.1", { cloudflare_proxy: "on" }),
  CF_SINGLE_REDIRECT(
    "LinkedIn",
    301,
    'http.host eq "in.sghuang.com"',
    'concat("https://linkedin.com/in/samuel-g-huang", "")',
  ),
  CF_SINGLE_REDIRECT(
    "GitHub",
    301,
    'http.host eq "git.sghuang.com"',
    'concat("https://github.com/sghng", "")',
  ),
);
