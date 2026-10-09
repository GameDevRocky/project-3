# Portrait System — Brainstorm

## Problem
The starter repository has no portrait implementation or shared GDScript types yet. The game needs reusable wall paintings and a portable final family portrait that own cover, activity, occupancy, and carry state, with visible feedback for each transition.

## Design grounded in the contracts
- Follow `docs/CONTRACTS.md` §2.2 signal names and public methods exactly.
- Ghost chooses movement; the Portrait System only validates entry and owns occupancy.
- Covered, inactive, occupied, and carried paintings cannot accept monster entry.
- The final portrait remains occupied while carried; ending logic can inspect it.
- Lighting state remains with Electrical. Portraits show an occupied/trapped effect but do not query or own room lighting.
- Player calls interaction hooks; no player controller or hardcoded teammate references.

## Scope
Reusable 3D painting component, registry/manager, portable family portrait hooks, procedural materials and haunted visual, standalone demo, focused tests, and teammate-facing documentation. No edits to contracts, shared, player, ghost, electrical, core, or the main project configuration.

## Implementation note
The starter has no `systems/shared/` implementation or root `project.godot`. A portrait-owned `PaintingData` resource will mirror the approved contract fields and integer room IDs for standalone use. The integration handoff will call out migration to the shared `PaintingData` and `GameTypes.RoomId` once foundation files are added.

## Approval
The detailed user request is treated as approval of this scope and behavior.
