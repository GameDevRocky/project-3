# The Last Portrait (COMP 440 Project 3)

A 3D psychological horror and puzzle game built in Godot 4.7.2 by Haliyah (Portraits), Rocky (Electrical), Daniel (Player), and John (Ghost / Integration). The concept synthesizes the team's collaborative ideas into a cohesive four-system architecture.

The player visits their old family home on the eve of new rental tenants moving in to pack and carry the last four room-labeled moving boxes out to their car. Unbeknownst to them, the house is haunted by an entity that moves freely through darkness and takes refuge inside oil paintings when exposed to light. To survive, the player must manipulate room lighting and portrait covers within a 100-watt power grid, navigate unlit rooms with a faint dark-adaptation glow, and retrieve the heirloom family portrait by the front door without letting the monster enter it or kill them.

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
| **Portrait / Painting system** | Haliyah | `systems/portraits/` | Portrait location, room ID, covered/uncovered, active/inactive, family portrait tracking, monster occupancy (`is_occupied`) |
| **Electrical & Lighting** | Rocky | `systems/electrical/` | Circuits, room light states, breaker state, bulb condition, 100W power grid budget |
| **Player System** | Daniel | `systems/player/` | Locomotion, first-person camera, carried items (boxes/sheet/portrait), dark-adaptation glow, switch interaction, death loop |
| **Ghost / Monster System** | John | `systems/ghost/` | Ghost location, state, chase state, movement mode, target, occupied portrait ID, lethal contact |
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
