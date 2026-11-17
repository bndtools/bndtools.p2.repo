# Testbed for bndtools.p2.repo

## 1. Title, status, and approval

| Item | Value |
|---|---|
| Subject | Testbed (automated checks plus manual sandbox) for the capabilities of `bndtools.p2.repo` |
| Revision | 2, 2026-11-13 |
| Status | **Approved** by the maintainer on 2026-11-13 (see section 13) |
| Decision authority | Repository maintainer who took part in the interview |
| Kind of document | Discovery result and first-level realization plan. It contains no implementation. |

Revision 2 differs from the reviewed revision 1 in three points: the fixture is
a small workspace stored in this repository instead of an outside repository
(D-16, D-19), the proposals P-01 to P-04 and Q-05 to Q-07 are accepted, and the
assumptions A-03 and A-04 are confirmed. Open questions that remain are listed
in section 11 and were accepted as open.

## 2. Executive understanding

**Problem.** Changes to this repository go live as soon as they reach `master`.
Nothing proves beforehand that a published p2 release installs, that a setup
link produces a working Eclipse, or that the Oomph extension does what it
should. Adding a bnd release is manual, touches many files, and is easy to get
partly wrong.

**Intended users.** The maintainer and other contributors to this repository.
End users of the setups benefit indirectly.

**Confirmed needs (what the testbed must make possible or protect).**

| ID | Need | Confirmed |
|---|---|---|
| N-01 | A broken change is caught before it is merged to `master`. | Yes |
| N-02 | There is proof that a published p2 release really installs into Eclipse, not only that files exist. | Yes |
| N-03 | There is proof that the setup links provision a working Eclipse and workspace end to end. | Yes |
| N-04 | There is a safe place to try setup, site, and extension changes without touching the live site or `master`. | Yes |
| N-05 | The Oomph extension is protected against regressions. | Yes |
| N-06 | Adding a bnd release takes less manual effort and produces fewer mistakes. | Yes |

Two candidate needs were offered and **not** selected: early warning about
changes in the outside world, and contributors verifying their own change
without the maintainer. They are not goals of this testbed. The scheduled runs
described below still happen, because they carry the part of N-03 that is too
heavy for a pull request.

**Proposed outcome (solution strategy, distinct from the needs).** A layered
testbed: cheap static checks, p2 installation tests, headless setup runs with a
console installer, deep UI-level checks for a representative set, functional
tests for the extension, and a release script with a workflow. The same entry
point serves automated runs and the manual sandbox.

**Measurable success.** Each requirement in section 5 has an observable
acceptance criterion. An overall time limit for pull-request feedback is
deliberately open; it is decided after the first measurements (OQ-01).

## 3. Context and scope

### 3.1 Capabilities of the repository

"Capabilities" means the following six features, as confirmed by the
maintainer.

| ID | Capability | Location |
|---|---|---|
| C-1 | p2 repositories: 26 expanded releases (4.2.0 to 7.5.0), the `latest` alias, and the release listing | `site/<version>/`, `site/latest`, `site/p2.html` |
| C-2 | Oomph setup models: 15 Configuration files, 5 Project files, 1 product setup | `setup/` |
| C-3 | Oomph extension with the task type `org.bndtools.import` | `org.bndtools.oomph/` |
| C-4 | Jekyll website and GitHub Pages deployment | `site/`, `.github/workflows/static.yml` |
| C-5 | Maintenance and consistency scripts | `processing/` |
| C-6 | Release procedure | `.github/skills/update-bnd-version/SKILL.md`, `dev.md` |

### 3.2 Current situation (facts with evidence)

| ID | Fact | Evidence |
|---|---|---|
| F-01 | The only build workflow runs on pushes to `master` and on manual start. There is no run for pull requests, so deployment and first verification coincide. | `.github/workflows/static.yml` |
| F-02 | The workflow builds the extension with Tycho, checks that its repository folder is not empty, builds Jekyll, and deploys. It does not run the consistency scripts. | `.github/workflows/static.yml` |
| F-03 | Three bash consistency scripts exist and are run by hand. They check file presence, release choices, placeholders, and reachability of the deployed site. | `processing/test-*.sh` |
| F-04 | Nothing installs p2 content, and nothing executes a setup file. There are no Java tests. | Repository file list |
| F-05 | `site/latest` and `site/oomph-bndtools-import-task` are stored in Git as symbolic links (mode 120000). `dev.md` describes `site/latest` as a plain-text pointer. On a Windows checkout without symbolic-link support both appear as small text files. | `git ls-files -s`, `dev.md` |
| F-06 | The consistency scripts read `site/latest` as a text file. Whether they pass on a checkout where it is a real symbolic link to a directory has not been verified. | `processing/test-repo-consistency.sh`, `processing/test-oomph-consistency.sh` |
| F-07 | The deployed `latest` alias serves a p2 repository, and the extension's p2 site is published under `oomph-bndtools-import-task/`. | R-09 |
| F-08 | Setup files reference each other with relative paths. Only the p2 address `https://bndtools.org/bndtools.p2.repo/...` is absolute and points at the live site. | `setup/bnd/config_bnd_50r.setup` |
| F-09 | The release variable `bndtools-release` already offers a free `RepoURL` choice (`${pr.repo.uri}`) and a pull-request choice. | `setup/bnd/config_bnd_50r.setup` |
| F-10 | Two setups depend on an external model at `https://cdn.klib.io/oomph/setups-github/BndConfiguration.setup`. | `setup/bndtools.p2.repo/project_bndtools-p2-repo.setup`, `setup/workspace-templates/project_workspace-templates.setup` |
| F-11 | `README.md` of the extension and `dev.md` state that the task runs "bnd workspace init". The code opens the bndtools import wizard `bndtools.importProject` and fails when it is cancelled. `isNeeded` always returns true. | `org.bndtools.oomph/org.bndtools.oomph.import/src/org/bndtools/oomph/importer/BndWorkspaceImportTask.java` |
| F-12 | No file under `setup/` uses the task type `org.bndtools.import`. | Search over `setup/` |
| F-13 | The workflow inside `org.bndtools.oomph/.github/` is inactive, because GitHub only reads the root `.github/` folder. It names Java 17; the root workflow uses Java 21. | `org.bndtools.oomph/.github/workflows/ci.yml` |
| F-14 | The local bnd command line (7.6.0 snapshot) has no command `workspace init`. The nearest command is `bnd add workspace`. | `bnd help add` |
| F-15 | The import streams of the bnd workspace setups use Oomph's `ProjectsImportTask` without project factories of their own. That task works with Oomph's Eclipse project factory. | `setup/bnd/project_bnd_workspace.setup`, R-06 |
| F-16 | The repository is licensed under EPL-2.0. | `LICENSE` |

### 3.3 Setup families

| Family | Configurations | Character |
|---|---|---|
| F1 empty bnd workspace | `50r`, `50s` | Java package, no clone |
| F2 import bnd workspace | `51r`, `51s` (local Git repository), `52r`, `52s` (`organisation/project:branch`) | Java package, needs a bnd workspace as input |
| F3 bnd contributor | `10r`, `10s`, `11s`, `12s`, `13s` | RCP or Committers package, clones `bndtools/bnd`, Maven import |
| F4 bnd plus ECF | `64r`, `64s` | Java package plus ECF p2 site |
| F5 repository development | `21s`, `22s` | Clone and import, depends on F-10 |
| F6 product | `zParkProduct.setup` | Product definition |

### 3.4 In scope

- Automated checks for C-1 to C-6 on pull requests, on a schedule, and on manual start.
- A manual sandbox that uses the same entry point as the automated runs.
- Bringing the Oomph extension to its intended behavior, test first (D-13).
- A release script and a manually started release workflow (D-12, D-14).

### 3.5 Exclusions

- Automatic detection of new bnd releases (later possibility).
- A preview site per pull request (S3, deferred).
- Hermetic tests without network access (N3, rejected).
- Installation tests for the 19 releases that the setups no longer offer; they receive structure checks only (D-06).
- Changing the content of existing release directories.

### 3.6 Later possibilities

- Release detection that opens the release pull request by itself.
- Preview deployment per pull request.
- Updating the console installer fork to a current Oomph version, if the experiment in W-01 does not already force it.

## 4. Shared glossary

Agreement states: **Confirmed** means the maintainer defined or explicitly
confirmed the meaning. **Explained** means the term was explained and then used
by the maintainer in a decision; explicit confirmation is requested with the
review of this draft.

| Term | Plain-language meaning in this project | Example or non-example | Aliases or distinctions | Agreement |
|---|---|---|---|---|
| Testbed | The environment in which the repository's capabilities are exercised: automated checks plus a manual sandbox. | Both a pull-request workflow and a local script belong to it. | Not only continuous integration. | Confirmed |
| Capability | One of the six features C-1 to C-6 of this repository. | The setup models are a capability. | Not the OSGi or p2 "provided capability" entries inside `content.xml`. | Confirmed |
| PR gate | Checks that run on a pull request and must pass before merge. | A failed setup run blocks the merge. | Different from checks after deployment. | Explained |
| p2 repository | A folder with metadata and artifacts from which Eclipse installs software. | `site/7.5.0/` | Also called update site. | Explained |
| Install test | The p2 director installs the bndtools features from a p2 repository into a fresh Eclipse and must finish without error. | Installing `bndtools.main.feature` from the local `site/7.5.0/`. | A structure check only looks at files and metadata. | Explained |
| Structure check | Verification that a release directory is complete and its metadata is readable, without installing. | `content.xml`, `artifacts.jar`, and `index.html` exist and parse. | Weaker than an install test. | Explained |
| Eclipse Installer (Oomph) | The tool that reads setup models and builds an Eclipse installation and workspace. | Started by an `eclipse+installer:` link. | "Oomph" and "Eclipse Installer" name the same tool here. | Explained |
| Configuration | A setup file that names a product, a workspace stream, and variables; one install button points at one Configuration. | `setup/bnd/config_bnd_50r.setup` | A Project file (`project_*.setup`) holds the tasks and is referenced by Configurations. | Explained |
| Trigger | The phase in which setup tasks run. BOOTSTRAP: the installer builds Eclipse. STARTUP: the installed Eclipse starts for the first time and performs workspace tasks. | Clone and project import happen at STARTUP. | The console installer covers BOOTSTRAP; STARTUP needs a display. | Explained |
| Level A | The installer finishes; Eclipse exists and contains the bndtools features from the chosen p2 repository. | BOOTSTRAP only. | Does not prove clone or import. | Explained |
| Level D | Level A, plus first start with all STARTUP tasks finished without error, plus a workspace that builds without errors, plus the UI checks of REQ-08. | The meaning of "works end to end". | Levels B and C are the intermediate steps and are contained in D. | Confirmed |
| Console installer | A build of the Eclipse Installer that runs without a user interface. | `io.klib.tools:org.eclipse.oomph.console.product:1.0.8` | Fork of `a-langer/eclipse-oomph-console`. | Explained |
| Redirection | A setting that makes the installer read one address from another place. | Reading `https://bndtools.org/bndtools.p2.repo/` from a local server. | Does not change the setup files. | Explained |
| Sandbox | A place to try a change by hand before pushing, isolated from the live site, from `master`, and from the user's own Eclipse settings. | Local script (S1), container (S2). | Not the live site. | Confirmed |
| Fixture | A small, known bnd workspace stored in this repository and used as test input. | `cnf/` plus one or two tiny projects, with Eclipse project files committed. | Not generated at test time; not an outside repository. | Confirmed |
| Representative set | The Configurations that run at level D on every pull request. | `50r`, `51r`, `64r` | All other Configurations reach level D only on schedule. | Confirmed |
| Scheduled run | A run of the full matrix at a fixed interval, independent of pull requests. | Level D for all Configurations. | Can also be started manually. | Explained |
| `latest` alias | The address that always serves the newest release. | `https://bndtools.org/bndtools.p2.repo/latest` | A symbolic link in Git (F-05). | Explained |
| SWTBot | A library that drives and inspects the Eclipse user interface from tests. | Opening the Bndtools perspective and reading the Problems view. | Needs a real or virtual display. | Explained |

## 5. User journeys and functional requirements

### 5.1 Journeys

- **J-1 Contributor opens a pull request.** The PR gate runs on Linux, Windows,
  and macOS. The contributor sees per check what failed and where the logs and
  screenshots are.
- **J-2 Maintainer tries a change locally.** One command serves the local site,
  starts the installer (console or normal user interface) against the local
  `site/` and `setup/`, and installs into a throwaway folder with a separate
  user home.
- **J-3 Maintainer adds a bnd release.** The maintainer starts the release
  workflow with a version. A pull request appears. The PR gate checks it like
  any other pull request.
- **J-4 Scheduled run fails.** A tracking issue is opened or updated; it is
  closed when the run is green again.

### 5.2 Requirements

| ID | Requirement | Actors and preconditions | Acceptance criteria | Needs, decisions |
|---|---|---|---|---|
| REQ-01 | Every pull request is verified before merge. | Contributor; pull request against `master`. | A workflow runs on pull requests. A pull request that breaks any check below shows a failed status. Nothing is deployed from a pull request. | N-01, D-04 |
| REQ-02 | Static checks run on every pull request. | – | The consistency scripts run and pass on a Linux checkout with real symbolic links as well as on Windows. Every `.setup` file is well-formed XML. Every release choice set matches the canonical list. | N-01, F-05, F-06 |
| REQ-03 | Every release directory passes a structure check. | 26 releases. | For each `site/<version>/`: required files exist and metadata parses. A deliberately damaged directory makes the check fail. | N-02, D-06 |
| REQ-04 | Offered releases pass an install test. | Fresh Eclipse; local copy of the site. | On pull requests the `latest` alias and every release directory touched by the pull request install without error. On schedule the seven offered releases (7.5.0, 7.4.0, 7.3.0, 7.2.3, 7.1.0, 7.0.0, 6.4.1) install without error. | N-02, D-06 |
| REQ-05 | Every Configuration reaches level A on every pull request. | Console installer; setup files taken from the pull request, p2 content from the local site through redirection. | For each of the 15 Configurations the installer exits successfully, the installation exists, and the installed bndtools version equals the chosen release. A run never waits for input; an unresolved variable fails the run and names the variable. | N-03, D-03, D-04 |
| REQ-06 | The representative set reaches level D on every pull request. | F1, F2, F4. | For each Configuration of the representative set, on each operating system: first start completes, the setup log contains no error, and all checks of REQ-08 pass. | N-03, D-03, D-05, P-01 |
| REQ-07 | The full matrix reaches level D on schedule and on manual start. | All families, release and snapshot variants. | A scheduled and a manually startable workflow run every Configuration at level D and the install tests of REQ-04. | N-03, D-04 |
| REQ-08 | Level D includes these UI checks. | Installed Eclipse with display. | (a) Installed bndtools version equals the version of the chosen p2 release. (b) The Bndtools perspective opens. (c) The Problems view shows no errors after the build. (d) The Error Log has no error entries from bndtools or Oomph. (e) One action per family: F1 a new bnd project created with the wizard builds; F2 the fixture's projects are present and built; F4 the ECF features are present. (f) The Bnd Repositories view lists repositories without error. (g) Preferences set by the setup have the expected values. | N-03, D-15 |
| REQ-09 | A local sandbox script exists and is the same entry point the automated runs use. | Maintainer; Linux, Windows (Git Bash), macOS. | One command serves the local site including a working `latest` alias, starts the console or the normal installer with redirections to local `site/` and `setup/`, and installs into a throwaway folder. The user's own `~/.p2`, `~/.eclipse`, and existing installations are unchanged afterwards. The live site and `master` are not contacted for repository content under test. | N-04, D-07 |
| REQ-10 | A container offers the same tools as the Linux automated run. | Docker or WSL available. | Starting the container and running the sandbox script inside it gives the same results as the Linux pull-request run. | N-04, D-07 |
| REQ-11 | The Oomph extension is tested at three depths. | Tycho build output. | X1: the extension builds and its p2 site installs into an Eclipse that contains Oomph. X2: a sample setup file using `org.bndtools.import` loads without an unknown-type error. X3: running the task fulfils REQ-12. | N-05, D-11 |
| REQ-12 | The task `org.bndtools.import` creates a bnd workspace. | Workspace location without a bnd workspace. | After the task ran during setup, the workspace location contains `cnf/` with `build.bnd`, Eclipse shows it as a bnd workspace, and no user click was needed. | N-05, D-11, D-13 |
| REQ-13 | One script performs the mechanical release steps. | Version and, optionally, artifact address. | Running it for a new version produces the release directory with metadata and index, updates `latest`, `site/p2.html`, the release choices in every setup, and the documentation links. Running it twice changes nothing the second time. A wrong version or unreachable artifact fails without leaving partial changes. | N-06, D-12 |
| REQ-14 | A manually started workflow opens the release pull request. | Maintainer starts it with a version. | A pull request containing exactly the changes of REQ-13 exists; the PR gate runs on it. | N-06, D-12, D-14 |
| REQ-15 | Release completeness is checked. | Any pull request. | Every point of the definition of done in the release skill is an automated check within REQ-02 to REQ-05. | N-06, D-12 |
| REQ-16 | A failing scheduled run is tracked in one issue. | Scheduled run. | First failure opens an issue, further failures update the same issue, the first green run closes it. | D-17 |
| REQ-17 | Downloads are cached between runs. | All runs. | A second run with unchanged inputs downloads less than the first; a documented rule states when the cache is renewed (OQ-03). | D-10 |
| REQ-18 | A small fixture bnd workspace is stored in this repository. | F2 tests, comparison for the extension test. | The fixture contains `cnf/` with `build.bnd` and at least one bnd project, each with committed `.project` and `.classpath`. It builds without errors in Eclipse with every offered bndtools release. For `51` a copy is turned into a local Git repository at test time. A pull request that changes the fixture is tested with the changed fixture. | D-16, D-19 |

**Additions proposed by the interviewer and accepted by the maintainer.**

| ID | Addition | Reason |
|---|---|---|
| P-01 | The representative set is exactly `50r`, `51r`, `64r`. `52r` and all snapshot variants run on schedule. | One release variant per chosen family. `52` clones from GitHub and therefore tests the state of a pushed branch, not of the pull request's working tree. |
| P-02 | The pull-request run also builds the Jekyll site and verifies that every install link in `site/index.md` points at an existing setup file. | Capability C-4 has no check otherwise. |
| P-03 | After each deployment the existing deployed-pages check runs. | Reuses `processing/test-deployed-pages-consistency.sh`; verifies the live result. |
| P-04 | The release workflow creates its commit with the person who started it as author, through the GitHub interface that yields a verified signature (the technique already used in `.github/workflows/dependabot-sign.yml`). | Commits in this repository are signed and carry a human author. |

## 6. Options and decisions

| ID | Decision | Alternatives considered | Rationale and trade-off | Status |
|---|---|---|---|---|
| D-01 | "Testbed" means automated checks and a manual sandbox. | Only one of both. | Maintainer's definition. | Confirmed |
| D-02 | "Capabilities" means the six repository features C-1 to C-6. | OSGi or p2 capabilities in metadata. | Maintainer's definition. | Confirmed |
| D-03 | "Works end to end" means level D. | A, B, C. Interviewer recommended B for a representative set. | Maintainer wants UI-level proof. Trade-off: slowest, most network-dependent, most prone to unstable results. | Confirmed |
| D-04 | Tiered execution: pull request runs static checks, install tests, level A for all, level D for the representative set; schedule and manual start run the full matrix. | Everything on every pull request; path-based selection; tiered plus path-based (recommended). | Maintainer chose tiered without path-based selection. Trade-off: every pull request, including documentation-only ones, pays the full pull-request tier. | Confirmed |
| D-05 | Level D on pull requests for families F1, F2, F4. | Any other subset. | Covers p2 install, project import, and an additional p2 site without cloning large outside repositories. Trade-off: F3, F5, F6 breakage is seen only on schedule. | Confirmed |
| D-06 | Install test for `latest` and touched releases on pull requests, for the seven offered releases on schedule; structure check for older releases. | All seven on pull requests; all 26; latest only. | Old releases are frozen and may fail for reasons unrelated to this repository. Trade-off: no proof that 4.x to 6.3 still install. | Confirmed |
| D-07 | Sandbox as local script (S1) plus container (S2). | Preview site per pull request (S3). | Same entry point locally and in automation. The container only serves the Linux path; Windows and macOS use the script natively. | Confirmed |
| D-08 | Linux, Windows, and macOS on every pull request. | Linux only; Windows and macOS on schedule (recommended). | Setup users work on all three. Trade-off: three times the run time and three times the exposure to outside failures per pull request. | Confirmed |
| D-09 | Headless engine is the klibio console installer 1.0.8 as published; updating the fork is the fallback. | Update the fork first (E2); drive the normal installer with SWTBot (E3); own headless application (E4). | It exists, is published, and accepts Configuration files and redirections. Trade-off: built on Oomph 1.28.0. | Confirmed, subject to W-01 |
| D-10 | Live servers with cache everywhere (N2). | Live without cache (N1); hermetic (N3); cache on pull requests only (recommended). | Corrected by the maintainer from N1 to N2. Trade-off: a cache can hide outside breakage; a renewal rule is needed. | Confirmed |
| D-11 | The intended behavior of `org.bndtools.import` is the documented one, not the wizard in the code. It is tested at depth X3. | Code is right and documentation outdated; experimental. | Maintainer's statement. | Confirmed |
| D-12 | Release effort is reduced by completeness checks, a script, and a workflow that opens the pull request (R3). | Checks only (recommended); checks plus script. | Maintainer wants the automation inside this plan. Trade-off: the plan grows beyond a test environment. | Confirmed |
| D-13 | Expected result of the task: a fresh bnd workspace at the workspace location. The code change is part of this plan, test first. | Import of an existing workspace; create or import; code change outside the plan. | A test that stays red protects nothing. | Confirmed |
| D-14 | The release workflow is started manually with the version as input. | Automatic detection; both. | A release is rare and a person decides its timing. | Confirmed |
| D-15 | All seven UI checks of REQ-08 apply. | Without the preference check (recommended). | Maintainer wants full coverage. Trade-off: the preference check covers many small values and needs upkeep when setups change. | Confirmed |
| D-16 | The fixture is a small bnd workspace created for this purpose. | `https://github.com/klibio/example.bnd.rcp`, chosen first and then replaced by the maintainer after the gaps in section 7.2 were listed. | A small fixture is fast to clone and build and contains only what the tests need. Trade-off: it exercises less than a real application workspace. | Confirmed |
| D-19 | The fixture lives in this repository under a test folder. | Own small public repository; generated at test time with the bnd command line. | Fixture and setups change together in one pull request, the fixed state comes with the commit, and the repository license applies. Trade-off: for `52` the workspace sits nested inside a larger repository instead of at the root, unlike a typical user repository, and a stored fixture can age against new bnd releases. | Confirmed |
| D-17 | A failing scheduled run is tracked in one issue. | Issue plus badge (recommended); badge only. | Maintainer chose the issue alone. | Confirmed |
| D-18 | This document is stored at `doc/testbed.md`. | – | Not published on the website. | Confirmed |

## 7. Edge cases and failure behavior

### 7.1 Scenarios

| ID | Scenario | Expected behavior and feedback | Data effects and recovery | Requirements |
|---|---|---|---|---|
| EC-01 | An outside server (Eclipse downloads, JFrog, GitHub, `cdn.klib.io`) is unavailable. | With a filled cache the run continues. On a cache miss the check fails and the message names the unreachable address. | No repository data changes. Rerun after recovery. | REQ-17 |
| EC-02 | A setup variable has no value and no default. | The run fails promptly and names the variable. It never waits for input and never continues with an empty value. | Throwaway installation is discarded. | REQ-05 |
| EC-03 | The console installer cannot read a current setup model or the current product catalog. | Detected in W-01. The fallback of D-09 applies; no silent skipping of Configurations. | – | D-09, RISK-01 |
| EC-04 | A pull request changes setup files. | The run uses the setup files of the pull request, never those of `master`. | – | REQ-05 |
| EC-05 | A pull request comes from a fork. | Checks run with read-only permissions and without secrets. Workflows that need write access (release, tracking issue) do not run on pull-request content. | – | REQ-01, section 8 |
| EC-06 | Snapshot content on JFrog is broken. | Affects scheduled runs only, because snapshot variants are not in the representative set. The tracking issue records it. | – | REQ-07, REQ-16 |
| EC-07 | First start hangs or a dialog blocks STARTUP. | A time limit ends the run; a screenshot and the setup log are kept as evidence. | Throwaway installation is discarded. | REQ-06 |
| EC-08 | The checkout has no real symbolic links (Windows). | The local server and the scripts resolve the `latest` alias themselves. Results equal those on Linux. | – | REQ-02, REQ-09 |
| EC-09 | The release script is run for an existing version, or twice. | No change the second time; an existing release directory is not overwritten silently. | Idempotent. | REQ-13 |
| EC-10 | The release artifact cannot be downloaded or is not a p2 repository. | The script fails and leaves no partial release directory or pointer change. | Clean working tree after failure. | REQ-13 |
| EC-11 | A pull request changes the fixture. | The pull-request run uses the changed fixture, so the change is verified together with the setups. | – | REQ-18 |
| EC-12 | Two runs happen at the same time on one machine. | Each run uses its own throwaway folder and user home; neither affects the other. | – | REQ-09 |

### 7.2 Fixture: what the small fixture must contain

The maintainer first named `klibio/example.bnd.rcp` as fixture and asked for a
list of what it lacks for the tests. After that list the maintainer decided on
a small fixture stored in this repository (D-16, D-19). The findings remain
here because they define what the small fixture has to provide.

Requirements derived for the small fixture:

- Eclipse project files (`.project`, `.classpath`) are committed for `cnf` and
  every project, because the import streams of `51` and `52` rely on them
  (from FX-1).
- The state under test is the commit of the pull request; no tag or separate
  branch is needed (from FX-2).
- The repository license covers it (from FX-3).
- It builds without errors in Eclipse with every offered bndtools release; this
  is part of REQ-18 (from FX-5).
- It reads as few outside repositories as possible (from FX-6).
- It is small: `cnf/` and one or two tiny projects (from FX-7).
- The expected project names are stored with the tests (from FX-8).

Findings for `klibio/example.bnd.rcp`, inspected at commit
`6eb3b027e716267696cee1c3c14e6956452530a9` (2026-09-11), source R-07:

| ID | Finding | Effect on the tests | Possible resolution (not pursued) |
|---|---|---|---|
| FX-1 | `.project` and `.classpath` are listed in `.gitignore`; none of the seven bnd projects nor `cnf` has them committed. | The import streams of `51` and `52` use Oomph's project import, which works with Eclipse project descriptions (F-15). With this fixture the import is expected to find no projects, so check (e) for F2 would fail. To be confirmed in W-01. | Commit Eclipse metadata on a dedicated fixture branch, or make the setups import bnd workspaces in a bnd-aware way. The second option touches the purpose of the extension (REQ-12). |
| FX-2 | No tags and no dedicated stable branch. | `51` can use a fixed commit. `52` takes a branch name, so it would follow a moving `main`. | Dedicated branch or tag for tests. |
| FX-3 | No license file. | Cloning at test time is unaffected. Copying fixture content into this repository would have no stated permission. | Owner adds a license. |
| FX-4 | The latest run of its own workflow on `main` failed in the Linux job, in the step that uploads test results and screenshots; the Windows and macOS jobs passed. | The fixture's own health signal is red on one of the three systems this testbed uses. | Owner repairs the workflow. |
| FX-5 | Unknown whether the workspace builds without errors inside Eclipse with each offered bndtools release. It compiles for Java 21. | Check (c) depends on it. A fixture error would look like a setup error. | Measure in W-06; restrict the fixture to projects that build cleanly. |
| FX-6 | Its bnd configuration reads Maven Central and `https://oss.sonatype.org/content/repositories/osgi/`; availability of the latter was not verified. | Additional outside dependencies during level D. | Verify; include in the cache. |
| FX-7 | About 78 MB, including legacy build folders and a PDF that the tests do not need. | Clone time on three systems per pull request. | Shallow clone, or a slim fixture branch. |
| FX-8 | No description of the expected result. | The tests need the list of expected projects. | Derive once and store with the tests: `example.osgi.services`, `example.rcp.app.ui`, `example.rcp.app.ui.swtbot.tests`, `example.rcp.headless`, `example.rcp.ui`, `io.klib.app.p2.mirror`, `io.klib.eclipse.snippets`, plus `cnf`. |

That repository also contains a project with SWTBot tests
(`example.rcp.app.ui.swtbot.tests`, `cnf/ext/swtbot.bnd`), which can serve as a
pattern for SWTBot in a bnd workspace.

## 8. Quality and operational requirements

| ID | Requirement | Status |
|---|---|---|
| Q-01 | Pull-request feedback time. No limit is set. W-01 measures, then the maintainer decides. | Open (OQ-01) |
| Q-02 | Platforms: Linux, Windows, macOS on every pull request. | Confirmed (D-08) |
| Q-03 | Network: live servers with cache. | Confirmed (D-10) |
| Q-04 | Isolation: no run changes the user's own Eclipse settings, bundle pool, or installations; no run writes to the live site or `master`. | Confirmed (REQ-09) |
| Q-05 | Security: checks that execute pull-request content run with read-only permissions and without secrets. Write permissions exist only in the scheduled, manual, and release workflows. | Confirmed |
| Q-06 | Evidence: every failed level D run keeps the setup log, the Error Log, and screenshots. | Confirmed |
| Q-07 | Repeatability: the version of the console installer is fixed in the test configuration; the fixture is fixed by the commit under test. | Confirmed |
| Q-08 | Cost: the repository is public; no budget limit was stated. | Not discussed |

Deployment and support: the testbed lives in this repository and runs on
GitHub-hosted machines. Availability targets, backup, and privacy obligations
are not applicable; the testbed processes no personal data and holds no state
besides caches.

## 9. Licensing and compatibility

The testbed is repository tooling. It is not a separately distributed product.
The outbound license for testbed code, the fixture, and documents is the
repository's existing EPL-2.0, as confirmed by the maintainer (A-03).

| Component and version | License and exceptions | Intended use and boundary | Proposed outbound license | Assessment | Obligations, evidence, open action |
|---|---|---|---|---|---|
| This repository | EPL-2.0 (`LICENSE`) | Host of the testbed code | EPL-2.0 | Compatible | – |
| klibio console installer 1.0.8 | EPL-2.0 (R-01) | Downloaded and executed at test time; not modified, not redistributed | EPL-2.0 | Compatible | If the fallback of D-09 modifies the fork, that happens in the fork under its own license. |
| Eclipse Oomph | EPL-2.0 (R-06) | Executed; the extension links against it | EPL-2.0 | Compatible | – |
| SWTBot | Not verified in this interview | Test library, executed inside the installed Eclipse | EPL-2.0 | Unknown | Verify the license text before use. |
| bnd command line | Not verified in this interview | Executed by the release script and possibly by the extension | EPL-2.0 | Unknown | Verify the license text before use. |
| Small fixture workspace | Newly written, EPL-2.0 | Stored in this repository | EPL-2.0 | Compatible | Write it new. Do not copy content from `klibio/example.bnd.rcp`, which has no license file (R-07, FX-3). Verify the terms of any template content that the bnd tooling generates into it. |
| Test results, logs, screenshots | – | Stored as run artifacts | – | Not applicable | – |

No dataset, model, or media licensing is involved. These notes are planning
guidance, not legal advice.

## 10. First-level divide-and-conquer realization plan

| ID and outcome | Scope and linked requirements | Prerequisites and dependencies | Main approach and tangible deliverable | Completion evidence | Principal risks or unknowns |
|---|---|---|---|---|---|
| **W-01: It is known whether the chosen engine works and how long it takes.** | Feasibility experiment for D-09. Covers one Configuration (`50r`) end to end on three systems. No permanent test code. | None. Starts first. | Run the console installer 1.0.8 against local `site/` and `setup/` through redirection, bind variables, start the installation once, observe STARTUP. Deliverable: a short findings note with measured times, a go or fallback statement for D-09, and confirmation that project import needs committed Eclipse project files (shapes the fixture, FX-1). | Recorded runs on Linux, Windows, macOS; measured durations; list of what did not work. | Oomph 1.28.0 against current models (RISK-01); macOS on Apple processors (RISK-02); behavior at first start (RISK-03). |
| **W-02: Every pull request gets static verification.** | REQ-01, REQ-02, REQ-03, REQ-15, P-02. Excludes anything that installs. | None. Parallel to W-01. | Pull-request workflow; consistency scripts made independent of symbolic-link support; structure check for all releases; completeness checks from the release skill. | A pull request with a deliberately wrong release choice fails; a correct one passes on Linux and Windows. | F-06 may require script changes. |
| **W-03: Offered releases are proven installable.** | REQ-04. | W-02 for the workflow frame. Parallel to W-01. | p2 director installs the bndtools features from the local site into a fresh Eclipse. | Install succeeds for `latest`; a release with a removed artifact fails. | Old offered releases (6.4.1, 7.0.0) may not install into a current Eclipse; the base Eclipse per release must be chosen (OQ-05). |
| **W-04: One entry point serves sandbox and automation.** | REQ-09, REQ-10, REQ-17, REQ-18. | W-01 result. | Script that serves the site with a working `latest` alias, applies redirections, isolates user home, and starts the console or normal installer; container image with the same tools; the small fixture workspace. | The maintainer performs J-2 on Windows; own Eclipse settings are unchanged afterwards. The fixture builds with the bnd command line. | Network restrictions on developer machines (RISK-06); fixture ageing (RISK-07). |
| **W-05: All Configurations reach level A.** | REQ-05. | W-04. | Matrix over 15 Configurations and three systems using the entry point; variable values per Configuration stored with the tests. | Matrix green; a Configuration with a removed default fails with the variable's name. | Run time on three systems (RISK-04). |
| **W-06: The representative set reaches level D.** | REQ-06, REQ-08, Q-06. | W-05; fixture from W-04. | First start with display, evaluation of the setup log, SWTBot checks installed into the provisioned Eclipse. | All checks of REQ-08 pass for `50r`, `51r`, `64r` on three systems; a seeded error is detected. | Unstable UI tests; how SWTBot gets into the provisioned Eclipse (A-02). |
| **W-07: The extension behaves as intended and stays that way.** | REQ-11, REQ-12. X1 and X2 can start early; X3 needs W-06. | W-02 for X1 and X2; W-06 for X3. | Write the X3 test as specification, then change the task from wizard to workspace creation; align `README.md` and `dev.md`; remove or activate the nested workflow (F-13). | X1 to X3 pass; no dialog appears. | How the task obtains bnd functionality at BOOTSTRAP or STARTUP (OQ-04). |
| **W-08: A release is one workflow start.** | REQ-13, REQ-14, P-04. | W-02 (checks), W-03 (install test). | Release script; manually started workflow that opens the pull request. | Dry run for an existing version changes nothing; a run for a new version yields a pull request that passes the PR gate. | Commit identity and signature (OQ-02). |
| **W-09: The full matrix runs on schedule and failures are tracked.** | REQ-07, REQ-16, P-03. | W-05, W-06. | Scheduled and manually startable workflow; tracking issue handling. | A forced failure opens the issue; the next green run closes it. | Interval (OQ-06); outside breakage in F3 and snapshot variants. |

**Starting workstream.** W-01 comes first, because decisions D-03, D-08, and
D-09 all rest on an engine that has not yet been shown to work with the current
setup models on three systems, and because the open time limit (OQ-01) can only
be decided with its measurements. W-02 and W-03 do not depend on it and can run
in parallel.

## 11. Risks, assumptions, and open questions

### Risks

| ID | Risk | Impact | Owner | Checkpoint |
|---|---|---|---|---|
| RISK-01 | The console installer 1.0.8 is built on Oomph 1.28.0 and Eclipse 2022-12. It may not handle the current product catalog or the Java 21 and 25 tasks. | Fallback E2: work in another repository before W-04 can proceed. | Unassigned | End of W-01 |
| RISK-02 | GitHub's current macOS machines use Apple processors; a console installer build for them was not verified. | macOS on pull requests (D-08) may be impossible without the fallback. | Unassigned | End of W-01 |
| RISK-03 | STARTUP tasks run inside the installed Eclipse. Whether they complete unattended after a console installation is unverified. | Level D may need additional handling at first start. | Unassigned | End of W-01 |
| RISK-04 | Three systems, level A for 15 Configurations, and level D for three on every pull request, without path-based selection. | Long feedback; contributors may bypass the gate. | Maintainer | After W-05 measurements |
| RISK-05 | The cache hides outside breakage. | A pull request passes although a fresh user installation would fail. | Unassigned | OQ-03 |
| RISK-06 | From the machine used for this interview, `bndtools.org` and Maven Central were not reachable with `curl`, while GitHub was. | The local sandbox may need proxy configuration on such machines. | Maintainer | W-04 |
| RISK-07 | The stored fixture ages: a new bnd release may no longer build it without errors, or may expect a different workspace layout. | F2 at level D fails for a reason outside the pull request. The release pull request is the place where it shows. | Unassigned | Each release (W-08) |
| RISK-10 | For `52` the fixture sits nested inside this repository, and cloning this repository is large because it contains all release artifacts. | `52` is slow and differs from a typical user repository with the workspace at the root. It runs on schedule only. | Unassigned | W-09 |
| RISK-08 | The preference check (g) and the Error Log check (d) are sensitive to unrelated changes in Eclipse releases, because the setups install the latest released Eclipse. | Failures unrelated to the pull request. | Unassigned | W-06 |
| RISK-09 | An outside outage on a cache miss turns pull requests red on all three systems. | Blocked merges without a fault in the pull request. | Accepted with D-10 | – |

### Assumptions

| ID | Assumption | State and resolution |
|---|---|---|
| A-01 | Variables of every Configuration can be bound from outside so that no prompt appears. | Unconfirmed; W-01 |
| A-02 | SWTBot and the test code can be installed into the provisioned Eclipse after the setup ran, without changing what is under test. | Unconfirmed; W-06 |
| A-03 | Testbed code is licensed like the repository, EPL-2.0. | Confirmed by the maintainer |
| A-04 | "Eclipse shows it as a bnd workspace" (REQ-12) is observable through the Bnd Repositories view and the presence of the `cnf` project. | Confirmed by the maintainer |

### Open questions

None of these blocks the start of W-01, W-02, or W-03. The maintainer accepted
them as open with the approval.

| ID | Question | Impact | Owner | Checkpoint |
|---|---|---|---|---|
| OQ-01 | What is the longest acceptable wait for a pull-request result? | May force a smaller pull-request tier. | Maintainer | After W-01 and W-05 |
| OQ-02 | Resolved by P-04: the person who starts the release workflow is the author; the commit is created through the GitHub interface that yields a verified signature. Whether that technique works for this case is verified in W-08. | – | Maintainer | W-08 |
| OQ-03 | When is the cache renewed? | RISK-05. | Maintainer | W-04 |
| OQ-04 | Which bnd functionality does the task use to create the workspace, and with which template content? | Blocks the code part of W-07. | Maintainer | Before W-07 |
| OQ-05 | Into which Eclipse version is each offered release installed for the install test? | Old releases may need an older Eclipse. | Maintainer | W-03 |
| OQ-06 | How often does the scheduled run happen? | Delay until F3, F5, F6 breakage is seen. | Maintainer | W-09 |
| OQ-07 | Resolved: P-01 to P-04 and Q-05 to Q-07 are accepted. | – | – | – |
| OQ-08 | Where do the test code and the fixture folder live in the repository? | Layout only. | Maintainer | W-02, W-04 |

## 12. References

All sources accessed on 2026-11-13.

| ID | Source | Location | Version | Supports |
|---|---|---|---|---|
| R-01 | klibio, eclipse-oomph-console | `https://github.com/klibio/eclipse-oomph-console` | Branch `main`, last push 2024-04-12 | Headless installer, settings, redirections, fork relation, EPL-2.0, target platform Oomph 1.28.0 |
| R-02 | a-langer, eclipse-oomph-console | `https://github.com/a-langer/eclipse-oomph-console` | Release 1.0.4 | Upstream of R-01 |
| R-03 | Maven Central, `io.klib.tools:org.eclipse.oomph.console.product` | `https://repo1.maven.org/maven2/io/klib/tools/org.eclipse.oomph.console.product/maven-metadata.xml` | 1.0.8, updated 2024-04-12 | Published version of the console installer |
| R-04 | Maven Central, `com.github.a-langer:org.eclipse.oomph.console.product` | `https://repo1.maven.org/maven2/com/github/a-langer/org.eclipse.oomph.console.product/maven-metadata.xml` | 1.0.0 to 1.0.4 | Upstream versions |
| R-05 | klibio console installer sources | `org.eclipse.oomph.console/src/.../ConsoleInstaller.java`, `org.eclipse.oomph.console.core/src/.../Parameters.java` in R-01 | Branch `main` | Selectable trigger, optional launch, handling of unresolved variables |
| R-06 | Eclipse Oomph | `https://github.com/eclipse-oomph/oomph`, file `plugins/org.eclipse.oomph.setup.projects/src/org/eclipse/oomph/setup/projects/impl/ProjectsImportTaskImpl.java` | Branch `master` | Project import uses the Eclipse project factory; EPL-2.0 |
| R-07 | klibio, example.bnd.rcp | `https://github.com/klibio/example.bnd.rcp` | Commit `6eb3b027e716267696cee1c3c14e6956452530a9` | Findings FX-1 to FX-8 for the fixture considered first |
| R-08 | Repository files | Paths named in section 3.2 | Working tree of 2026-11-13, branch `update-bnd-7.5.0` at `44370c4` | Current situation |
| R-09 | Deployed site | `https://bndtools.org/bndtools.p2.repo/latest/p2.index`, `https://bndtools.org/bndtools.p2.repo/oomph-bndtools-import-task/p2.index` | 2026-11-13 | `latest` alias and extension site are published |

A search of the Eclipse Oomph authoring wiki for redirection and headless
operation returned no content during the interview; statements about
redirection rest on R-01 only.

## 13. Agreement record

| Item | State |
|---|---|
| Decisions D-01 to D-19 | Given by the maintainer during the interview on 2026-11-13. D-10 was corrected by the maintainer from N1 to N2. D-16 was changed by the maintainer from an outside repository to a small own fixture; D-19 was added and confirmed afterwards. |
| Revision 1 | Reviewed and approved by the maintainer on 2026-11-13 (shared understanding, scope, first-level plan), with one correction: small own fixture. |
| Revision 2 (this document) | Contains that correction, confirmed by the maintainer through D-19 on 2026-11-13. **Approved.** |
| Proposals P-01 to P-04, Q-05 to Q-07, assumptions A-03 and A-04 | Accepted by the maintainer on 2026-11-13. |
| Assumptions A-01 and A-02 | Unconfirmed technical assumptions; resolved by W-01 and W-06. |
| Accepted limitations | Old releases without install test (D-06); F3, F5, F6, `52`, and snapshot variants at level D only on schedule (D-05, P-01); cache may hide outside breakage (D-10); no time limit yet (OQ-01); open questions OQ-01, OQ-03 to OQ-06, OQ-08. |
| Requires renewed agreement if changed | The meaning of level D, the representative set, the operating systems on pull requests, the engine, the intended behavior of the extension, and the release trigger. |
