# 04-web-export: Lite feature

| | |
|---|---|
| System / Owner | Integration / John |
| Branch | `integration/04-web-export` |
| Agent / Date | Codex / 2026-10-09 |
| Milestone | Final |

## 1. Brainstorm

Goal: Configure a single-threaded Godot Web export that can be deployed at `https://gamedevrocky.github.io/project-3/`.

- **Q:** Which build target should the project expose? **A:** A runnable `Web` release preset whose entry point is `builds/web/index.html`.
- **Q:** How should browser compatibility be handled? **A:** Keep the Compatibility renderer and disable web thread support so GitHub Pages does not need cross-origin-isolation headers.

## 2. Spec

- **Behavior:** The Godot editor and command line offer a runnable `Web` export preset that produces the files GitHub Pages expects beneath `builds/web/`.
- **Numbers:** 1280x720 viewport and Compatibility renderer remain unchanged from `project.godot`; web threading is disabled.
- **Uses:** No gameplay contracts or shared types.
- **Files:** `export_presets.cfg`, `docs/features/integration/04-web-export/FEATURE-lite.md`, and the Integration section of `docs/PROGRESS.md`.
- **Edge cases:** The exported game must use relative companion-file paths so hosting below `/project-3/` works; generated build output remains ignored by Git.
- **Out of scope:** GitHub Actions, Pages source configuration, custom domains, and committing generated web artifacts.

**Done when:**
- [x] A runnable `Web` preset exports to `builds/web/index.html`.
- [x] Thread support is disabled for GitHub Pages compatibility.
- [ ] A release export completes with Godot 4.7.2.
- [ ] Full GUT suite passes headless with no `SCRIPT ERROR` and the expected script count.
- [ ] The exported build is checked in a browser after deployment.

## 3. Plan

1. Add the Godot Web export preset with GitHub Pages-safe browser settings -> test: inspect the recognized preset and perform a release export.
2. Run the complete project verification -> test: full headless GUT suite, then inspect its script count and errors.
3. Pull `origin/main`, merge the feature to `main`, and push the requested configuration.

## 4. Checklist

- [x] Branch created from a fresh `main`; `PROGRESS.md` updated.
- [x] Step 1 configuration added.
- [ ] Step 1 release export verified.
- [ ] Step 2 full suite verified.
- [ ] Step 3 pulled `main`, merged, and pushed.
- [ ] Browser deployment check (requires the separate GitHub Pages publishing setup).
