# 05-pages-deploy: Lite feature

| | |
|---|---|
| System / Owner | Integration / John |
| Branch | `integration/05-pages-deploy` |
| Agent / Date | Codex / 2026-10-15 |
| Milestone | Final |
| Status | Approved by user request on 2026-10-15 |

## 1. Brainstorm

Goal: Replace the repository-root Jekyll deployment with an automated Godot 4.7.2 Web export published to GitHub Pages.

- **Q:** How should generated web files reach Pages without committing `builds/`? **A:** Build them in GitHub Actions and publish a Pages artifact. This preserves the repository's generated-file policy and avoids a long-lived `gh-pages` branch.
- **Q:** When should deployment happen? **A:** Pull requests build, test, and export for validation; only pushes to `main` deploy.
- **Q:** Which engine source should CI use? **A:** The official Godot 4.7.2 Linux editor and export templates from `godotengine/godot-builds`, verified with fixed SHA-256 digests.

## 2. Spec

- **Behavior:** A workflow imports the project, runs the full GUT suite, creates the single-threaded Web export at `builds/web/index.html`, uploads that directory as a Pages artifact, and deploys it after changes reach `main`.
- **Uses:** Existing `Web` preset in `export_presets.cfg`; no gameplay contract changes.
- **Files:** `.github/workflows/deploy-pages.yml`, this Lite feature file, and the Integration section of `docs/PROGRESS.md`.
- **Safety:** Pull-request runs never deploy. The workflow fails on a nonzero GUT result, any `SCRIPT ERROR`, a missing GUT script count, a skipped test script, a failed export, or missing web output.
- **Hosting:** Add `.nojekyll` to the generated artifact. Keep Web thread and extension support disabled so GitHub Pages requires no cross-origin-isolation headers.
- **Verification defect found:** The previously skipped ghost test referenced a nonexistent shared resource and the ghost read `portrait_id` instead of the frozen `PaintingData.id` field. Use the integrated portrait resource in the test, instantiate the complete ghost scene, and align the ghost lookup with `id` so all test scripts actually execute.
- **Out of scope:** Custom domains, PWA/offline support, multithreaded Web exports, and committing generated builds.

**Done when:**
- [x] Pull-request CI imports, tests, and exports with Godot 4.7.2.
- [x] The reported GUT script count matches the number of `test_*.gd` files.
- [x] GitHub Pages uses the Actions publishing source.
- [ ] A `main` workflow run deploys successfully.
- [ ] `https://gamedevrocky.github.io/project-3/` loads the Godot game rather than the repository README.

## 3. Plan

1. Add the Pages workflow and validate its YAML and referenced release assets.
2. Update Integration progress notes and run repository checks available locally.
3. Commit, push, and open a PR into `main`.
4. Use the PR workflow to validate Godot import, the complete GUT suite, and Web export.
5. Merge only after CI succeeds, switch Pages to the Actions source, and verify the deployed game URL.

## 4. Checklist

- [x] Branch created from current `main`.
- [x] Lite spec approved.
- [x] Workflow implemented.
- [x] Local static checks pass.
- [x] PR workflow passes.
- [ ] PR merged into `main`.
- [ ] Pages deployment verified in a browser.
