# <NN-slug>: Spec

| | |
|---|---|
| System / Owner | <System> / <name> |
| Branch | `<system>/<NN>-<slug>` |
| Status | Draft / Approved (<date>) |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | <Prototype / Alpha / Final / Stretch> |

## 1. Overview

<What this feature is, in 3–5 sentences, and where it sits in the game loop and horror tension curve.>

## 2. Player-facing behavior

<What the player sees, hears, and feels, step by step. Include audio-visual cues and timing.>

## 3. Rules and numbers

| Rule / constant | Value | Source |
|---|---|---|
| <e.g. flicker duration> | <1.5 s> | `GAME_SPEC.md` §<n> |

<Formulas, state machines, and decision rules in plain words or pseudocode.>

## 4. Interfaces

**Uses** (from other systems; link, don't redefine):
- `CONTRACTS.md` §<n>: `<signal / method>`: <how this feature uses it>

**Provides / emits:**
- `<signal / method>`: <when, with what values>

**Contract changes:** <None, or the proposed change + `DECISIONS.md` entry ID. Don't build until approved.>

## 5. Scenes and files

| Path | New / changed | Purpose |
|---|---|---|
| `systems/<system>/...` | New / Changed | <Description> |

## 6. Edge cases and failure modes

- <What happens if lights flicker while ghost is mid-transition?>
- <What happens if player covers a portrait while ghost is entering it?>

## 7. Out of scope

- <Explicit list of things not included in this feature>

## 8. Done when

- [ ] <Observable criterion 1>
- [ ] <Observable criterion 2>
- [ ] Full GUT suite passes headless (no parse errors, all asserts pass)
- [ ] Owner checked it in `systems/<system>/test/` test scene
- [ ] Wired into `main.tscn` and verified with Run Project on `main`
