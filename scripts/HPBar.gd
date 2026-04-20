extends CanvasLayer

@export var player1: Node2D
@export var player2: Node2D
@export var hp_bar_texture: Texture2D

var player1_max_health: int = 100
var player2_max_health: int = 100

func _ready():
	if player1:
		player1_max_health = player1.max_health
		if player1.has_signal("health_changed"):
			player1.health_changed.connect(_on_player1_health_changed)
	
	if player2:
		player2_max_health = player2.max_health
		if player2.has_signal("health_changed"):
			player2.health_changed.connect(_on_player2_health_changed)

func _on_player1_health_changed(new_health):
	update_hp_bar("Player1", new_health, player1_max_health)

func _on_player2_health_changed(new_health):
	update_hp_bar("Player2", new_health, player2_max_health)

func update_hp_bar(player_label: String, current_health: int, max_health: int):
	var health_percentage = float(current_health) / float(max_health)
	
	if has_node(player_label + "HPLabel"):
		var label = get_node(player_label + "HPLabel")
		label.text = str(current_health) + " / " + str(max_health)
	
	if has_node(player_label + "HPBar"):
		var bar = get_node(player_label + "HPBar")
		if bar.has_method("set_value"):
			bar.set_value(health_percentage * 100)
		elif bar is TextureProgressBar:
			bar.value = health_percentage * 100
