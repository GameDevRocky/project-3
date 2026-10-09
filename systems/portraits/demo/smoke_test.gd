extends SceneTree
## Dependency-free state/scene smoke test for the standalone portrait project.

var _checks: int = 0
var _failures: int = 0

func _initialize() -> void:
	call_deferred("_run_checks")

func _run_checks() -> void:
	var test_root := Node3D.new()
	var portraits := PortraitSystem.new()
	test_root.add_child(portraits)
	var open_frame := _make_painting(&"open", 1, false)
	var inactive_frame := _make_painting(&"inactive", 1, false)
	inactive_frame.is_active = false
	var family := _make_painting(&"family", 0, true)
	portraits.add_child(open_frame)
	portraits.add_child(inactive_frame)
	portraits.add_child(family)
	var carry_socket := Node3D.new()
	carry_socket.name = "CarrySocket"
	test_root.add_child(carry_socket)
	root.add_child(test_root)
	await process_frame

	_check(portraits.get_valid_entry_paintings(1).size() == 1, "active uncovered frame is eligible")
	_check(portraits.drape_sheet(&"open"), "cover request succeeds")
	_check(open_frame.is_covered and portraits.get_valid_entry_paintings(1).is_empty(), "cover appears in state and blocks entry")
	_check(not portraits.enter_painting(&"open"), "covered entry is rejected")
	_check(portraits.remove_sheet(&"open"), "uncover request succeeds")
	_check(portraits.set_painting_active(&"open", false), "frame deactivation succeeds")
	_check(not portraits.enter_painting(&"open"), "inactive entry is rejected")
	_check(portraits.set_painting_active(&"open", true), "frame reactivation succeeds")
	_check(portraits.enter_painting(&"open"), "valid frame accepts ghost")
	_check(not portraits.enter_painting(&"family"), "second painting cannot claim ghost")
	_check(portraits.exit_painting(&"open"), "ghost exits occupied frame")
	_check(not portraits.remove_family_portrait(false, carry_socket), "four-box gate blocks pickup")
	_check(portraits.remove_family_portrait(true, carry_socket), "family portrait attaches to carry socket")
	_check(portraits.enter_painting(&"family"), "carried family portrait can become occupied")
	_check(not portraits.is_family_portrait_safe_to_remove(), "occupied family portrait is unsafe to take outside")
	var drop_parent := Node3D.new()
	test_root.add_child(drop_parent)
	_check(portraits.drop_family_portrait(0, Transform3D(Basis.IDENTITY, Vector3(2, 1, 0)), drop_parent), "family portrait drops")
	_check(family.is_occupied and not family.is_being_carried, "drop preserves occupancy")
	_check(portraits.exit_painting(&"family"), "ghost exits after drop")

	print("Portrait smoke test: %d checks, %d failures." % [_checks, _failures])
	test_root.queue_free()
	await process_frame
	quit(1 if _failures > 0 else 0)

func _make_painting(id: StringName, room_id: int, family: bool) -> PortraitPainting:
	var painting := PortraitPainting.new()
	painting.portrait_id = id
	painting.room_id = room_id
	painting.is_family_portrait = family
	return painting

func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("FAIL: %s" % description)
