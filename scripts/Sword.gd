extends Node2D

@export var damage: int = 15
@export var attack_range: float = 50.0
@export var attack_duration: float = 0.3

var is_attacking: bool = false
var hit_targets: Array = []
var owner_player: Node2D = null

func _ready():
	if has_node("Area2D"):
		$Area2D.area_entered.connect(_on_area_entered)
		$Area2D.body_entered.connect(_on_body_entered)

func attack(player: Node2D):
	owner_player = player
	is_attacking = true
	hit_targets.clear()
	
	# Sword swing animation
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	var original_rotation = rotation
	var swing_angle = PI / 2
	
	if player.facing_right:
		tween.tween_property(self, "rotation", swing_angle, attack_duration * 0.5)
		tween.tween_property(self, "rotation", original_rotation, attack_duration * 0.5)
	else:
		tween.tween_property(self, "rotation", -swing_angle, attack_duration * 0.5)
		tween.tween_property(self, "rotation", original_rotation, attack_duration * 0.5)
	
	# Create slash effect
	create_slash_effect(player.facing_right)
	
	await get_tree().create_timer(attack_duration).timeout
	is_attacking = false

func _on_area_entered(area):
	if not is_attacking or area in hit_targets:
		return
	
	if area.is_in_group("player") and area.get_parent() != owner_player:
		hit_targets.append(area)
		var target_player = area.get_parent()
		if target_player:
			target_player.take_damage(damage)
			if owner_player and owner_player.has_method("add_score"):
				owner_player.add_score(10)
			create_hit_effect(area.global_position)

func _on_body_entered(body):
	if not is_attacking or body in hit_targets:
		return
	
	if body.is_in_group("player") and body != owner_player:
		hit_targets.append(body)
		body.take_damage(damage)
		if owner_player and owner_player.has_method("add_score"):
			owner_player.add_score(10)
		create_hit_effect(body.global_position)

func create_slash_effect(facing_right: bool):
	var slash = Line2D.new()
	slash.width = 3.0
	slash.default_color = Color.LIGHT_CORAL
	slash.z_index = 5
	
	if facing_right:
		slash.add_point(Vector2(-20, -20))
		slash.add_point(Vector2(20, 20))
	else:
		slash.add_point(Vector2(20, -20))
		slash.add_point(Vector2(-20, 20))
	
	add_child(slash)
	
	# Animate slash
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(slash, "modulate", Color(1, 1, 1, 0.5), 0.15)
	await tween.finished
	slash.queue_free()

func create_hit_effect(hit_position: Vector2):
	# Create impact burst - star-like slash lines
	for i in range(6):
		var effect = Line2D.new()
		effect.width = 3.0
		effect.z_index = 8
		
		var angle = (TAU / 6) * i + randf() * 0.3
		var length = randf_range(15, 35)
		var end_x = cos(angle) * length
		var end_y = sin(angle) * length
		
		effect.add_point(Vector2.ZERO)
		effect.add_point(Vector2(end_x, end_y))
		effect.default_color = Color(1.0, 0.3, 0.1, 1.0)
		
		get_parent().add_child(effect)
		effect.global_position = hit_position
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(effect, "global_position", hit_position + Vector2(end_x * 0.5, end_y * 0.5), 0.25)
		tween.tween_property(effect, "modulate", Color.TRANSPARENT, 0.25)
		tween.tween_property(effect, "width", 0.5, 0.25)
		tween.set_parallel(false)
		tween.tween_callback(effect.queue_free)
	
	# Create a flash circle effect
	var flash = ColorRect.new()
	flash.size = Vector2(30, 30)
	flash.color = Color(1, 1, 0.5, 0.8)
	flash.z_index = 9
	flash.pivot_offset = Vector2(15, 15)
	get_parent().add_child(flash)
	flash.global_position = hit_position - Vector2(15, 15)
	
	var flash_tween = create_tween()
	flash_tween.set_parallel(true)
	flash_tween.tween_property(flash, "scale", Vector2(2, 2), 0.15)
	flash_tween.tween_property(flash, "modulate", Color.TRANSPARENT, 0.15)
	flash_tween.set_parallel(false)
	flash_tween.tween_callback(flash.queue_free)

func get_attack_range() -> float:
	return attack_range
