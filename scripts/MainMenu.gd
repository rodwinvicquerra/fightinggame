extends Control

func _ready():
	$VBoxContainer/PvPButton.pressed.connect(_on_pvp)
	$VBoxContainer/SurvivalButton.pressed.connect(_on_survival)

func _on_pvp():
	GameState.game_mode = "pvp"
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_survival():
	GameState.game_mode = "survival"
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
