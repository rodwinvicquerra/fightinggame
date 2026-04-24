extends CharacterBody2D

var hp: int = 20
var move_speed: float = 60.0
var contact_damage: int = 5
var contact_cooldown: float = 1.0
var contact_timer: float = 0.0
var is_dead: bool = false
var gravity_val: float = 800.0
var floor_y: float = 520.0

func _ready():
	add_to_group("minion")
	# Put minions on layer 2 so they don't physically push against players (layer 1)
	collision_layer = 2
	collision_mask = 2
	build_visual()
	build_collision()

func build_visual():
	var body_rect = ColorRect.new()
	body_rect.name = "Visual"
	body_rect.size = Vector2(24, 28)
	body_rect.position = Vector2(-12, -28)
	body_rect.color = Color(0.15, 0.1, 0.2)
	body_rect.z_index = 4
	add_child(body_rect)
	var eye1 = ColorRect.new()
	eye1.size = Vector2(4, 4)
	eye1.position = Vector2(4, 5)
	eye1.color = Color(1, 0.1, 0.1)
	body_rect.add_child(eye1)
	var eye2 = ColorRect.new()
	eye2.size = Vector2(4, 4)
	eye2.position = Vector2(16, 5)
	eye2.color = Color(1, 0.1, 0.1)
	body_rect.add_child(eye2)
	var mouth = ColorRect.new()
	mouth.size = Vector2(10, 2)
	mouth.position = Vector2(7, 16)
	mouth.color = Color(0.8, 0.0, 0.0, 0.6)
	body_rect.add_child(mouth)

func build_collision():
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(24, 28)
	col.shape = shape
	col.position = Vector2(0, -14)
	add_child(col)

func _physics_process(delta):
	if is_dead:
		return
	contact_timer = max(contact_timer - delta, 0.0)
	var target = find_nearest_player()
	if target:
		var dir = sign(target.global_position.x - global_position.x)
		velocity.x = dir * move_speed
		var dist = (target.global_position - global_position).length()
		if dist < 35 and contact_timer <= 0:
			perform_attack(target)
			contact_timer = contact_cooldown
	else:
		velocity.x = 0
	if position.y < floor_y:
		velocity.y += gravity_val * delta
	else:
		velocity.y = 0
		position.y = floor_y
	move_and_slide()
	position.x = clamp(position.x, 30, 770)

func perform_attack(target: Node):
	target.take_damage(contact_damage)
	# Flash minion body orange during attack
	var visual = get_node_or_null("Visual")
	if visual:
		visual.color = Color(1.0, 0.45, 0.0)
		var ftw = create_tween()
		ftw.tween_property(visual, "color", Color(0.15, 0.1, 0.2), 0.2)
	# Spawn 3 slash marks at the target
	for i in range(3):
		var slash = ColorRect.new()
		slash.size = Vector2(randf_range(8, 16), randf_range(3, 6))
		slash.color = Color(1.0, 0.15, 0.0, 1.0)
		slash.z_index = 15
		slash.rotation = randf_range(-0.6, 0.6)
		get_parent().add_child(slash)
		slash.global_position = target.global_position + Vector2(randf_range(-12, 12), randf_range(-30, -5))
		var stw = get_tree().create_tween()
		stw.set_parallel(true)
		stw.tween_property(slash, "position", slash.position + Vector2(randf_range(-18, 18), randf_range(-20, -5)), 0.22)
		stw.tween_property(slash, "modulate", Color.TRANSPARENT, 0.22)
		stw.set_parallel(false)
		stw.tween_callback(slash.queue_free)
	# Brief lunge toward target
	var lunge_origin = global_position
	var lunge_dir = sign(target.global_position.x - global_position.x)
	var ltw = create_tween()
	ltw.tween_property(self, "global_position", lunge_origin + Vector2(lunge_dir * 12, 0), 0.06)
	ltw.tween_property(self, "global_position", lunge_origin, 0.10)

func find_nearest_player() -> Node:
	var players = get_tree().get_nodes_in_group("player")
	var nearest = null
	var min_dist = 99999.0
	for p in players:
		if p.is_dead:
			continue
		var d = (p.global_position - global_position).length()
		if d < min_dist:
			min_dist = d
			nearest = p
	return nearest

func take_damage(amount: int, attacker: Node = null):
	if is_dead:
		return
	hp -= amount
	var visual = get_node_or_null("Visual")
	if visual:
		visual.modulate = Color.RED
		var tw = create_tween()
		if tw:
			tw.tween_property(visual, "modulate", Color.WHITE, 0.2)
	if hp <= 0:
		die(attacker)

func die(attacker: Node = null):
	is_dead = true
	if attacker and attacker.has_method("add_score"):
		attacker.add_score(15)
	for i in range(6):
		var p = ColorRect.new()
		p.size = Vector2(5, 5)
		p.color = Color(0.3, 0.0, 0.1, 0.9)
		p.z_index = 8
		get_parent().add_child(p)
		p.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-20, 0))
		var a = randf() * TAU
		var d = randf_range(20, 50)
		var tw = get_tree().create_tween()
		tw.set_parallel(true)
		tw.tween_property(p, "position", p.position + Vector2(cos(a) * d, sin(a) * d), 0.4)
		tw.tween_property(p, "modulate", Color.TRANSPARENT, 0.4)
		tw.set_parallel(false)
		tw.tween_callback(p.queue_free)
	queue_free()
