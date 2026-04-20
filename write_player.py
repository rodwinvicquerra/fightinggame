content = """\
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
var punch_timer: float = 0.0
var special_timer: float = 0.0
var ultimate_timer: float = 0.0
var ultimate_cooldown: float = 10.0
var facing_right: bool = true
var score: int = 0
var frozen_timer: float = 0.0

var gravity: float = 800.0
var jump_force: float = -350.0
var is_on_floor: bool = true
var floor_y: float = 0.0

var flash_tween: Tween = null
var is_dead: bool = false

signal health_changed(new_health)
signal player_died
signal score_changed(new_score)

func _ready():
\thealth = max_health
\tscore = 0
\tfloor_y = position.y
\temit_signal("health_changed", health)
\temit_signal("score_changed", score)
\tif player_id == 2:
\t\tfacing_right = false
\t\t$Sprite2D.flip_h = true
\tadd_to_group("player")

func _physics_process(delta):
\tif is_dead:
\t\treturn
\tif frozen_timer > 0:
\t\tfrozen_timer -= delta
\t\tcurrent_velocity = 0.0
\telse:
\t\thandle_input()
\thandle_cooldowns(delta)
\tif not is_on_floor:
\t\tvelocity.y += gravity * delta
\telse:
\t\tvelocity.y = 0
\tvelocity.x = current_velocity
\tmove_and_slide()
\tif position.y >= floor_y:
\t\tposition.y = floor_y
\t\tif not is_on_floor:
\t\t\tis_on_floor = true
\t\t\tcreate_land_effect()
\t\tvelocity.y = 0
\tposition.x = clamp(position.x, 50, 750)

func handle_input():
\tcurrent_velocity = 0.0
\tif player_id == 1:
\t\tif Input.is_action_pressed("p1_left"):
\t\t\tcurrent_velocity = -move_speed
\t\t\tif facing_right:
\t\t\t\tfacing_right = false
\t\t\t\t$Sprite2D.flip_h = true
\t\telif Input.is_action_pressed("p1_right"):
\t\t\tcurrent_velocity = move_speed
\t\t\tif not facing_right:
\t\t\t\tfacing_right = true
\t\t\t\t$Sprite2D.flip_h = false
\t\tif Input.is_action_just_pressed("p1_punch") and can_punch:
\t\t\tperform_punch()
\t\tif Input.is_action_just_pressed("p1_special") and can_special:
\t\t\tperform_special()
\t\tif Input.is_action_just_pressed("p1_ultimate") and can_ultimate:
\t\t\tperform_ultimate()
\t\tif Input.is_action_just_pressed("p1_jump") and is_on_floor:
\t\t\tperform_jump()
\telif player_id == 2:
\t\tif Input.is_action_pressed("gojo_left"):
\t\t\tcurrent_velocity = -move_speed
\t\t\tif facing_right:
\t\t\t\tfacing_right = false
\t\t\t\t$Sprite2D.flip_h = true
\t\telif Input.is_action_pressed("gojo_right"):
\t\t\tcurrent_velocity = move_speed
\t\t\tif not facing_right:
\t\t\t\tfacing_right = true
\t\t\t\t$Sprite2D.flip_h = false
\t\tif Input.is_action_just_pressed("gojo_attack") and can_punch:
\t\t\tperform_punch()
\t\tif Input.is_action_just_pressed("gojo_special") and can_special:
\t\t\tperform_special()
\t\tif Input.is_action_just_pressed("gojo_ultimate") and can_ultimate:
\t\t\tperform_ultimate()
\t\tif Input.is_action_just_pressed("gojo_jump") and is_on_floor:
\t\t\tperform_jump()

func perform_jump():
\tis_on_floor = false
\tvelocity.y = jump_force
\tcreate_jump_effect()

func create_jump_effect():
\tfor i in range(5):
\t\tvar dust = ColorRect.new()
\t\tdust.size = Vector2(4, 4)
\t\tdust.color = Color(0.8, 0.8, 0.7, 0.8)
\t\tdust.z_index = 5
\t\tget_parent().add_child(dust)
\t\tdust.global_position = global_position + Vector2(randf_range(-15, 15), 0)
\t\tvar tw = create_tween()
\t\ttw.set_parallel(true)
\t\ttw.tween_property(dust, "position", dust.position + Vector2(randf_range(-20, 20), randf_range(-15, 5)), 0.3)
\t\ttw.tween_property(dust, "modulate", Color(1, 1, 1, 0), 0.3)
\t\ttw.set_parallel(false)
\t\ttw.tween_callback(dust.queue_free)

func create_land_effect():
\tfor i in range(4):
\t\tvar dust = ColorRect.new()
\t\tdust.size = Vector2(3, 3)
\t\tdust.color = Color(0.7, 0.7, 0.6, 0.7)
\t\tdust.z_index = 5
\t\tget_parent().add_child(dust)
\t\tdust.global_position = global_position + Vector2(randf_range(-10, 10), 0)
\t\tvar tw = create_tween()
\t\ttw.set_parallel(true)
\t\ttw.tween_property(dust, "position", dust.position + Vector2(randf_range(-15, 15), randf_range(-10, 0)), 0.25)
\t\ttw.tween_property(dust, "modulate", Color(1, 1, 1, 0), 0.25)
\t\ttw.set_parallel(false)
\t\ttw.tween_callback(dust.queue_free)

func perform_punch():
\tcan_punch = false
\tpunch_timer = punch_cooldown
\tvar tw = create_tween()
\tif tw:
\t\tvar orig_scale = $Sprite2D.scale
\t\ttw.tween_property($Sprite2D, "scale", orig_scale * 1.15, 0.05)
\t\ttw.tween_property($Sprite2D, "scale", orig_scale, 0.05)
\tcreate_fist_effect()
\tvar players = get_tree().get_nodes_in_group("player")
\tfor p in players:
\t\tif p == self or p.is_dead:
\t\t\tcontinue
\t\tvar dir_to = p.global_position - global_position
\t\tvar dist = dir_to.length()
\t\tvar in_front = (facing_right and dir_to.x > 0) or (not facing_right and dir_to.x < 0)
\t\tif dist < punch_range and in_front:
\t\t\tp.take_damage(punch_damage)
\t\t\tadd_score(10)
\t\t\tcreate_punch_hit_effect(p.global_position + Vector2(0, -15))

func perform_special():
\tcan_special = false
\tspecial_timer = special_cooldown
\tif player_id == 1:
\t\tcreate_yuta_special()
\telse:
\t\tcreate_gojo_special()

func perform_ultimate():
\tcan_ultimate = false
\tultimate_timer = ultimate_cooldown
\tif player_id == 1:
\t\tcreate_yuta_ultimate()
\telse:
\t\tcreate_gojo_ultimate()

func create_yuta_ultimate():
\tvar dir = 1.0 if facing_right else -1.0
\tvar overlay = ColorRect.new()
\toverlay.size = Vector2(800, 600)
\toverlay.color = Color(0.1, 0.0, 0.15, 0.75)
\toverlay.z_index = 50
\tget_parent().add_child(overlay)
\tvar otw = create_tween()
\tif otw:
\t\totw.tween_property(overlay, "modulate", Color.TRANSPARENT, 0.7)
\t\totw.tween_callback(overlay.queue_free)
\tfor i in range(14):
\t\tvar chunk = ColorRect.new()
\t\tchunk.size = Vector2(randf_range(20, 55), randf_range(20, 55))
\t\tchunk.color = Color(randf_range(0.3, 0.6), 0.0, randf_range(0.5, 0.9), 0.95)
\t\tchunk.z_index = 51
\t\tchunk.pivot_offset = chunk.size / 2
\t\tget_parent().add_child(chunk)
\t\tvar offset = Vector2(dir * randf_range(20, 140), randf_range(-90, 40))
\t\tchunk.global_position = global_position + offset
\t\tvar ctw = create_tween()
\t\tctw.set_parallel(true)
\t\tctw.tween_property(chunk, "scale", Vector2(randf_range(1.5, 3.0), randf_range(1.5, 3.0)), 0.3)
\t\tctw.tween_property(chunk, "modulate", Color.TRANSPARENT, 0.55)
\t\tctw.set_parallel(false)
\t\tctw.tween_callback(chunk.queue_free)
\tfor i in range(16):
\t\tvar pt = ColorRect.new()
\t\tpt.size = Vector2(8, 8)
\t\tpt.color = Color(0.7, 0.0, 1.0, 1.0)
\t\tpt.z_index = 52
\t\tget_parent().add_child(pt)
\t\tpt.global_position = global_position + Vector2(dir * randf_range(0, 90), randf_range(-60, 20))
\t\tvar a = randf() * TAU
\t\tvar d = randf_range(40, 110)
\t\tvar ptw = create_tween()
\t\tptw.set_parallel(true)
\t\tptw.tween_property(pt, "position", pt.position + Vector2(cos(a) * d, sin(a) * d), 0.45)
\t\tptw.tween_property(pt, "modulate", Color.TRANSPARENT, 0.45)
\t\tptw.set_parallel(false)
\t\tptw.tween_callback(pt.queue_free)
\t$Sprite2D.modulate = Color(0.6, 0.0, 1.0)
\tvar glow_tween = create_tween()
\tif glow_tween:
\t\tglow_tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.6)
\tvar players = get_tree().get_nodes_in_group("player")
\tfor p in players:
\t\tif p == self or p.is_dead:
\t\t\tcontinue
\t\tvar dv = p.global_position - global_position
\t\tvar in_front = (facing_right and dv.x > 0) or (not facing_right and dv.x < 0)
\t\tif abs(dv.x) < 160 and abs(dv.y) < 90 and in_front:
\t\t\tp.take_damage(20)
\t\t\tadd_score(50)
\t\t\tcreate_special_hit_effect(p.global_position, Color(0.5, 0.0, 1.0))

func create_gojo_ultimate():
\tvar dir = 1.0 if facing_right else -1.0
\tvar overlay = ColorRect.new()
\toverlay.size = Vector2(800, 600)
\toverlay.color = Color(0.0, 0.0, 0.08, 0.88)
\toverlay.z_index = 50
\tget_parent().add_child(overlay)
\tvar otw = create_tween()
\tif otw:
\t\totw.tween_property(overlay, "modulate", Color.TRANSPARENT, 1.5)
\t\totw.tween_callback(overlay.queue_free)
\tfor ring_i in range(5):
\t\tvar ring = Line2D.new()
\t\tring.width = 2.5
\t\tring.default_color = Color(0.2, 0.55, 1.0, 0.85)
\t\tring.z_index = 51
\t\tvar radius = 40.0 + ring_i * 38.0
\t\tfor ai in range(33):
\t\t\tvar a = (TAU / 32.0) * ai
\t\t\tring.add_point(Vector2(cos(a) * radius, sin(a) * radius))
\t\tget_parent().add_child(ring)
\t\tring.global_position = global_position + Vector2(dir * 60, -20)
\t\tvar rtw = create_tween()
\t\trtw.set_parallel(true)
\t\trtw.tween_property(ring, "scale", Vector2(2.8, 2.8), 0.9)
\t\trtw.tween_property(ring, "modulate", Color.TRANSPARENT, 1.0)
\t\trtw.set_parallel(false)
\t\trtw.tween_callback(ring.queue_free)
\tfor i in range(22):
\t\tvar sp = ColorRect.new()
\t\tsp.size = Vector2(6, 6)
\t\tsp.color = Color(0.5, 0.8, 1.0, 1.0)
\t\tsp.z_index = 52
\t\tget_parent().add_child(sp)
\t\tsp.global_position = global_position + Vector2(0, -20)
\t\tvar a = randf() * TAU
\t\tvar d = randf_range(60, 210)
\t\tvar stw = create_tween()
\t\tstw.set_parallel(true)
\t\tstw.tween_property(sp, "position", sp.position + Vector2(cos(a) * d, sin(a) * d), 0.8)
\t\tstw.tween_property(sp, "modulate", Color.TRANSPARENT, 0.8)
\t\tstw.set_parallel(false)
\t\tstw.tween_callback(sp.queue_free)
\t$Sprite2D.modulate = Color(0.8, 0.9, 1.0)
\tvar glow_tween = create_tween()
\tif glow_tween:
\t\tglow_tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.9)
\tvar players = get_tree().get_nodes_in_group("player")
\tfor p in players:
\t\tif p == self or p.is_dead:
\t\t\tcontinue
\t\tp.take_damage(20)
\t\tp.frozen_timer = 2.0
\t\tadd_score(50)
\t\tcreate_special_hit_effect(p.global_position, Color(0.2, 0.55, 1.0))

func create_yuta_special():
\tvar dir = 1.0 if facing_right else -1.0
\tvar slash = Line2D.new()
\tslash.width = 8.0
\tslash.default_color = Color(0.4, 0.0, 0.6, 1.0)
\tslash.z_index = 10
\tslash.add_point(Vector2.ZERO)
\tslash.add_point(Vector2(dir * 60, -15))
\tslash.add_point(Vector2(dir * 80, 0))
\tslash.add_point(Vector2(dir * 60, 15))
\tslash.add_point(Vector2.ZERO)
\tget_parent().add_child(slash)
\tslash.global_position = global_position + Vector2(dir * 20, -15)
\tfor i in range(8):
\t\tvar pt = ColorRect.new()
\t\tpt.size = Vector2(6, 6)
\t\tpt.color = Color(0.6, 0.1, 0.9, 0.9)
\t\tpt.z_index = 11
\t\tget_parent().add_child(pt)
\t\tpt.global_position = global_position + Vector2(dir * randf_range(15, 70), randf_range(-25, 15))
\t\tvar ptw = create_tween()
\t\tptw.set_parallel(true)
\t\tptw.tween_property(pt, "position", pt.position + Vector2(dir * 30, randf_range(-10, 10)), 0.3)
\t\tptw.tween_property(pt, "modulate", Color.TRANSPARENT, 0.3)
\t\tptw.set_parallel(false)
\t\tptw.tween_callback(pt.queue_free)
\tvar stw = create_tween()
\tif stw:
\t\tstw.tween_property(slash, "modulate", Color(0.5, 0, 1, 0), 0.35)
\t\tstw.tween_callback(slash.queue_free)
\tvar players = get_tree().get_nodes_in_group("player")
\tfor p in players:
\t\tif p == self or p.is_dead:
\t\t\tcontinue
\t\tvar d = p.global_position - global_position
\t\tvar in_front = (facing_right and d.x > 0) or (not facing_right and d.x < 0)
\t\tif abs(d.x) < 100 and abs(d.y) < 50 and in_front:
\t\t\tp.take_damage(special_damage)
\t\t\tadd_score(25)
\t\t\tcreate_special_hit_effect(p.global_position, Color(0.5, 0.0, 1.0))

func create_gojo_special():
\tvar dir = 1.0 if facing_right else -1.0
\tvar orb = ColorRect.new()
\torb.size = Vector2(20, 20)
\torb.color = Color(0.2, 0.5, 1.0, 0.9)
\torb.z_index = 10
\torb.pivot_offset = Vector2(10, 10)
\tget_parent().add_child(orb)
\torb.global_position = global_position + Vector2(dir * 25, -20)
\tvar ring = Line2D.new()
\tring.width = 3.0
\tring.default_color = Color(0.3, 0.6, 1.0, 0.8)
\tring.z_index = 10
\tfor ai in range(13):
\t\tvar a = (TAU / 12) * ai
\t\tring.add_point(Vector2(cos(a) * 15, sin(a) * 15))
\tget_parent().add_child(ring)
\tring.global_position = global_position + Vector2(dir * 25, -15)
\tvar otw = create_tween()
\tif otw:
\t\totw.set_parallel(true)
\t\totw.tween_property(orb, "position:x", orb.position.x + dir * 120, 0.3)
\t\totw.tween_property(orb, "scale", Vector2(1.5, 1.5), 0.3)
\t\totw.set_parallel(false)
\t\totw.tween_property(orb, "modulate", Color.TRANSPARENT, 0.15)
\t\totw.tween_callback(orb.queue_free)
\tvar rtw = create_tween()
\tif rtw:
\t\trtw.set_parallel(true)
\t\trtw.tween_property(ring, "position:x", ring.position.x + dir * 120, 0.3)
\t\trtw.tween_property(ring, "scale", Vector2(2, 2), 0.3)
\t\trtw.set_parallel(false)
\t\trtw.tween_property(ring, "modulate", Color.TRANSPARENT, 0.15)
\t\trtw.tween_callback(ring.queue_free)
\tfor i in range(6):
\t\tvar sp = ColorRect.new()
\t\tsp.size = Vector2(4, 4)
\t\tsp.color = Color(0.4, 0.7, 1.0, 0.8)
\t\tsp.z_index = 9
\t\tget_parent().add_child(sp)
\t\tsp.global_position = global_position + Vector2(dir * randf_range(10, 50), randf_range(-25, -5))
\t\tvar stw2 = create_tween()
\t\tstw2.set_parallel(true)
\t\tstw2.tween_property(sp, "position", sp.position + Vector2(dir * randf_range(20, 60), randf_range(-10, 10)), 0.25)
\t\tstw2.tween_property(sp, "modulate", Color.TRANSPARENT, 0.25)
\t\tstw2.set_parallel(false)
\t\tstw2.tween_callback(sp.queue_free)
\tvar players = get_tree().get_nodes_in_group("player")
\tfor p in players:
\t\tif p == self or p.is_dead:
\t\t\tcontinue
\t\tvar d = p.global_position - global_position
\t\tvar in_front = (facing_right and d.x > 0) or (not facing_right and d.x < 0)
\t\tif abs(d.x) < 120 and abs(d.y) < 50 and in_front:
\t\t\tp.take_damage(special_damage)
\t\t\tadd_score(25)
\t\t\tcreate_special_hit_effect(p.global_position, Color(0.2, 0.5, 1.0))

func create_fist_effect():
\tvar dir = 1.0 if facing_right else -1.0
\tvar fist = ColorRect.new()
\tfist.size = Vector2(14, 14)
\tfist.color = Color(1.0, 0.9, 0.7, 0.9)
\tfist.z_index = 10
\tfist.pivot_offset = Vector2(7, 7)
\tget_parent().add_child(fist)
\tfist.global_position = global_position + Vector2(dir * 20, -15)
\tvar line = Line2D.new()
\tline.width = 2.5
\tline.default_color = Color(1.0, 1.0, 0.8, 0.7)
\tline.z_index = 9
\tline.add_point(Vector2.ZERO)
\tline.add_point(Vector2(dir * 25, 0))
\tget_parent().add_child(line)
\tline.global_position = global_position + Vector2(dir * 5, -15)
\tvar ftw = create_tween()
\tif ftw:
\t\tftw.set_parallel(true)
\t\tftw.tween_property(fist, "position:x", fist.position.x + dir * 20, 0.1)
\t\tftw.tween_property(fist, "modulate", Color.TRANSPARENT, 0.15)
\t\tftw.set_parallel(false)
\t\tftw.tween_callback(fist.queue_free)
\tvar ltw = create_tween()
\tif ltw:
\t\tltw.tween_property(line, "modulate", Color.TRANSPARENT, 0.12)
\t\tltw.tween_callback(line.queue_free)

func create_punch_hit_effect(hit_pos: Vector2):
\tfor i in range(5):
\t\tvar sp = ColorRect.new()
\t\tsp.size = Vector2(5, 5)
\t\tsp.color = Color(1.0, 0.8, 0.2, 1.0)
\t\tsp.z_index = 12
\t\tget_parent().add_child(sp)
\t\tsp.global_position = hit_pos
\t\tvar a = randf() * TAU
\t\tvar d = randf_range(10, 30)
\t\tvar tgt = Vector2(cos(a) * d, sin(a) * d)
\t\tvar stw = create_tween()
\t\tstw.set_parallel(true)
\t\tstw.tween_property(sp, "position", sp.position + tgt, 0.2)
\t\tstw.tween_property(sp, "modulate", Color.TRANSPARENT, 0.2)
\t\tstw.set_parallel(false)
\t\tstw.tween_callback(sp.queue_free)
\tvar fl = ColorRect.new()
\tfl.size = Vector2(24, 24)
\tfl.color = Color(1.0, 1.0, 0.6, 0.8)
\tfl.z_index = 13
\tfl.pivot_offset = Vector2(12, 12)
\tget_parent().add_child(fl)
\tfl.global_position = hit_pos - Vector2(12, 12)
\tvar fltw = create_tween()
\tif fltw:
\t\tfltw.set_parallel(true)
\t\tfltw.tween_property(fl, "scale", Vector2(2.5, 2.5), 0.12)
\t\tfltw.tween_property(fl, "modulate", Color.TRANSPARENT, 0.12)
\t\tfltw.set_parallel(false)
\t\tfltw.tween_callback(fl.queue_free)

func create_special_hit_effect(hit_pos: Vector2, color: Color):
\tfor i in range(8):
\t\tvar sp = ColorRect.new()
\t\tsp.size = Vector2(7, 7)
\t\tsp.color = color
\t\tsp.z_index = 12
\t\tget_parent().add_child(sp)
\t\tsp.global_position = hit_pos
\t\tvar a = (TAU / 8) * i
\t\tvar d = randf_range(20, 45)
\t\tvar tgt = Vector2(cos(a) * d, sin(a) * d)
\t\tvar stw = create_tween()
\t\tstw.set_parallel(true)
\t\tstw.tween_property(sp, "position", sp.position + tgt, 0.3)
\t\tstw.tween_property(sp, "modulate", Color.TRANSPARENT, 0.3)
\t\tstw.set_parallel(false)
\t\tstw.tween_callback(sp.queue_free)
\tvar fl = ColorRect.new()
\tfl.size = Vector2(35, 35)
\tfl.color = Color(color.r, color.g, color.b, 0.9)
\tfl.z_index = 13
\tfl.pivot_offset = Vector2(17, 17)
\tget_parent().add_child(fl)
\tfl.global_position = hit_pos - Vector2(17, 17)
\tvar fltw = create_tween()
\tif fltw:
\t\tfltw.set_parallel(true)
\t\tfltw.tween_property(fl, "scale", Vector2(3, 3), 0.2)
\t\tfltw.tween_property(fl, "modulate", Color.TRANSPARENT, 0.2)
\t\tfltw.set_parallel(false)
\t\tfltw.tween_callback(fl.queue_free)

func handle_cooldowns(delta):
\tif not can_punch:
\t\tpunch_timer -= delta
\t\tif punch_timer <= 0:
\t\t\tcan_punch = true
\tif not can_special:
\t\tspecial_timer -= delta
\t\tif special_timer <= 0:
\t\t\tcan_special = true
\tif not can_ultimate:
\t\tultimate_timer -= delta
\t\tif ultimate_timer <= 0:
\t\t\tcan_ultimate = true

func add_score(points: int):
\tscore += points
\temit_signal("score_changed", score)

func take_damage(amount: int):
\tif is_dead:
\t\treturn
\thealth -= amount
\thealth = max(health, 0)
\temit_signal("health_changed", health)
\tif flash_tween != null:
\t\tif flash_tween.is_valid():
\t\t\tflash_tween.kill()
\t\tflash_tween = null
\tflash_tween = create_tween()
\tif flash_tween:
\t\t$Sprite2D.modulate = Color.RED
\t\tflash_tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.3)
\tvar kb_dir = -1.0 if facing_right else 1.0
\tposition.x += kb_dir * 15
\tvar orig_pos = $Sprite2D.position
\tvar stw = create_tween()
\tif stw:
\t\tstw.tween_property($Sprite2D, "position", orig_pos + Vector2(5, 0), 0.03)
\t\tstw.tween_property($Sprite2D, "position", orig_pos + Vector2(-5, 0), 0.03)
\t\tstw.tween_property($Sprite2D, "position", orig_pos + Vector2(3, 0), 0.03)
\t\tstw.tween_property($Sprite2D, "position", orig_pos, 0.03)
\tcreate_damage_popup(amount)
\tif health <= 0:
\t\tdie()

func create_damage_popup(dmg: int):
\tvar label = Label.new()
\tlabel.text = "-" + str(dmg)
\tlabel.add_theme_font_size_override("font_size", 20)
\tlabel.add_theme_color_override("font_color", Color.RED)
\tlabel.z_index = 20
\tlabel.position = Vector2(-15, -60)
\tadd_child(label)
\tvar tw = create_tween()
\tif tw:
\t\ttw.set_parallel(true)
\t\ttw.tween_property(label, "position", label.position + Vector2(0, -40), 0.6)
\t\ttw.tween_property(label, "modulate", Color(1, 0, 0, 0), 0.6)
\t\ttw.set_parallel(false)
\t\ttw.tween_callback(label.queue_free)

func die():
\tis_dead = true
\temit_signal("player_died")
\tset_physics_process(false)
\tif flash_tween != null:
\t\tif flash_tween.is_valid():
\t\t\tflash_tween.kill()
\t\tflash_tween = null
\tvar tw = create_tween()
\tif tw:
\t\ttw.tween_property($Sprite2D, "modulate", Color(1, 0, 0, 0.5), 0.3)
\t\ttw.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 0), 0.5)

func get_health_percentage() -> float:
\treturn float(health) / float(max_health)
"""

with open("scripts/Player.gd", "w", encoding="utf-8", newline="\n") as f:
    f.write(content)

print("Player.gd written successfully.")
