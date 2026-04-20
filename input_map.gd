extends Node

func _ready():
	setup_input_map()

func setup_input_map():
	# Player 1 (Yuta) - WASD move/jump, V punch, B special
	if not InputMap.has_action("p1_left"):
		InputMap.add_action("p1_left")
		var event = InputEventKey.new()
		event.keycode = KEY_A
		InputMap.action_add_event("p1_left", event)

	if not InputMap.has_action("p1_right"):
		InputMap.add_action("p1_right")
		var event = InputEventKey.new()
		event.keycode = KEY_D
		InputMap.action_add_event("p1_right", event)

	if not InputMap.has_action("p1_jump"):
		InputMap.add_action("p1_jump")
		var event = InputEventKey.new()
		event.keycode = KEY_W
		InputMap.action_add_event("p1_jump", event)

	if not InputMap.has_action("p1_punch"):
		InputMap.add_action("p1_punch")
		var event = InputEventKey.new()
		event.keycode = KEY_V
		InputMap.action_add_event("p1_punch", event)

	if not InputMap.has_action("p1_special"):
		InputMap.add_action("p1_special")
		var event = InputEventKey.new()
		event.keycode = KEY_B
		InputMap.action_add_event("p1_special", event)

	# Player 2 (Gojo) - Arrow keys move/jump, Numpad 1 punch, Numpad 2 special
	if not InputMap.has_action("gojo_left"):
		InputMap.add_action("gojo_left")
		var event = InputEventKey.new()
		event.keycode = KEY_LEFT
		InputMap.action_add_event("gojo_left", event)

	if not InputMap.has_action("gojo_right"):
		InputMap.add_action("gojo_right")
		var event = InputEventKey.new()
		event.keycode = KEY_RIGHT
		InputMap.action_add_event("gojo_right", event)

	if not InputMap.has_action("gojo_jump"):
		InputMap.add_action("gojo_jump")
		var event = InputEventKey.new()
		event.keycode = KEY_UP
		InputMap.action_add_event("gojo_jump", event)

	if not InputMap.has_action("gojo_attack"):
		InputMap.add_action("gojo_attack")
		var event = InputEventKey.new()
		event.keycode = KEY_I
		InputMap.action_add_event("gojo_attack", event)

	if not InputMap.has_action("gojo_special"):
		InputMap.add_action("gojo_special")
		var event = InputEventKey.new()
		event.keycode = KEY_O
		InputMap.action_add_event("gojo_special", event)

	# Player 1 Ultimate - N Key
	if not InputMap.has_action("p1_ultimate"):
		InputMap.add_action("p1_ultimate")
		var event2 = InputEventKey.new()
		event2.keycode = KEY_N
		InputMap.action_add_event("p1_ultimate", event2)

	# Player 2 Ultimate - P Key
	if not InputMap.has_action("gojo_ultimate"):
		InputMap.add_action("gojo_ultimate")
		var event3 = InputEventKey.new()
		event3.keycode = KEY_P
		InputMap.action_add_event("gojo_ultimate", event3)

	# Player 1 Cursed Burst - L Key
	if not InputMap.has_action("p1_cursed_burst"):
		InputMap.add_action("p1_cursed_burst")
		var event4 = InputEventKey.new()
		event4.keycode = KEY_L
		InputMap.action_add_event("p1_cursed_burst", event4)

	# Player 2 Blue Pull - M Key
	if not InputMap.has_action("gojo_blue_pull"):
		InputMap.add_action("gojo_blue_pull")
		var event5 = InputEventKey.new()
		event5.keycode = KEY_M
		InputMap.action_add_event("gojo_blue_pull", event5)
