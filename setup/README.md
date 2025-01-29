# oomph / Eclipse Installer configuration URLs

## bnd project setups

| Topic | brief description |
|---|---|
| [stable development `bnd/master`][url-config-bnd-10]   | [EPP Java Dev](https://www.eclipse.org/downloads/packages/) + [bnd release](https://github.com/bndtools/bnd/wiki/Changes-in-7.1.0) on [github repo](https://github.com/bndtools/bnd)            |
| [snapshot development `bnd/master`][url-config-bnd-11] | [EPP Java Dev](https://www.eclipse.org/downloads/packages/) + [bnd snapshot](https://github.com/bndtools/bnd/wiki/Changes-in-7.2.0) on [github repo](https://github.com/bndtools/bnd/tree/next) |
| [stable development `bnd/next`][url-config-bnd-20]     | [EPP Java Dev](https://www.eclipse.org/downloads/packages/) + [bnd release](https://github.com/bndtools/bnd/wiki/Changes-in-7.1.0) on [github repo](https://github.com/bndtools/bnd/)           |
| [snapshot development `bnd/next`][url-config-bnd-21]   | [EPP Java Dev](https://www.eclipse.org/downloads/packages/) + [bnd snapshot](https://github.com/bndtools/bnd/wiki/Changes-in-7.2.0) on [github repo](https://github.com/bndtools/bnd/tree/next) |

## bnd-based project/workspace setups

| Project/file URL \* | [Eclipse EPP](https://www.eclipse.org/downloads/packages/) |
|---|---|
| [empty bnd][url-config-bnd-50] / [file\*][file-url-config-bnd-50]  | EPP Java Dev + bnd on empty bnd workspace        |
| [import bnd][url-config-bnd-51] / [file\*][file-url-config-bnd-51] | EPP Java Dev + bnd on import bnd workspace       |
| [empty ecf][url-config-ecf-10] / [file\*][file-url-config-ecf-10]  | EPP Java Dev + bnd + ecf on empty ECF workspace  |

(*) requires local available repository inside following location `C:/IDEfix/bndtools-p2-repo-master/git/bndtools.p2.repo`

[url-config-bnd-10]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_10.setup
[url-config-bnd-11]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_11.setup
[url-config-bnd-20]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_20.setup
[url-config-bnd-21]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_21.setup

[url-config-bnd-50]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_50.setup
[file-url-config-bnd-50]: eclipse+installer:file:///C:/IDEfix/bndtools-p2-repo-master/git/bndtools.p2.repo/setup/bnd/config_bnd_50.setup
[url-config-bnd-51]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_51.setup
[file-url-config-bnd-51]: eclipse+installer:file:///C:/IDEfix/bndtools-p2-repo-master/git/bndtools.p2.repo/setup/bnd/config_bnd_51.setup

[url-config-ecf-10]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/ecf/config_ecf_10.setup
[file-url-config-ecf-10]: eclipse+installer:file:///C:/IDEfix/bndtools-p2-repo-master/git/bndtools.p2.repo/setup/ecf/config_ecf_10.setup
