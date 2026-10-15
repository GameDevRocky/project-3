# 02-visible-paintings: Brainstorm

| | |
|---|---|
| System | Portraits |
| Owner | Haliyah |
| Branch | portraits/02-visible-paintings |
| Agent | Codex |
| Date | 2026-10-15 |
| Milestone | Final |

## Goal

Give the monster several registered, reachable painting refuges in every interior room, including the basement where it starts. When the Ghost System reports an occupied painting, render the same capsule mesh used by the live ghost as part of the canvas artwork so players can recognize its physical silhouette.

## Grounding

- GAME_SPEC.md §3: the entry hall, parlor, study, dining room, and basement are distinct playable rooms.
- GAME_SPEC.md §5, Seam 3: the Portrait System renders the monster inside an occupied canvas.
- GAME_SPEC.md §5, Seam 4 and §6: the monster can enter only active, uncovered paintings; covering paintings remains a discovery mechanic.
- CONTRACTS.md §2.2: the Ghost System sets painting occupancy through the Portrait System; the Portrait System owns registration, eligibility, and canvas state.

## Q&A

1. **Q:** Which visual source should the canvas use?
   **A:** The CapsuleMesh from GhostMonster's existing ShadowMesh, rendered to a transparent SubViewport texture and composited into the painting shader. This keeps the in-canvas figure matched to John's actual monster without placing a 3D actor in front of the frame.

## Decisions

- Add wall paintings as children of the PortraitSystem scene. Correct all initial painting facings toward their assigned room from the Portrait System, leaving the Integration-owned main house scene unchanged.
- Add one entry hall painting, one parlor painting, two study paintings, one dining room painting, and two basement paintings. The existing family portrait and five ordinary paintings remain in place.
- Give every added painting a unique ID, the correct GameTypes.RoomId value, and explicit uncovered/active startup state.
- Create a canvas-local render of the existing ghost capsule only when the painting is occupied. Keep the existing oil painting, brush distortion, and transition tween.
- Keep occupancy controlled by the existing PortraitSystem API. Do not change GhostMonster movement, spawning, or chase behavior.
- Do not reveal the cover mechanic with tutorial or HUD copy.

## Contract changes needed

None. The existing occupancy and eligibility interfaces provide all required state.

## Open questions

None. The user request supplies the acceptance criteria and approves this feature scope.

## Out of scope

- Changing GhostMonster movement or chase logic.
- Changing house geometry or the Integration-owned main scene.
- Adding a scripted monster spawn, jumpscare, or tutorial.