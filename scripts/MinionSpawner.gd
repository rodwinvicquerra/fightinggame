extends Node

var spawn_interval: float = 3.0
var spawn_timer: float = 2.0
var max_minions: int = 8

func _ready():
	if GameState.game_mode != "survival":
		set_process(false)

func _process(delta):
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = spawn_interval
		var current_count = get_tree().get_nodes_in_group("minion").size()
		if current_count < max_minions:
			spawn_minion()

func spawn_minion():
	var minion = CharacterBody2D.new()
	minion.set_script(load("res://scripts/Minion.gd"))
	var side = randi() % 2
	var spawn_x = 60.0 if side == 0 else 740.0
	minion.position = Vector2(spawn_x, 520)
	get_parent().add_child(minion)
