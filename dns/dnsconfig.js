// @ts-check
/// <reference path="types-dnscontrol.d.ts" />

var REG_NONE = NewRegistrar("none");
var DSP_CLOUDFLARE = NewDnsProvider("cloudflare", undefined, {
	manage_redirects: true,
	manage_single_redirects: true,
});

var CF_PROXY_ON = { cloudflare_proxy: "on" };
var REDIRECT_TO_PRIMARY_DOMAIN = CF_SINGLE_REDIRECT(
	"redirect to sghuang.com",
	301,
	"*sgh.ng/*",
	"https://$1sghuang.com/$2",
);

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
	IGNORE("srv", "A"), // real IP address of server managed in dashboard
	CNAME("naive", "cname.vercel-dns.com."),
	CNAME("typ2docx", "typ2docx.onrender.com."),
	// proxy needed for Obsidian
	CNAME("notes", "publish-main.obsidian.md.", CF_PROXY_ON),
	A("jellyfin", "129.74.246.41"),

	// redirections
	A("in", "192.0.2.1", CF_PROXY_ON),
	A("git", "192.0.2.1", CF_PROXY_ON),
	CF_REDIRECT("in.sghuang.com", "https://linkedin.com/in/sghng"),
	CF_REDIRECT("git.sghuang.com", "https://github.com/sghng"),
);

/* Primary shorthand */

D(
	"sgh.ng",
	REG_NONE,
	DnsProvider(DSP_CLOUDFLARE),
	// proxy all domains
	A("@", "192.0.2.1", CF_PROXY_ON),
	A("*", "192.0.2.1", CF_PROXY_ON),
	// email
	MX("@", 10, "mx01.mail.icloud.com."),
	MX("@", 10, "mx02.mail.icloud.com."),
	CNAME("sig1._domainkey", "sig1.dkim.sgh.ng.at.icloudmailadmin.com."),
	TXT("@", "apple-domain=3ewMGQM5mVlNnFbt"),
	TXT("@", "v=spf1 include:icloud.com ~all"),
	REDIRECT_TO_PRIMARY_DOMAIN,
);

/* Other shorthands */

D(
	"sghua.ng",
	REG_NONE,
	DnsProvider(DSP_CLOUDFLARE),
	// proxy all domains
	A("@", "192.0.2.1", CF_PROXY_ON),
	A("*", "192.0.2.1", CF_PROXY_ON),
	REDIRECT_TO_PRIMARY_DOMAIN,
);

D(
	"sghng.com",
	REG_NONE,
	DnsProvider(DSP_CLOUDFLARE),
	// proxy all domains
	A("@", "192.0.2.1", CF_PROXY_ON),
	A("*", "192.0.2.1", CF_PROXY_ON),
	REDIRECT_TO_PRIMARY_DOMAIN,
);
