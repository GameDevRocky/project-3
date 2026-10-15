# 02-visible-paintings: Plan

| | |
|---|---|
| System / Owner | Portraits / Haliyah |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## 1. Blueprint

- Add tests that load the actual main scene and check room counts, unique IDs, startup state, basement eligibility, and family portrait presence.
- Add an occupancy test using GhostMonster's current enter/exit interface; inspect that the canvas texture is rendered from the same capsule mesh as GhostMonster.
- Add seven painting scene instances in a Portrait System-owned house layout scene, loaded only under the integrated house root, with transforms that avoid doors, furniture, the breaker panel, and the basement pipe.
- Add a transparent SubViewport per painting, disabled while empty. On occupancy, render the existing ghost capsule once and composite its texture through the canvas paint shader.
- Run portrait tests, the complete GUT suite, Godot import/parse validation, and an actual-house visual check.

## 2. Iterations and steps

### Iteration 1: Coverage and registration

- **Step 1.1:** Add main-scene tests for 13 unique, registered, initially uncovered/active paintings and the basement refuge.
- **Step 1.2:** Add seven paintings to a Portrait System-owned house scene, loaded under the integrated house root, and confirm tests see the added counts without editing main.tscn.

### Iteration 2: Occupied canvas representation

- **Step 2.1:** Test that the occupied canvas has a SubViewportTexture sourced from the GhostMonster capsule mesh.
- **Step 2.2:** Add the portrait-local render target and composite its silhouette into the existing canvas shader.
- **Step 2.3:** Test exit/entry transfer, cover/uncover eligibility, and no persistent duplicates.

### Iteration 3: Integrated verification

- **Step 3.1:** Run portrait tests and full GUT; check all scripts were discovered and no script errors occurred.
- **Step 3.2:** Import/parse with Godot 4.7.2, run the main house, exercise a basement entry and a second painting, inspect the rendered canvas, and record remaining integration issues.

## 3. Prompts

Follow the steps in order: test first, implement only the Portrait System, run the requested validations, update the Portrait System progress handoff, and report results. Do not change GhostMonster movement or the Integration-owned main scene.
