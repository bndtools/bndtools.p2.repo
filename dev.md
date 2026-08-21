# Developer Guide

This repository publishes bnd/bndtools p2 repositories, Eclipse Installer
(Oomph) setup models, and an Oomph extension used by those setups. The root
repository is mostly release and configuration data; the Oomph extension is
the part that is compiled.

## Prerequisites

- Git
- Bash for the scripts in `processing/` (Git Bash, WSL, or a Linux/macOS shell)
- Java 21 for the Oomph build (the Maven wrapper downloads Maven as needed)
- Ruby and Bundler for the Jekyll site
- `curl`, `unzip`, and `find`
- `xsltproc` when regenerating human-readable p2 indexes
- `xmllint` is optional; `test-oomph-consistency.sh` uses it when available

On Windows, run shell commands from Git Bash or WSL. The Oomph project also
provides `mvnw.cmd` for a native Windows command prompt or PowerShell.

## Repository areas

### `site/`: published website and p2 repositories

The Jekyll source is in `site/`. The numbered directories, such as
`site/7.3.0/`, are expanded p2 repositories containing metadata, features, and
plugins. `site/latest` identifies the current release and `site/p2.html` lists
all release directories. `site/latest` is a plain-text pointer in the source
tree; GitHub Pages exposes the same content through the deployed site.

Do not edit generated release metadata casually. A release directory is
normally populated from the corresponding `org.bndtools.p2-<version>.jar`,
then `content.xml` and `index.html` are generated or refreshed.

The site also contains `site/doc/` for release-specific maintenance notes,
including the ECF update procedure, and `site/_plugins/` for Jekyll plugins.

### `setup/`: Eclipse Installer models

The `.setup` files are the user-facing Eclipse Installer entry points. They
are grouped by supported scenario:

- `setup/bnd/` for bnd projects and bndtools contributor workflows
- `setup/bndtools.p2.repo/` for developing this repository
- `setup/ecf/` for bnd plus Eclipse Communication Framework projects
- `setup/workspace-templates/` for workspace-template development
- `setup/zParkProduct.setup` for the product-level setup

Configuration files select Eclipse releases and bnd/bndtools release or
snapshot repositories. Project files describe source repositories and setup
tasks. Keep release choices consistent across files containing the
`bndtools-release` task; the consistency script treats
`setup/bnd/config_bnd_10r.setup` as the canonical list.

### `org.bndtools.oomph/`: compiled Oomph extension

This is a Maven/Tycho multi-module build:

- `org.bndtools.oomph.target/` defines the target platform
- `org.bndtools.oomph.import/` implements the `org.bndtools.import` setup task
- `org.bndtools.oomph.import.feature/` packages the plugin as an installable feature
- `org.bndtools.oomph.import.site/` produces the p2 update site

The custom task runs `bnd workspace init` during Eclipse workspace setup.
Generated build output is under each module's `target/` directory and is not
part of the source release site.

### `processing/`: maintenance and validation scripts

- `human-readable-index.sh` extracts p2 metadata and transforms `content.xml`
  with `content2html.xsl` into a browsable `index.html`.
- `test-repo-consistency.sh` checks the local latest release, p2 listing, and
  README release link.
- `test-oomph-consistency.sh` checks setup release choices, repository URLs,
  PR placeholders, and XML when `xmllint` is installed.
- `test-deployed-pages-consistency.sh` checks the deployed GitHub Pages site.
- `test-all-consistency.sh` runs the three consistency checks together.

`doc/` contains general documentation and diagrams. `artifactory-sync-p2-repo/`
is reserved for the Artifactory synchronization area and currently contains
only its ignore configuration.

## Local development

### Build the Oomph extension

From `org.bndtools.oomph/`:

```bash
./mvnw -B -ntp clean verify
```

On Windows:

```powershell
.\mvnw.cmd -B -ntp clean verify
```

The p2 repository is written to
`org.bndtools.oomph.import.site/target/repository/`. Install it locally in
Eclipse with **Help > Install New Software > Add > Local** if you need to test
the feature.

The CI build uses Java 21 and runs the same Maven verification before building
the website.

### Build the website

From `site/`, install the Ruby dependencies and run Jekyll:

```bash
bundle install
bundle exec jekyll serve
```

Open the local URL printed by Jekyll. The `site/_config.yml` excludes release
directories from Jekyll processing so the p2 files remain directly accessible.

### Run validation

From the repository root:

```bash
processing/test-all-consistency.sh
```

The deployed-pages check requires network access to
`https://bndtools.org/bndtools.p2.repo/`. To check only local content, run
`processing/test-repo-consistency.sh` and
`processing/test-oomph-consistency.sh` separately.

## Release workflows

### Add a bnd/bndtools release

1. Create `site/<version>/` and download the matching p2 jar as
   `org.bndtools.p2-<version>.jar`.
2. Extract the jar into that directory.
3. Ensure `content.xml` exists and run
   `processing/human-readable-index.sh` to generate `index.html` when needed.
4. Set `site/latest` to the new version and add it to `site/p2.html`.
5. Add the release choice to every relevant Oomph setup file, preserving
   existing release and snapshot choices and any PR override placeholders.
6. Update the release links in `site/index.md` and the direct p2 example in
   `README.md`.
7. Run the consistency scripts and inspect the generated site before pushing.

The repository's `.github/skills/update-bnd-version/SKILL.md` contains the
full release checklist and current release policy.

### Add or update an ECF setup

Update `setup/ecf/project_ecf.setup`, add matching release and snapshot setup
files in `setup/ecf/`, and update the ECF table in `site/index.md`. The
existing procedure is documented in
`site/doc/ecf/update_ECF.md`.

### Change the Oomph extension

Modify the relevant module under `org.bndtools.oomph/`, run the Maven wrapper
build, and test the generated feature from the local p2 repository. Keep
plugin, feature, site, and target-platform changes aligned; Tycho resolves
the modules through the root `pom.xml`.

## CI and publishing

`.github/workflows/static.yml` builds the Oomph extension, verifies its output,
builds the Jekyll site, and deploys `site/_site` to GitHub Pages on pushes to
`master`. Release directories and setup files are therefore published from
the repository; Maven `target/` output is only a CI validation artifact.

Before opening a change, check:

```bash
git diff --check
processing/test-all-consistency.sh
```

For changes under `org.bndtools.oomph/`, also run `./mvnw -B -ntp clean verify`
from that directory with Java 21 available.