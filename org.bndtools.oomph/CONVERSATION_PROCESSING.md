# Processed Conversation: Bndtools vs Eclipse Import in Oomph

Date processed: 2026-06-17
Source: Copilot share `HanwpdWbocoDKQ2TZQkG8`

## 1. What the conversation established

- `Existing Bnd Workspace` (Bndtools import) is different from Eclipse `Existing Projects into Workspace`.
- Bndtools import understands Bnd workspace semantics (`cnf/`, workspace repos, run configs, Bnd containers).
- Standard Eclipse import only consumes `.project`/`.classpath` and does not initialize Bnd workspace behavior.
- Oomph does not provide a built-in task that directly maps to the Bndtools wizard.

## 2. Paths discussed in the conversation

### Path A: Workaround (recommended practical baseline)

- Oomph materializes repository via Git.
- Oomph executes command task: `bnd workspace init`.
- Eclipse/Bndtools then sees initialized metadata.

### Path B: Custom Oomph extension plugin

- Add custom setup task type using namespace prefix `org.bndtools`.
- Implement task class that performs Bnd workspace initialization.
- Build and distribute via Tycho + Feature + Update Site.

## 3. Artifacts repeatedly requested/generated in the conversation

- Plugin: `org.bndtools.oomph.import`
- Feature: `org.bndtools.oomph.import.feature`
- Update site: `org.bndtools.oomph.import.site`
- Parent Maven/Tycho build in repository root.

## 4. Important caveats before implementation

- Some code shown in the conversation is conceptual and may require adaptation to current Oomph/Bndtools APIs.
- Oomph custom setup tasks commonly rely on generated model + implementation classes; extending `SetupTask` directly may not be enough in real builds.
- Extension-point details should be validated against your target Oomph version.
- Target platform repositories and IUs should be pinned to known-good versions for reproducible CI.

## 5. Clean implementation strategy (recommended)

1. Start with Path A (`bnd workspace init` command task) to verify behavior quickly.
2. If full automation is still needed, implement Path B as a separate plugin with:
   - explicit target platform
   - integration test workspace
   - CI Tycho build
3. Publish as p2 update site and consume in Oomph setup model.

## 6. Minimal acceptance criteria

- A fresh workspace setup ends with a valid Bnd workspace (no manual import wizard use).
- `cnf/` and projects are recognized by Bndtools after setup.
- Setup can be rerun idempotently.
- Tycho build produces installable p2 repository.

## 7. Suggested next concrete step in this workspace

- If you want, generate the full multi-module repository now in this folder:
  - root parent pom
  - plugin module
  - feature module
  - update-site module
  - target platform definition
  - CI workflow

Reply with: `generate the project now` and I will create all files directly here.
