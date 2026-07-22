import '../site_customization.dart';

/// idcflare.com 站点自定义配置
///
/// IDC Flare 与 linux.do 同属一个社区生态,链接安全配置沿用社区内置域名列表
/// (COMMUNITY_*_DOMAINS),内部域名换成 *.idcflare.com,linux.do 归入信任域名。
/// 头像光晕与头衔特殊样式为 linux.do 专属(g-merchant 群组、种子用户头衔),
/// idcflare 无对应配置,故留空。
final idcflareCustomization = SiteCustomization(
  linkSecurityConfig: _idcflareLinkSecurityConfig,
);

/// idcflare.com 链接安全配置
const _idcflareLinkSecurityConfig = LinkSecurityConfig(
  enableExitConfirmation: true,
  internalDomains: [
    '*.idcflare.com',
    'localhost',
    // COMMUNITY_INTERNAL_DOMAINS
    '*.local',
    '^127(?:\\.(?:25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}',
    '^10(?:\\.(?:25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}',
    '^169\\.254(?:\\.(?:25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){2}',
    '^192\\.168(?:\\.(?:25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){2}',
    '^172\\.(?:1[6-9]|2\\d|3[0-1])(?:\\.(?:25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){2}',
  ],
  trustedDomains: [
    '*.linux.do',
    '*.uasm.net',
    '*.wegram.org',
    // COMMUNITY_TRUSTED_DOMAINS
    '*.zhile.io',
    '*.fuclaude.com',
    '*.linuxdo.org',
    '*.deeplx.org',
    '*.oaifree.com',
    '*.oaipro.com',
    '*.uasm.com',
    't.me/linux_do_channel',
    't.me/idcflare',
    't.me/ja_netfilter_group',
    'github.com/linux-do/*',
  ],
  riskyDomains: [
    // COMMUNITY_RISKY_DOMAINS
    'bit.ly', 'tinyurl.com', 't.co', 'goo.gl', 'ow.ly', 'buff.ly',
    'adf.ly', 'short.link', '*.short.link', 'tiny.cc', 'is.gd',
    'cli.gs', 'pic.gd', 'dwarfurl.com', 'yfrog.com', 'migre.me',
    'ff.im', 'tiny.pl', 'url4.eu', 'tr.im', 'twit.ac', 'su.pr',
    'twurl.nl', 'snipurl.com', 'budurl.com', 'short.to', 'ping.fm',
    'digg.com', 'post.ly', 'just.as', 'bkite.com', 'snipr.com',
    'fic.kr', 'loopt.us', 'doiop.com', 'twitthis.com', 'htxt.it',
    'alturl.com', 'redirx.com', 'digbig.com', 'short.ie',
    'u.mavrev.com', 'kl.am', 'wp.me', 'rubyurl.com', 'om.ly',
    'to.ly', 'bit.do', 'lnkd.in', 'db.tt', 'qr.ae', 'bitly.com',
    'cur.lv', 'ity.im', 'q.gs', 'po.st', 'bc.vc', 'u.to', 'j.mp',
    'buzurl.com', 'cutt.us', 'u.bb', 'yourls.org', 'x.co',
    'prettylinkpro.com', 'scrnch.me', 'filoops.info', 'vzturl.com',
    'qr.net', '1url.com', 'tweez.me', 'v.gd', 'link.zip',
  ],
  dangerousDomains: [
    // COMMUNITY_DANGEROUS_DOMAINS
    '**aff=',
  ],
  blockedDomains: [
    '*.chiddns.com',
    '*.chiclaude.com',
    '*.kcursor.xyz',
  ],
);
