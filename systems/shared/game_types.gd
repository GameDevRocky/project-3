class_name GameTypes
extends RefCounted

## Enumeration of lighting states for each room
enum LightState {
	OFF,
	ON,
	FLICKERING
}

## Master breaker box status
enum BreakerState {
	OPERATIONAL,
	TRIPPED
}

## Painting state for wall portrait entities
enum PaintingState {
	INACTIVE,
	ACTIVE
}

## Monster behavioral modes
enum GhostMode {
	FREE_ROAM,      ## Roaming physical rooms in darkness
	PAINTING_BOUND, ## Frozen inside an active painting in a lit room
	CHASE,          ## Actively pursuing player in darkness
	DORMANT         ## Opening startup phase before breaker is flipped
}

## Discrete room identification for tracking and lighting circuits
enum RoomId {
	ENTRY_HALL,
	PARLOR,
	STUDY,
	DINING_ROOM,
	BASEMENT,
	EXTERIOR_DRIVEWAY
}

## Carried item types for the player interaction system
enum CarriedItemType {
	NONE,
	BOX_LIVING_ROOM,
	BOX_DINING_ROOM,
	BOX_STUDY,
	BOX_BASEMENT,
	DUST_SHEET,
	FAMILY_PORTRAIT
}
