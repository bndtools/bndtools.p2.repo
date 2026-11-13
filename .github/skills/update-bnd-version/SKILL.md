---
name: update-bnd-version
description: End-to-end workflow for adding a new bnd/bndtools release to this repository, including p2 site import, Oomph setup updates, documentation updates, and validation.
---

# Update bnd/bndtools Release Skill

Use this skill when the user asks to add a new bnd/bndtools release to this repository.

## Inputs to collect first

- Release version, for example `7.3.0`.
- Source artifact URL, for example `https://bndtools.jfrog.io/artifactory/update-latest/org/bndtools/org.bndtools.p2/<version>/org.bndtools.p2-<version>.jar`.
- Oomph defaults (`value` and `defaultValue`) point at the `latest` alias (`https://bndtools.org/bndtools.p2.repo/latest`, which follows `site/latest`) and normally need no change per release; only change them if the user explicitly asks to pin a version.

## Repository areas involved

- Site release content: `site/<version>/`
- Site release pointers/listing: `site/latest`, `site/p2.html`
- User-facing docs: `README.md`, `site/index.md`
- Oomph setups: `setup/**/*.setup`

## Step-by-step procedure

1. Verify current workspace state.

- Run `git status --short`.
- Do not revert unrelated user changes.

2. Create and populate the new release folder.

- Create `site/<version>/`.
- Download the jar to `site/<version>/org.bndtools.p2-<version>.jar`.
- Extract the jar into the same folder.

Recommended commands:

```bash
mkdir -p site/<version>
curl -fL "<artifact-url>" -o "site/<version>/org.bndtools.p2-<version>.jar"
cd site/<version>
unzip -oq "org.bndtools.p2-<version>.jar"
```

3. Ensure expanded metadata and human-readable index exist.

- `content.xml` must exist in `site/<version>/`.
- `index.html` must list features and plugins in the style of previous releases.

Preferred path:

- Run `processing/human-readable-index.sh` (requires `xsltproc`).

Fallback when `xsltproc` is unavailable:

- Extract `content.jar` to materialize `content.xml`.
- Generate `index.html` from `content.xml` entries for:
  - `provided namespace="org.eclipse.update.feature"`
  - `provided namespace="osgi.bundle"`

4. Update site pointers/listing.

- Set `site/latest` to `<version>`.
- Add `<version>` entry to `site/p2.html`.

5. Update documentation references.

- Update the direct p2 example in `README.md` to current release.
- Update release wiki links in `site/index.md` if they reference older release pages.

6. Update Oomph setup choices.

- Update all `setupTask` blocks with `id="bndtools-release"`.
- Each `bndtools-release` task's `value` and `defaultValue` (whichever are present) must be `https://bndtools.org/bndtools.p2.repo/latest`; do not pin them to `<version>` unless the user asks.
- Keep a `rel latest` choice (`.../latest`) as the first choice, above the newest `rel <version>` choice.
- Only change the task attributes, never the `value` of `<choice>` entries (those are followed by `label="rel ..."`).
- Ensure choices include the maintained release set from latest to baseline.

Current policy baseline:

- `rel 7.5.0`
- `rel 7.4.0`
- `rel 7.3.0`
- `rel 7.2.3`
- `rel 7.1.0`
- `rel 7.0.0`
- `rel 6.4.1`
- `release (JFrog)`
- `snapshot (JFrog)`

If present in a file, preserve additional advanced choices:

- `SelectPullRequest` using `https://bndtools.jfrog.io/artifactory/p2/pr/${pullrequest}/`
- `RepoURL` using `${pr.repo.uri}`

7. Validate Oomph consistency.

- Every file containing `id="bndtools-release"` has the expected release choices.
- No malformed placeholder substitutions, especially `${pullrequest}`.
- XML structure remains valid.

Useful checks:

```bash
grep -RIn "id=\"bndtools-release\"" setup
grep -RIn "https://bndtools.org/bndtools.p2.repo/<version>" setup
grep -RIn "artifactory/p2/pr/\$\{pullrequest\}" setup
```

8. Final verification and report.

- Run `git status --short` and review changed files.
- Run diagnostics (`get_errors`) to catch syntax issues.
- Summarize:
  - what was changed,
  - that defaults stay on the `latest` alias,
  - any manual follow-up (for example, if `xsltproc` was missing).

## Common pitfalls

- Pinning `value`/`defaultValue` of `bndtools-release` to a version instead of `latest` (or dropping the `rel latest` choice).
- Accidentally rewriting `<choice value=...>` entries while updating defaults.
- Dropping `SelectPullRequest` or `RepoURL` choices from setups that support PR/repo override flows.
- Corrupting `${pullrequest}` into a literal empty path.
- Updating `site/latest` without adding the release to `site/p2.html`.
- Adding release files but forgetting to generate a readable `index.html`.

## Definition of done

- New release exists under `site/<version>/` with p2 artifacts plus `content.xml` and `index.html`.
- `site/latest` and `site/p2.html` reference the new release.
- Oomph setup files have consistent release choices and defaults pointing at `latest` unless requested otherwise.
- Documentation references are aligned with the new release.
- No validation errors remain.
