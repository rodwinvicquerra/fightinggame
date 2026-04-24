extends CharacterBody2D

@export var player_id: int = 1
@export var max_health: int = 100
@export var move_speed: float = 200.0
@export var punch_damage: int = 10
@export var special_damage: int = 25
@export var punch_cooldown: float = 0.25
@export var special_cooldown: float = 1.5
@export var punch_range: float = 45.0

var health: int
var current_velocity: float = 0.0
var can_punch: bool = true
var can_special: bool = true
var can_ultimate: bool = true
var can_cursed_burst: bool = true
var can_blue_pull: bool = true
var punch_timer: float = 0.0
var special_timer: float = 0.0
var ultimate_timer: float = 0.0
var ultimate_cooldown: float = 10.0
var cursed_burst_timer: float = 0.0
var cursed_burst_cooldown: float = 3.0
var blue_pull_timer: float = 0.0
var blue_pull_cooldown: float = 3.0
var facing_right: bool = true
var score: int = 0
var frozen_timer: float = 0.0

var gravity: float = 800.0
var jump_force: float = -350.0
var on_ground: bool = true
var jump_count: int = 0
var max_jumps: int = 2

var flash_tween: Tween = null
var is_dead: bool = false

signal health_changed(new_health)
signal player_died
signal score_changed(new_score)


func _ready():
	health = max_health
	score = 0
	emit_signal("health_changed", health)
	emit_signal("score_changed", score)
	if player_id == 2:
		facing_right = false
		$Sprite2D.flip_h = true
	add_to_group("player")

func _physics_process(delta):
	if is_dead:
		return
	if frozen_timer > 0:
		frozen_timer -= delta
		current_velocity = 0.0
	else:
		handle_input()
	handle_cooldowns(delta)
	var was_on_floor = is_on_floor()
	if not was_on_floor:
		velocity.y += gravity * delta
	else:
		if velocity.y > 0:
			velocity.y = 0
	velocity.x = current_velocity
	move_and_slide()
	on_ground = is_on_floor()
	if not was_on_floor and on_ground:
		jump_count = 0
		create_land_effect()
	position.x = clamp(position.x, 50, 750)

func handle_input():
	current_velocity = 0.0
	if player_id == 1:
		if Input.is_action_pressed("p1_left"):
			current_velocity = -move_speed
			if facing_right:
				facing_right = false
				$Sprite2D.flip_h = true
		elif Input.is_action_pressed("p1_right"):
			current_velocity = move_speed
			if not facing_right:
				facing_right = true
				$Sprite2D.flip_h = false
		if Input.is_action_just_pressed("p1_punch") and can_punch:
			perform_punch()
		if Input.is_action_just_pressed("p1_special") and can_special:
			perform_special()
		if Input.is_action_just_pressed("p1_ultimate") and can_ultimate:
			perform_ultimate()
		if Input.is_action_just_pressed("p1_cursed_burst") and can_cursed_burst:
			perform_cursed_burst()
		if Input.is_action_just_pressed("p1_jump") and jump_count < max_jumps:
			perform_jump()
	elif player_id == 2:
		if Input.is_action_pressed("gojo_left"):
			current_velocity = -move_speed
			if facing_right:
				facing_right = false
				$Sprite2D.flip_h = true
		elif Input.is_action_pressed("gojo_right"):
			current_velocity = move_speed
			if not facing_right:
				facing_right = true
				$Sprite2D.flip_h = false
		if Input.is_action_just_pressed("gojo_attack") and can_punch:
			perform_punch()
		if Input.is_action_just_pressed("gojo_special") and can_special:
			perform_special()
		if Input.is_action_just_pressed("gojo_ultimate") and can_ultimate:
			perform_ultimate()
		if Input.is_action_just_pressed("gojo_blue_pull") and can_blue_pull:
			perform_blue_pull()
		if Input.is_action_just_pressed("gojo_jump") and jump_count < max_jumps:
			perform_jump()

func perform_jump():
	jump_count += 1
	on_ground = false
	velocity.y = jump_force
	create_jump_effect()

func create_jump_effect():
	for i in range(5):
		var dust = ColorRect.new()
		dust.size = Vector2(4, 4)
		dust.color = Color(0.8, 0.8, 0.7, 0.8)
		dust.z_index = 5
		get_parent().add_child(dust)
		dust.global_position = global_position + Vector2(randf_range(-15, 15), 0)
		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(dust, "position", dust.position + Vector2(randf_range(-20, 20), randf_range(-15, 5)), 0.3)
		tw.tween_property(dust, "modulate", Color(1, 1, 1, 0), 0.3)
		tw.set_parallel(false)
		tw.tween_callback(dust.queue_free)

func create_land_effect():
	for i in range(4):
		var dust = ColorRect.new()
		dust.size = Vector2(3, 3)
		dust.color = Color(0.7, 0.7, 0.6, 0.7)
		dust.z_index = 5
		get_parent().add_child(dust)
		dust.global_position = global_position + Vector2(randf_range(-10, 10), 0)
		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(dust, "position", dust.position + Vector2(randf_range(-15, 15), randf_range(-10, 0)), 0.25)
		tw.tween_property(dust, "modulate", Color(1, 1, 1, 0), 0.25)
		tw.set_parallel(false)
		tw.tween_callback(dust.queue_free)

func perform_punch():
	can_punch = false
	punch_timer = punch_cooldown
	var tw = create_tween()
	if tw:
		var orig_scale = $Sprite2D.scale
		tw.tween_property($Sprite2D, "scale", orig_scale * 1.15, 0.05)
		tw.tween_property($Sprite2D, "scale", orig_scale, 0.05)
	create_fist_effect()
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if p == self or p.is_dead:
			continue
		var dir_to = p.global_position - global_position
		var dist = dir_to.length()
		var in_front = (facing_right and dir_to.x > 0) or (not facing_right and dir_to.x < 0)
		if dist < punch_range and in_front:
			p.take_damage(punch_damage)
			add_score(10)
			create_punch_hit_effect(p.global_position + Vector2(0, -15))
	hit_minions_in_range(punch_range, punch_damage, true)
	hit_destructibles_in_range(punch_range, punch_damage)

func perform_special():
	can_special = false
	special_timer = special_cooldown

	if player_id == 1:
		create_yuta_special()
	else:
		create_gojo_special()

func perform_ultimate():
	can_ultimate = false
	ultimate_timer = ultimate_cooldown

	if player_id == 1:
		create_yuta_ultimate()
	else:
		create_gojo_ultimate()

func perform_cursed_burst():
	can_cursed_burst = false
	cursed_burst_timer = cursed_burst_cooldown

	var ring = Line2D.new()
	ring.width = 3.0
	ring.default_color = Color(0.6, 0.0, 0.9, 0.9)
	ring.z_index = 10
	for ai in range(17):
		var a = (TAU / 16.0) * ai
		ring.add_point(Vector2(cos(a) * 20, sin(a) * 20))
	get_parent().add_child(ring)
	ring.global_position = global_position + Vector2(0, -10)
	var rtw = create_tween()
	rtw.set_parallel(true)
	rtw.tween_property(ring, "scale", Vector2(4.0, 4.0), 0.4)
	rtw.tween_property(ring, "modulate", Color.TRANSPARENT, 0.45)
	rtw.set_parallel(false)
	rtw.tween_callback(ring.queue_free)
	for i in range(10):
		var pt = ColorRect.new()
		pt.size = Vector2(6, 6)
		pt.color = Color(0.7, 0.0, 1.0, 0.9)
		pt.z_index = 11
		get_parent().add_child(pt)
		pt.global_position = global_position + Vector2(0, -10)
		var a = randf() * TAU
		var d = randf_range(40, 90)
		var ptw = create_tween()
		ptw.set_parallel(true)
		ptw.tween_property(pt, "position", pt.position + Vector2(cos(a) * d, sin(a) * d), 0.35)
		ptw.tween_property(pt, "modulate", Color.TRANSPARENT, 0.35)
		ptw.set_parallel(false)
		ptw.tween_callback(pt.queue_free)
	$Sprite2D.modulate = Color(0.6, 0.0, 1.0)
	var glow_tween = create_tween()
	if glow_tween:
		glow_tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.4)
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if p == self or p.is_dead:
			continue
		var dv = p.global_position - global_position
		if abs(dv.x) < 90 and abs(dv.y) < 60:
			p.take_damage(20)
			add_score(30)
			create_special_hit_effect(p.global_position, Color(0.6, 0.0, 0.9))
	hit_minions_in_range(100.0, 20, false)
	hit_destructibles_in_range(100.0, 20)

func perform_blue_pull():
	can_blue_pull = false
	blue_pull_timer = blue_pull_cooldown

	for i in range(10):
		var pt = ColorRect.new()
		pt.size = Vector2(5, 5)
		pt.color = Color(0.3, 0.6, 1.0, 0.9)
		pt.z_index = 11
		get_parent().add_child(pt)
		var a = randf() * TAU
		var r = randf_range(80, 150)
		pt.global_position = global_position + Vector2(cos(a) * r, sin(a) * r * 0.5 - 10)
		var ptw = create_tween()
		ptw.set_parallel(true)
		ptw.tween_property(pt, "global_position", global_position + Vector2(0, -10), 0.4)
		ptw.tween_property(pt, "modulate", Color.TRANSPARENT, 0.45)
		ptw.set_parallel(false)
		ptw.tween_callback(pt.queue_free)
	$Sprite2D.modulate = Color(0.5, 0.7, 1.0)
	var glow_tw = create_tween()
	if glow_tw:
		glow_tw.tween_property($Sprite2D, "modulate", Color.WHITE, 0.5)
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if p == self or p.is_dead:
			continue
		var dv = p.global_position - global_position
		if abs(dv.x) < 200 and abs(dv.y) < 80:
			p.take_damage(15)
			add_score(25)
			var pull_dir = sign(global_position.x - p.global_position.x)
			var pull_tw = create_tween()
			pull_tw.tween_property(p, "position:x", p.position.x + pull_dir * 80, 0.3)
			create_special_hit_effect(p.global_position, Color(0.2, 0.5, 1.0))
	hit_minions_in_range(150.0, 15, false)
	hit_destructibles_in_range(150.0, 15)

func hit_minions_in_range(attack_range: float, damage: int, check_facing: bool):
	var minions = get_tree().get_nodes_in_group("minion")
	for m in minions:
		if m.is_dead:
			continue
		var dir_to = m.global_position - global_position
		var dist = dir_to.length()
		if check_facing:
			var in_front = (facing_right and dir_to.x > 0) or (not facing_right and dir_to.x < 0)
			if dist < attack_range and in_front:
				m.take_damage(damage, self)
				create_punch_hit_effect(m.global_position + Vector2(0, -15))
		else:
			if dist < attack_range:
				m.take_damage(damage, self)
				create_punch_hit_effect(m.global_position + Vector2(0, -15))

func hit_destructibles_in_range(attack_range: float, damage: int):
	var destructibles = get_tree().get_nodes_in_group("destructible")
	for obj in destructibles:
		var dist = (obj.global_position - global_position).length()
		if dist < attack_range:
			obj.take_hit(damage)

func create_yuta_ultimate():
	var dir = 1.0 if facing_right else -1.0
	var overlay = ColorRect.new()
	overlay.size = Vector2(800, 600)
	overlay.color = Color(0.1, 0.0, 0.15, 0.75)
	overlay.z_index = 50
	get_parent().add_child(overlay)
	var otw = create_tween()
	if otw:
		otw.tween_property(overlay, "modulate", Color.TRANSPARENT, 0.7)
		otw.tween_callback(overlay.queue_free)
	for i in range(14):
		var chunk = ColorRect.new()
		chunk.size = Vector2(randf_range(20, 55), randf_range(20, 55))
		chunk.color = Color(randf_range(0.3, 0.6), 0.0, randf_range(0.5, 0.9), 0.95)
		chunk.z_index = 51
		chunk.pivot_offset = chunk.size / 2
		get_parent().add_child(chunk)
		var offset = Vector2(dir * randf_range(20, 140), randf_range(-90, 40))
		chunk.global_position = global_position + offset
		var ctw = create_tween()
		ctw.set_parallel(true)
		ctw.tween_property(chunk, "scale", Vector2(randf_range(1.5, 3.0), randf_range(1.5, 3.0)), 0.3)
		ctw.tween_property(chunk, "modulate", Color.TRANSPARENT, 0.55)
		ctw.set_parallel(false)
		ctw.tween_callback(chunk.queue_free)
	for i in range(16):
		var pt = ColorRect.new()
		pt.size = Vector2(8, 8)
		pt.color = Color(0.7, 0.0, 1.0, 1.0)
		pt.z_index = 52
		get_parent().add_child(pt)
		pt.global_position = global_position + Vector2(dir * randf_range(0, 90), randf_range(-60, 20))
		var a = randf() * TAU
		var d = randf_range(40, 110)
		var ptw = create_tween()
		ptw.set_parallel(true)
		ptw.tween_property(pt, "position", pt.position + Vector2(cos(a) * d, sin(a) * d), 0.45)
		ptw.tween_property(pt, "modulate", Color.TRANSPARENT, 0.45)
		ptw.set_parallel(false)
		ptw.tween_callback(pt.queue_free)
	$Sprite2D.modulate = Color(0.6, 0.0, 1.0)
	var glow_tween = create_tween()
	if glow_tween:
		glow_tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.6)
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if p == self or p.is_dead:
			continue
		var dv = p.global_position - global_position
		var in_front = (facing_right and dv.x > 0) or (not facing_right and dv.x < 0)
		if abs(dv.x) < 160 and abs(dv.y) < 90 and in_front:
			p.take_damage(20)
			add_score(50)
			create_special_hit_effect(p.global_position, Color(0.5, 0.0, 1.0))
	hit_minions_in_range(160.0, 20, true)
	hit_destructibles_in_range(160.0, 20)

func create_gojo_ultimate():
	var dir = 1.0 if facing_right else -1.0
	var overlay = ColorRect.new()
	overlay.size = Vector2(800, 600)
	overlay.color = Color(0.0, 0.0, 0.08, 0.88)
	overlay.z_index = 50
	get_parent().add_child(overlay)
	var otw = create_tween()
	if otw:
		otw.tween_property(overlay, "modulate", Color.TRANSPARENT, 1.5)
		otw.tween_callback(overlay.queue_free)
	for ring_i in range(5):
		var ring = Line2D.new()
		ring.width = 2.5
		ring.default_color = Color(0.2, 0.55, 1.0, 0.85)
		ring.z_index = 51
		var radius = 40.0 + ring_i * 38.0
		for ai in range(33):
			var a = (TAU / 32.0) * ai
			ring.add_point(Vector2(cos(a) * radius, sin(a) * radius))
		get_parent().add_child(ring)
		ring.global_position = global_position + Vector2(dir * 60, -20)
		var rtw = create_tween()
		rtw.set_parallel(true)
		rtw.tween_property(ring, "scale", Vector2(2.8, 2.8), 0.9)
		rtw.tween_property(ring, "modulate", Color.TRANSPARENT, 1.0)
		rtw.set_parallel(false)
		rtw.tween_callback(ring.queue_free)
	for i in range(22):
		var sp = ColorRect.new()
		sp.size = Vector2(6, 6)
		sp.color = Color(0.5, 0.8, 1.0, 1.0)
		sp.z_index = 52
		get_parent().add_child(sp)
		sp.global_position = global_position + Vector2(0, -20)
		var a = randf() * TAU
		var d = randf_range(60, 210)
		var stw = create_tween()
		stw.set_parallel(true)
		stw.tween_property(sp, "position", sp.position + Vector2(cos(a) * d, sin(a) * d), 0.8)
		stw.tween_property(sp, "modulate", Color.TRANSPARENT, 0.8)
		stw.set_parallel(false)
		stw.tween_callback(sp.queue_free)
	$Sprite2D.modulate = Color(0.8, 0.9, 1.0)
	var glow_tween = create_tween()
	if glow_tween:
		glow_tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.9)
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if p == self or p.is_dead:
			continue
		p.take_damage(20)
		p.frozen_timer = 2.0
		add_score(50)
		create_special_hit_effect(p.global_position, Color(0.2, 0.55, 1.0))
	hit_minions_in_range(250.0, 20, false)
	hit_destructibles_in_range(250.0, 20)

func create_yuta_special():
	var dir = 1.0 if facing_right else -1.0
	var slash = Line2D.new()
	slash.width = 8.0
	slash.default_color = Color(0.4, 0.0, 0.6, 1.0)
	slash.z_index = 10
	slash.add_point(Vector2.ZERO)
	slash.add_point(Vector2(dir * 60, -15))
	slash.add_point(Vector2(dir * 80, 0))
	slash.add_point(Vector2(dir * 60, 15))
	slash.add_point(Vector2.ZERO)
	get_parent().add_child(slash)
	slash.global_position = global_position + Vector2(dir * 20, -15)
	for i in range(8):
		var pt = ColorRect.new()
		pt.size = Vector2(6, 6)
		pt.color = Color(0.6, 0.1, 0.9, 0.9)
		pt.z_index = 11
		get_parent().add_child(pt)
		pt.global_position = global_position + Vector2(dir * randf_range(15, 70), randf_range(-25, 15))
		var ptw = create_tween()
		ptw.set_parallel(true)
		ptw.tween_property(pt, "position", pt.position + Vector2(dir * 30, randf_range(-10, 10)), 0.3)
		ptw.tween_property(pt, "modulate", Color.TRANSPARENT, 0.3)
		ptw.set_parallel(false)
		ptw.tween_callback(pt.queue_free)
	var stw = create_tween()
	if stw:
		stw.tween_property(slash, "modulate", Color(0.5, 0, 1, 0), 0.35)
		stw.tween_callback(slash.queue_free)
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if p == self or p.is_dead:
			continue
		var d = p.global_position - global_position
		var in_front = (facing_right and d.x > 0) or (not facing_right and d.x < 0)
		if abs(d.x) < 100 and abs(d.y) < 50 and in_front:
			p.take_damage(special_damage)
			add_score(25)
			create_special_hit_effect(p.global_position, Color(0.5, 0.0, 1.0))
	hit_minions_in_range(100.0, special_damage, true)
	hit_destructibles_in_range(100.0, special_damage)

func create_gojo_special():
	var dir = 1.0 if facing_right else -1.0
	var orb = ColorRect.new()
	orb.size = Vector2(20, 20)
	orb.color = Color(0.2, 0.5, 1.0, 0.9)
	orb.z_index = 10
	orb.pivot_offset = Vector2(10, 10)
	get_parent().add_child(orb)
	orb.global_position = global_position + Vector2(dir * 25, -20)
	var ring = Line2D.new()
	ring.width = 3.0
	ring.default_color = Color(0.3, 0.6, 1.0, 0.8)
	ring.z_index = 10
	for ai in range(13):
		var a = (TAU / 12) * ai
		ring.add_point(Vector2(cos(a) * 15, sin(a) * 15))
	get_parent().add_child(ring)
	ring.global_position = global_position + Vector2(dir * 25, -15)
	var otw = create_tween()
	if otw:
		otw.set_parallel(true)
		otw.tween_property(orb, "position:x", orb.position.x + dir * 120, 0.3)
		otw.tween_property(orb, "scale", Vector2(1.5, 1.5), 0.3)
		otw.set_parallel(false)
		otw.tween_property(orb, "modulate", Color.TRANSPARENT, 0.15)
		otw.tween_callback(orb.queue_free)
	var rtw = create_tween()
	if rtw:
		rtw.set_parallel(true)
		rtw.tween_property(ring, "position:x", ring.position.x + dir * 120, 0.3)
		rtw.tween_property(ring, "scale", Vector2(2, 2), 0.3)
		rtw.set_parallel(false)
		rtw.tween_property(ring, "modulate", Color.TRANSPARENT, 0.15)
		rtw.tween_callback(ring.queue_free)
	for i in range(6):
		var sp = ColorRect.new()
		sp.size = Vector2(4, 4)
		sp.color = Color(0.4, 0.7, 1.0, 0.8)
		sp.z_index = 9
		get_parent().add_child(sp)
		sp.global_position = global_position + Vector2(dir * randf_range(10, 50), randf_range(-25, -5))
		var stw2 = create_tween()
		stw2.set_parallel(true)
		stw2.tween_property(sp, "position", sp.position + Vector2(dir * randf_range(20, 60), randf_range(-10, 10)), 0.25)
		stw2.tween_property(sp, "modulate", Color.TRANSPARENT, 0.25)
		stw2.set_parallel(false)
		stw2.tween_callback(sp.queue_free)
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if p == self or p.is_dead:
			continue
		var d = p.global_position - global_position
		var in_front = (facing_right and d.x > 0) or (not facing_right and d.x < 0)
		if abs(d.x) < 120 and abs(d.y) < 50 and in_front:
			p.take_damage(special_damage)
			add_score(25)
			create_special_hit_effect(p.global_position, Color(0.2, 0.5, 1.0))
	hit_minions_in_range(120.0, special_damage, true)
	hit_destructibles_in_range(120.0, special_damage)

func create_fist_effect():
	var dir = 1.0 if facing_right else -1.0
	var fist = ColorRect.new()
	fist.size = Vector2(14, 14)
	fist.color = Color(1.0, 0.9, 0.7, 0.9)
	fist.z_index = 10
	fist.pivot_offset = Vector2(7, 7)
	get_parent().add_child(fist)
	fist.global_position = global_position + Vector2(dir * 20, -15)
	var line = Line2D.new()
	line.width = 2.5
	line.default_color = Color(1.0, 1.0, 0.8, 0.7)
	line.z_index = 9
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2(dir * 25, 0))
	get_parent().add_child(line)
	line.global_position = global_position + Vector2(dir * 5, -15)
	var ftw = create_tween()
	if ftw:
		ftw.set_parallel(true)
		ftw.tween_property(fist, "position:x", fist.position.x + dir * 20, 0.1)
		ftw.tween_property(fist, "modulate", Color.TRANSPARENT, 0.15)
		ftw.set_parallel(false)
		ftw.tween_callback(fist.queue_free)
	var ltw = create_tween()
	if ltw:
		ltw.tween_property(line, "modulate", Color.TRANSPARENT, 0.12)
		ltw.tween_callback(line.queue_free)

func create_punch_hit_effect(hit_pos: Vector2):
	for i in range(5):
		var sp = ColorRect.new()
		sp.size = Vector2(5, 5)
		sp.color = Color(1.0, 0.8, 0.2, 1.0)
		sp.z_index = 12
		get_parent().add_child(sp)
		sp.global_position = hit_pos
		var a = randf() * TAU
		var d = randf_range(10, 30)
		var tgt = Vector2(cos(a) * d, sin(a) * d)
		var stw = create_tween()
		stw.set_parallel(true)
		stw.tween_property(sp, "position", sp.position + tgt, 0.2)
		stw.tween_property(sp, "modulate", Color.TRANSPARENT, 0.2)
		stw.set_parallel(false)
		stw.tween_callback(sp.queue_free)
	var fl = ColorRect.new()
	fl.size = Vector2(24, 24)
	fl.color = Color(1.0, 1.0, 0.6, 0.8)
	fl.z_index = 13
	fl.pivot_offset = Vector2(12, 12)
	get_parent().add_child(fl)
	fl.global_position = hit_pos - Vector2(12, 12)
	var fltw = create_tween()
	if fltw:
		fltw.set_parallel(true)
		fltw.tween_property(fl, "scale", Vector2(2.5, 2.5), 0.12)
		fltw.tween_property(fl, "modulate", Color.TRANSPARENT, 0.12)
		fltw.set_parallel(false)
		fltw.tween_callback(fl.queue_free)

func create_special_hit_effect(hit_pos: Vector2, color: Color):
	for i in range(8):
		var sp = ColorRect.new()
		sp.size = Vector2(7, 7)
		sp.color = color
		sp.z_index = 12
		get_parent().add_child(sp)
		sp.global_position = hit_pos
		var a = (TAU / 8) * i
		var d = randf_range(20, 45)
		var tgt = Vector2(cos(a) * d, sin(a) * d)
		var stw = create_tween()
		stw.set_parallel(true)
		stw.tween_property(sp, "position", sp.position + tgt, 0.3)
		stw.tween_property(sp, "modulate", Color.TRANSPARENT, 0.3)
		stw.set_parallel(false)
		stw.tween_callback(sp.queue_free)
	var fl = ColorRect.new()
	fl.size = Vector2(35, 35)
	fl.color = Color(color.r, color.g, color.b, 0.9)
	fl.z_index = 13
	fl.pivot_offset = Vector2(17, 17)
	get_parent().add_child(fl)
	fl.global_position = hit_pos - Vector2(17, 17)
	var fltw = create_tween()
	if fltw:
		fltw.set_parallel(true)
		fltw.tween_property(fl, "scale", Vector2(3, 3), 0.2)
		fltw.tween_property(fl, "modulate", Color.TRANSPARENT, 0.2)
		fltw.set_parallel(false)
		fltw.tween_callback(fl.queue_free)

func handle_cooldowns(delta):
	if not can_punch:
		punch_timer -= delta
		if punch_timer <= 0:
			can_punch = true
	if not can_special:
		special_timer -= delta
		if special_timer <= 0:
			can_special = true
	if not can_ultimate:
		ultimate_timer -= delta
		if ultimate_timer <= 0:
			can_ultimate = true
	if not can_cursed_burst:
		cursed_burst_timer -= delta
		if cursed_burst_timer <= 0:
			can_cursed_burst = true
	if not can_blue_pull:
		blue_pull_timer -= delta
		if blue_pull_timer <= 0:
			can_blue_pull = true

func add_score(points: int):
	score += points
	emit_signal("score_changed", score)

func take_damage(amount: int):
	if is_dead:
		return
	health -= amount
	health = max(health, 0)
	emit_signal("health_changed", health)
	if flash_tween != null:
		if flash_tween.is_valid():
			flash_tween.kill()
		flash_tween = null
	flash_tween = create_tween()
	if flash_tween:
		$Sprite2D.modulate = Color.RED
		flash_tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.3)
	var kb_dir = -1.0 if facing_right else 1.0
	position.x += kb_dir * 15
	var orig_pos = $Sprite2D.position
	var stw = create_tween()
	if stw:
		stw.tween_property($Sprite2D, "position", orig_pos + Vector2(5, 0), 0.03)
		stw.tween_property($Sprite2D, "position", orig_pos + Vector2(-5, 0), 0.03)
		stw.tween_property($Sprite2D, "position", orig_pos + Vector2(3, 0), 0.03)
		stw.tween_property($Sprite2D, "position", orig_pos, 0.03)
	create_damage_popup(amount)
	if health <= 0:
		die()

func create_damage_popup(dmg: int):
	var label = Label.new()
	label.text = "-" + str(dmg)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color.RED)
	label.z_index = 20
	label.position = Vector2(-15, -60)
	add_child(label)
	var tw = create_tween()
	if tw:
		tw.set_parallel(true)
		tw.tween_property(label, "position", label.position + Vector2(0, -40), 0.6)
		tw.tween_property(label, "modulate", Color(1, 0, 0, 0), 0.6)
		tw.set_parallel(false)
		tw.tween_callback(label.queue_free)

func die():
	is_dead = true
	emit_signal("player_died")
	set_physics_process(false)
	if flash_tween != null:
		if flash_tween.is_valid():
			flash_tween.kill()
		flash_tween = null
	var tw = create_tween()
	if tw:
		tw.tween_property($Sprite2D, "modulate", Color(1, 0, 0, 0.5), 0.3)
		tw.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 0), 0.5)

func get_health_percentage() -> float:
	return float(health) / float(max_health)
