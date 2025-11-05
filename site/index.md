---
layout: page
title: "oomph setups for bnd"
---

## overview on bnd/bndtools setups

This page contains eclipse-installer setups for eclipse with pre-configured bnd/bndtools and configurations.
All setups are based on the **eclipse-installer** aka. **oomph**.

<a href="https://www.eclipse.org/setups/installer/" target="_blank">Press here to download, install and register URL protocol handler from **eclipse-installer** as a pre-requisite for all of these setups.</a>

We assume that the locally installed oomph with a registered URL handler for the protocol `eclipse+installer` is available from here onwards.

To launch the eclipse-installer for a selected setup press the button launch at the beginning of a row.

# Table of Contents

- [overview on bnd/bndtools setups](#overview-on-bndbndtools-setups)
- [I want to develop my project with bnd](#i-want-to-develop-my-project-with-bnd)
- [I want to develop my project with bnd+ecf](#i-want-to-develop-my-project-with-bndecf)
- [I want to contribute to github organisation `bndtools`](#i-want-to-contribute-to-github-organisation-bndtools)
    - [github repo `bnd`](#github-repo-bnd)
    - [other bndtools repos](#other-bndtools-repos)

## I want to develop my project with bnd

This section contains setups with Eclipse and bnd ([**release**][41] or [**snapshot**][42] versions).
Choose what **IDE you want have** and what you **want to do**.

| ![link][96] ![oomph][95]         | I want to have ...         | I want to do ...                                   |
|:--------------------------------:|----------------------------|----------------------------------------------------|
| [{{ site.install_button }}][50r] | eclipse + bnd **release**  | start a **new project** in a empty workspace       |
| [{{ site.install_button }}][50s] | eclipse + bnd **snapshot** | start a **new project** in a empty workspace       |
| [{{ site.install_button }}][51r] | eclipse + bnd **release**  | import a **existing local git repo**               |
| [{{ site.install_button }}][51s] | eclipse + bnd **snapshot** | import a **existing local git repo**               |
| [{{ site.install_button }}][52r] | eclipse + bnd **release**  | import a github repo `organisation/project:branch` |
| [{{ site.install_button }}][52s] | eclipse + bnd **snapshot** | import a github repo `organisation/project:branch` |

[50r]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_50r.setup
[50s]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_50s.setup
[51r]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_51r.setup
[51s]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_51s.setup
[52r]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_52r.setup
[52s]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_52s.setup

## I want to develop my project with bnd+ecf 

[ecf - Eclipse Communication Framework](https://github.com/eclipse-ecf/ecf)

| ![link][96] ![oomph][95]        | I want to have ...                         | I want to do ...                             |
|:-------------------------------:|--------------------------------------------|----------------------------------------------|
| [{{ site.install_button }}][60] | eclipse + **latest ecf** + bnd **release** | start a **new project** in a empty workspace |
| [{{ site.install_button }}][61] | eclipse + **ecf 3.15.7** + bnd **release** | start a **new project** in a empty workspace |

[60]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/ecf/config_ecf_60.setup
[61]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/ecf/config_ecf_61.setup

## I want to contribute to github organisation [`bndtools`](https://github.com/bndtools)

This section contains setups used projects/repos inside bndtools.

### github repo [`bnd`](https://github.com/bndtools/bnd)

As base IDE for bnd setups we are using the EPP package [Eclipse for Eclipse Committers][90]

For a detailed overview on EPP packages see [comparison of Eclipse EPP Packages][91]

| ![link][96] ![oomph][95]         | I want to have ...          | I want to do bugfix or development on                      |
|:--------------------------------:|-----------------------------|------------------------------------------------------------|
| [{{ site.install_button }}][10r] | eclipse + bnd **release**   | github project `bndtools/bnd` on branch `master`           |
| [{{ site.install_button }}][10s] | eclipse + bnd **snapshot**  | github project `bndtools/bnd` on branch `master`           |
| [{{ site.install_button }}][11s] | eclipse + bnd **snapshot**  | github project `bndtools/bnd` with **branch selection**    |
| [{{ site.install_button }}][12s] | eclipse + bnd **snapshot**  | my github `organisation/project` with **branch selection** |
| [{{ site.install_button }}][13s] | eclipse + bnd **snapshot**  | on a **import of existing local repo  git repo**           |

[10r]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_10r.setup
[10s]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_10s.setup
[11s]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_11s.setup
[12s]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_12s.setup
[13s]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bnd/config_bnd_13s.setup

### other bndtools [repos](https://github.com/bndtools)

| ![link][96] ![oomph][95]         |  I want to have ...        | I want to do bugfix or development on         |
|:--------------------------------:|----------------------------|-----------------------------------------------|
| [{{ site.install_button }}][21s] | eclipse + bnd **snapshot** | repo `bndtools.p2.repo` on branch `master`    |
| [{{ site.install_button }}][22s] | eclipse + bnd **snapshot** | repo `workspace-templates` on branch `master` |

[21s]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/bndtools.p2.repo/config_bndtools-p2-repo_21s.setup
[22s]: eclipse+installer:https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/workspace-templates/config_workspace-templates_22s.setup

[41]: https://github.com/bndtools/bnd/wiki/Changes-in-7.1.0
[42]: https://github.com/bndtools/bnd/wiki/Changes-in-7.2.0

[90]: https://www.eclipse.org/downloads/packages/
[91]: https://www.eclipse.org/downloads/packages/compare

[95]: {{ site.baseurl }}/assets/oomph_24x24.png
[96]: {{ site.baseurl }}/assets/link_24x24.png
