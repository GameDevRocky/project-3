# 08-story-text: Brainstorm

| | |
|---|---|
| System | Integration / Narrative & Presentation |
| Owner | John |
| Branch | `integration/story-text` |
| Agent | Gemini CLI |
| Date | 2026-10-15 |
| Milestone | Final Game Delivery |

## Goal

Add narrative intro, event tooltips, horror audio cues, story-driven endings, and a jumpscare upon player capture:
1. **Intro Text:** Explains the premise (moving out on the eve of new tenants, packing 4 rooms of belongings, final family portrait) without mentioning the ghost. Dismissible via key press/click.
2. **Event Tooltips:**
   - Breaker flip awakening: "It has awoken".
   - Power drain / anger (low voltage / dimming): Warning tooltip when lights dim/destabilize.
   - Room transition after dimming: "Something has moved through the shadows..." (no destination room revealed).
3. **Horror Audio Cues:**
   - Painting entry/exit audio cues.
   - Suspenseful chase lock-on sting.
   - Rumbling chase drone during active pursuit.
4. **Endings & Jumpscare:**
   - Rich narrative text for Win, Loss (escaped in portrait), and Death (caught).
   - Jumpscare flash & audio upon capture.

## Grounding

- `GAME_SPEC.md` §4 & §7: Premise, moving boxes, objective flow, and endings.
- `CONTRACTS.md` §2.1 & §2.3: System coordination and events.

## Q&A

1. **Q:** How should the intro text be presented and dismissed?
   **A:** Option 1: Full-screen narrative overlay panel at game start explaining the moving out chore, dismissible with 'E' or Spacebar to begin gameplay. · *why:* Sets the mood clearly before the player takes control.
