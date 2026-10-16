# 08-story-text: Spec

| | |
|---|---|
| System / Owner | Integration / John |
| Branch | `integration/story-text` |
| Status | Approved by user on 2026-10-15 |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | Final Game Delivery |

## 1. Overview

Adds immersive narrative framing, event tooltips, horror audio enhancements, rich story text for endings, and a jumpscare upon player capture:
1. **Intro Overlay:** Explains that new tenants move in tomorrow, and you must clear out the four packed moving boxes and the final family portrait from your old family home before time runs out (no mention of the ghost).
2. **Event Tooltips:**
   - On basement breaker flip: `"It has awoken"` appears as a transient center screen tooltip.
   - On low voltage / dimming (<50W): `"The lights are straining as something stirs in the dark..."`.
   - On ghost room transfer / room change: `"Something has moved through the shadows..."`.
3. **Horror Audio & Jumpscare:**
   - Distinct canvas strain / wooden creak sound on painting entry/exit.
   - Suspenseful string/brass sting on entering `CHASE` mode.
   - Low rumbling bass drone loop while `is_chasing` is active.
   - Jumpscare flash (red/black strobe overlay + piercing shriek) when caught by the monster.
4. **Narrative Endings:**
   - **Win (Safe Escape):** `"ESCAPED\n\nYou successfully packed all your belongings, contained the shadows within the walls, and left the family home behind safely."`
   - **Loss (Trapped in Portrait):** `"YOU BROUGHT IT WITH YOU\n\nYou loaded the family portrait into the car trunk, unaware the entity was trapped inside the canvas. It followed you out into the world."`
   - **Death (Caught):** `"THE DARKNESS TOOK YOU\n\nYou were caught in the dark before you could finish packing. The house claims another tenant."`

## 2. Rules and numbers

| Parameter | Value | Source |
|---|---|---|
| Intro Overlay Dismissal Key | `E` or `Space` | User request |
| Tooltip Duration | 3.5 seconds | UI presentation standard |
| Chase Rumbling Audio Interval | Continuous looping drone during chase | User request |
| Jumpscare Flash Duration | 0.8 seconds | Visual impact standard |

## 3. Interfaces

**Uses:**
- `GameCoordinator`, `GameHUD`, `PlayerController`, `ElectricalSystem`, `GhostMonster`, `ProceduralAudio`.

**Provides / Emits:**
- Narrative event notifications and jumpscare triggers.

## 4. Done when

- [ ] Intro narrative overlay displays premise without mentioning the ghost, dismissible with E/Space.
- [ ] Tooltip `"It has awoken"` displays upon flipping the basement breaker.
- [ ] Low-voltage dimming displays warning tooltip.
- [ ] Ghost room movement displays `"Something has moved through the shadows..."` without revealing destination.
- [ ] Painting entry/exit, chase lock-on sting, and chase rumbling sound play correctly.
- [ ] Jumpscare flash and audio trigger upon player capture.
- [ ] Rich narrative ending texts display for Win, Loss, and Death.
- [ ] Full GUT test suite passes with 0 errors.
