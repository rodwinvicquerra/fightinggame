extends Node

var winner: String = ""
var game_over: bool = false
var p1_score: int = 0
var p2_score: int = 0

@onready var player1 = get_parent().get_node("Player1")
@onready var player2 = get_parent().get_node("Player2")
@onready var ui_layer = get_parent().get_node("UILayer")

func _ready():
	if player1:
		player1.health_changed.connect(_on_player1_health_changed)
		player1.player_died.connect(_on_player1_died)
		player1.score_changed.connect(_on_player1_score_changed)

	if player2:
		player2.health_changed.connect(_on_player2_health_changed)
		player2.player_died.connect(_on_player2_died)
		player2.score_changed.connect(_on_player2_score_changed)

func _on_player1_health_changed(new_health):
	if ui_layer and ui_layer.has_node("TopBar/Player1HPBar"):
		ui_layer.get_node("TopBar/Player1HPBar").value = new_health
	if ui_layer and ui_layer.has_node("TopBar/Player1HPLabel"):
		ui_layer.get_node("TopBar/Player1HPLabel").text = str(new_health) + "/100"

func _on_player2_health_changed(new_health):
	if ui_layer and ui_layer.has_node("TopBar/Player2HPBar"):
		ui_layer.get_node("TopBar/Player2HPBar").value = new_health
	if ui_layer and ui_layer.has_node("TopBar/Player2HPLabel"):
		ui_layer.get_node("TopBar/Player2HPLabel").text = str(new_health) + "/100"

func _on_player1_score_changed(new_score):
	if ui_layer and ui_layer.has_node("ScoreBar/Player1Score"):
		ui_layer.get_node("ScoreBar/Player1Score").text = "P1 Score: " + str(new_score)

func _on_player2_score_changed(new_score):
	if ui_layer and ui_layer.has_node("ScoreBar/Player2Score"):
		ui_layer.get_node("ScoreBar/Player2Score").text = "P2 Score: " + str(new_score)

func _on_player1_died():
	if GameState.game_mode == "survival":
		check_survival_game_over()
	else:
		game_over = true
		winner = "GOJO (Player 2) WINS!"
		if player2:
			player2.add_score(100)
		show_game_over()

func _on_player2_died():
	if GameState.game_mode == "survival":
		check_survival_game_over()
	else:
		game_over = true
		winner = "YUTA (Player 1) WINS!"
		if player1:
			player1.add_score(100)
		show_game_over()

func check_survival_game_over():
	var p1_alive = player1 and not player1.is_dead
	var p2_alive = player2 and not player2.is_dead
	if not p1_alive and not p2_alive:
		game_over = true
		var p1s = player1.score if player1 else 0
		var p2s = player2.score if player2 else 0
		winner = "SURVIVAL OVER!\nP1 Score: " + str(p1s) + "  P2 Score: " + str(p2s)
		show_game_over()
	elif not p1_alive or not p2_alive:
		pass

func show_game_over():
	if ui_layer and ui_layer.has_node("GameOverLabel"):
		var label = ui_layer.get_node("GameOverLabel")
		label.text = winner + "\nPress ENTER to restart"
		label.visible = true

func _input(event):
	if game_over and event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
