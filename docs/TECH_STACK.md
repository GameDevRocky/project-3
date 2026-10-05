# Tools and Technology Stack

Everything the team and AI agents use to build Project 3.

## Engine and Language

| Item | Choice | Notes |
|---|---|---|
| Engine | **Godot 4.7.2 stable, standard build** | Pinned in `.godot-version`. Not .NET/C#. Any version change requires unanimous team sign-off in `DECISIONS.md`. |
| Language | **GDScript**, statically typed | Strictly typed variables, parameters, and returns (`var light_state: GameTypes.LightState`, `func is_lit() -> bool`). |
| Renderer | **Compatibility** (`gl_compatibility`) | Web target compatible. No heavy Forward+ features (no SDFGI, no volumetric fog). Keep dynamic lights disciplined. |
| Physics | Godot 3D Physics (Default) | Collision layers configured in `project.godot`. |
| Audio | Built-in Godot AudioServer | Positional `AudioStreamPlayer3D` for footsteps, disturbances, and environmental stingers. |
| Test Framework | **GUT (Godot Unit Test)** | Runs headless in CI and local terminal. |

---

## Godot 4 vs Godot 3 (Critical Agent Pitfalls)

Do NOT use legacy Godot 3 patterns. In Godot 4:
- Use `@export`, `@onready` (not `export`, `onready`).
- Use `await signal_name` or `await get_tree().process_frame` (not `yield`).
- Use `CharacterBody3D` (not `KinematicBody` or `KinematicBody3D`). Built-in `velocity` property is modified directly, followed by `move_and_slide()`.
- Use `signal_name.connect(callable)` and `signal_name.emit(args)` (not `connect("name", obj, "method")` / `emit_signal`).
- Use `Node3D` (not `Spatial`).
- Use `instantiate()` (not `instance()`).

---

## Headless GUT Test Execution

Run the headless suite from the project root:

```bash
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

On Linux / WSL: ensure `godot` is in `$PATH` or symlinked to `/usr/local/bin/godot`.
On macOS: `/Applications/Godot.app/Contents/MacOS/Godot`.
On Windows: `godot.exe` or alias in PowerShell / bash.

**Test parsing note:** A GDScript test file with a syntax or parse error is silently skipped by GUT. Always verify that the reported `Scripts` count matches the actual number of test files, and that no `SCRIPT ERROR` appears in console output.

---

## Web Export

- Web preset in `export_presets.cfg`, output to `builds/web/index.html`.
- Threading disabled (`variant/thread_support=false`) for broad browser compatibility.
- Audio playback starts only following initial player user interaction (browser security policy requirement).
- Test locally using a lightweight server:
  ```bash
  cd builds/web && python3 -m http.server 8000
  ```
