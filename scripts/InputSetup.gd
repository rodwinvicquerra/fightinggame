extends Node

# This script ensures all required input actions are properly configured
# It runs automatically when the game starts

func _enter_tree():
	setup_input_actions()

func setup_input_actions():
	# Setup Player 1 controls (Arrow Keys and Space are usually pre-configured)
	# Setup Player 2 custom controls
	
	# Gojo Left - J Key
	if not InputMap.has_action("gojo_left"):
		InputMap.add_action("gojo_left")
		var key_event = InputEventKey.new()
		key_event.keycode = KEY_J
		InputMap.action_add_event("gojo_left", key_event)
	
	# Gojo Right - L Key
	if not InputMap.has_action("gojo_right"):
		InputMap.add_action("gojo_right")
		var key_event = InputEventKey.new()
		key_event.keycode = KEY_L
		InputMap.action_add_event("gojo_right", key_event)
	
	# Gojo Attack - K Key
	if not InputMap.has_action("gojo_attack"):
		InputMap.add_action("gojo_attack")
		var key_event = InputEventKey.new()
		key_event.keycode = KEY_K
		InputMap.action_add_event("gojo_attack", key_event)
	
	print("[InputSetup] Input actions configured successfully")
