# COMP 440 Project 3 (Working Title)

A 3D psychological horror and puzzle game built in Godot 4.7.2 by Haliyah (Portraits), Rocky (Electrical), Daniel (Environmental Clues), and John (Ghost / Integration). The concept synthesizes the team's collaborative ideas into a cohesive four-system architecture.

The player investigates an eerie house haunted by an entity that moves freely through darkness and takes refuge inside oil paintings when exposed to light. To survive, the player must manipulate room lighting and portrait covers, decipher environmental clues, and navigate an inescapable truth: the entity can only leave the house if carried out inside the central family portrait.

**Deadlines:**
- **Game Design Document:** Wed 2026-10-07
- **Playtest (Working Slice):** Fri 2026-10-09
- **Final Game:** Fri 2026-10-16 (Code freeze Thu 2026-10-15 night)

---

## Start Here

| Document | Purpose |
|---|---|
| [docs/GAME_SPEC.md](docs/GAME_SPEC.md) | Game design specification: narrative, systems, monster rules, scariest moment, and tuning |
| [docs/CONTRACTS.md](docs/CONTRACTS.md) | The typed interfaces and seams between the four systems |
| [docs/TEAM.md](docs/TEAM.md) | System ownership, boundaries, review pairs, and collaboration rules |
| [docs/WORKFLOW.md](docs/WORKFLOW.md) | Spec-driven development cycle (`branch → spec → plan → todo → build → PR`) with prompts |
| [docs/PROGRESS.md](docs/PROGRESS.md) | Active progress tracker and inter-agent handoff notes |
| [docs/TODO.md](docs/TODO.md) | The project backlog by milestone and owner |
| [docs/TECH_STACK.md](docs/TECH_STACK.md) | Engine settings, GDScript standards, headless GUT testing, and web export |
| [docs/DECISIONS.md](docs/DECISIONS.md) | Architecture log recording decisions, proposals, and rationales |
| [docs/ASSETS.md](docs/ASSETS.md) | Manifest of 3D meshes, textures, materials, and audio files |

**AI Agents:** [`AGENTS.md`](AGENTS.md) is the canonical instruction file for all AI agents. [`GEMINI.md`](GEMINI.md) and [`CLAUDE.md`](CLAUDE.md) import it.

---

## System Ownership

| System | Owner | Folder | Owned State |
|---|---|---|---|
| **Portrait / Painting system** | Hali | `systems/portraits/` | Portrait location, covered/uncovered, turned/moved, active/inactive |
| **Electrical & Lighting** | Rocky | `systems/electrical/` | Circuits, room light states, breaker state, bulb condition |
| **Environmental Clues** | Daniel | `systems/environment/` | Physical disturbances, audio cues, clue intensity/location, triggered evidence |
| **Ghost / Monster System** | John | `systems/ghost/` | Ghost location, state, chase state, movement mode, target |
| **Integration & Core** | John | `systems/core/` | `main.tscn`, `project.godot`, export presets, input mapping |
| **Shared Contracts** | Joint | `systems/shared/` | Data transfer objects, enums, seam signatures |

---

## Shared Setup

- **Engine:** Godot 4.7.2 stable (standard build with GDScript).
- **Renderer:** Compatibility renderer (`gl_compatibility`).
- **Web Export:** Configured with threading disabled for maximum browser compatibility.

### Quick Start
1. Clone the repository.
2. Open Godot 4.7.2 and import the project.
3. To run headless unit tests (via GUT):
   ```bash
   godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
   ```
4. Follow the workflow in [`docs/WORKFLOW.md`](docs/WORKFLOW.md) before writing any code.
