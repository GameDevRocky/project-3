# 04-energy-tuning: Brainstorm

| | |
|---|---|
| System | Electrical & Lighting |
| Owner | Rocky |
| Branch | `electrical/04-energy-tuning` |
| Agent | Gemini CLI |
| Date | 2026-10-15 |
| Milestone | Final Game Delivery |

## Goal

Tune the power grid capacity (`max_power`) and energy drain/recharge dynamics to provide the optimal balance between tension and exploration pacing during the packing phase.

## Grounding

- `GAME_SPEC.md` §9: Tuning Table (Capacity, drain per room, recharge rate, trip thresholds).
- `CONTRACTS.md` §2.1: `ElectricalSystem` public methods and signals.
- `systems/electrical/power_meter_hud.gd`: Dynamic warnings (low voltage, critical voltage, blackout).

## Q&A

1. **Q:** What target capacity and gameplay pacing do you prefer for the power grid?
   **A:** 250 Watts capacity, combined with a continuous generator recharge model where power recharges with a small number of lit rooms, but drains when many or all rooms are lit. · *why:* 250W provides enough reserve to carry items without constant frustrating blackouts, while continuous generation rewards turning off unused rooms.

2. **Q:** What should the continuous recharge rate and per-room drain rate be (and at how many lit rooms should the grid break even)?
   **A:** Option 1: Break-even at 2 rooms (Base recharge +4.0 W/s, drain 2.0 W/s per lit room).
     - 0 rooms lit: +4.0 W/s (recharges to full 250W in ~62s)
     - 1 room lit: +2.0 W/s (net recharge while actively working in a single room)
     - 2 rooms lit: 0.0 W/s (break-even equilibrium; player can keep active room + hallway illuminated)
     - 3 rooms lit: -2.0 W/s (steady drain)
     - 4 rooms lit: -4.0 W/s (rapid drain)
     - 5 rooms lit (all on): -6.0 W/s (critical drain, empties full reserve in ~42s)
     · *why:* Rewards tactical light management while ensuring neglectful play results in a blackout.

3. **Q:** What should the warning and dimming thresholds be scaled to for the 250W grid?
   **A:** Low Voltage warning at 100W, Lights Dimming at 50W, and Critical Flashing at 25W. · *why:* Provides a generous amber window at 100W (40%) to notify the player, activates dimming at 50W (20%), and triggers critical red flashing at 25W (10%) before the final blackout at 0W.

## Decisions

- **D-ET-1:** Set `max_power` and initial operational power to **250.0 Watts**.
- **D-ET-2:** Implement continuous net power generation:
  - Base recharge rate: **+4.0 W/s**.
  - Drain rate per lit room: **2.0 W/s**.
  - Net power change formula: `net_rate = base_recharge - (lit_rooms * drain_rate_per_room)`.
  - 0 rooms lit: `+4.0 W/s` recharge.
  - 1 room lit: `+2.0 W/s` recharge.
  - 2 rooms lit: `0.0 W/s` break-even equilibrium.
  - 3 rooms lit: `-2.0 W/s` drain.
  - 4 rooms lit: `-4.0 W/s` drain.
  - 5 rooms lit (all on): `-6.0 W/s` drain (~42 seconds from full 250W to blackout).
- **D-ET-3:** Scaled voltage warning and dimming thresholds:
  - **Low Voltage Warning:** Current power `< 100.0 W` (displays amber warning banner and amber wattage bar).
  - **Light Fixture Dimming & Paranormal Flicker:** Current power `< 50.0 W` (dims visual omni lights and arms low-voltage flicker; rearms above `60.0 W`).
  - **Critical Destabilizing Voltage:** Current power `< 25.0 W` (displays flashing red warning banner and red bar).
  - **Master Breaker Trip:** At `<= 0.0 W` (house blackout).
  - **Breaker Panel Reset:** Restores full **250.0 Watts**.
- **D-ET-4:** Update `GAME_SPEC.md` §9 Tuning Table to document the new 250W capacity, 4.0 W/s base recharge, 2.0 W/s per-room drain, and updated warning thresholds.

## Contract changes needed

- None. All public method signatures and signals (`get_current_power()`, `power_meter_updated`, `reset_breaker()`) remain unchanged.

## Open questions

- None. All tuning numbers finalized.

## Out of scope

- Redesigning electrical breaker panel 3D model or adding new circuits.
