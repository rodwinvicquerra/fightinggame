extends Node

var spawn_timer: float = 2.0
var max_minions: int = 10
var elapsed_time: float = 0.0

func get_spawn_interval() -> float:
	if elapsed_time < 30.0:
		return 3.0
	elif elapsed_time < 60.0:
		return 2.0
	elif elapsed_time < 90.0:
		return 1.0
	else:
		return 0.5

func _ready():
	if GameState.game_mode != "survival":
		set_process(false)

func _process(delta):
	elapsed_time += delta
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = get_spawn_interval()
		var current_count = get_tree().get_nodes_in_group("minion").size()
		if current_count < max_minions:
			spawn_minion()

func spawn_minion():
	var minion = CharacterBody2D.new()
	minion.set_script(load("res://scripts/Minion.gd"))
	var is_aerial = randi() % 2 == 1
	if is_aerial:
		# Drop from random x at top of screen
		var spawn_x = randf_range(100, 700)
		minion.position = Vector2(spawn_x, 30)
		get_parent().add_child(minion)
		spawn_drop_warning(spawn_x)
	else:
		# Spawn from left or right side at ground level
		var side = randi() % 2
		var spawn_x = 60.0 if side == 0 else 740.0
		minion.position = Vector2(spawn_x, 520)
		get_parent().add_child(minion)

func spawn_drop_warning(x: float):
	# Blinking red diamond on the floor showing where the minion will land
	var marker = ColorRect.new()
	marker.size = Vector2(16, 16)
	marker.pivot_offset = Vector2(8, 8)
	marker.rotation_degrees = 45
	marker.color = Color(1.0, 0.1, 0.1, 0.85)
	marker.z_index = 6
	get_parent().add_child(marker)
	marker.global_position = Vector2(x - 8, 508)
	# Blink 3 times then disappear
	var tw = get_parent().create_tween()
	tw.tween_property(marker, "modulate", Color(1, 1, 1, 0.1), 0.18)
	tw.tween_property(marker, "modulate", Color(1, 1, 1, 0.85), 0.18)
	tw.tween_property(marker, "modulate", Color(1, 1, 1, 0.1), 0.18)
	tw.tween_property(marker, "modulate", Color(1, 1, 1, 0.85), 0.18)
	tw.tween_property(marker, "modulate", Color(1, 1, 1, 0.1), 0.18)
	tw.tween_callback(marker.queue_free)
