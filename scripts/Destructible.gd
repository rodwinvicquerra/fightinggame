extends StaticBody2D

@export var max_hp: int = 30
@export var object_type: String = "crate"

var hp: int
var is_destroyed: bool = false

func _ready():
	hp = max_hp
	add_to_group("destructible")
	build_visual()
	build_collision()

func build_collision():
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	match object_type:
		"crate":
			shape.size = Vector2(40, 40)
			col.position = Vector2(0, -20)
		"cursed_stone":
			shape.size = Vector2(45, 35)
			col.position = Vector2(0, -17)
		"torii_pillar":
			shape.size = Vector2(25, 60)
			col.position = Vector2(0, -30)
	col.shape = shape
	add_child(col)

func build_visual():
	match object_type:
		"crate":
			build_crate()
		"cursed_stone":
			build_cursed_stone()
		"torii_pillar":
			build_torii_pillar()

func build_crate():
	var body = ColorRect.new()
	body.name = "Visual"
	body.size = Vector2(40, 40)
	body.position = Vector2(-20, -40)
	body.color = Color(0.6, 0.4, 0.2)
	body.z_index = 3
	add_child(body)
	var line1 = ColorRect.new()
	line1.size = Vector2(40, 2)
	line1.position = Vector2(0, 19)
	line1.color = Color(0.45, 0.3, 0.15)
	body.add_child(line1)
	var line2 = ColorRect.new()
	line2.size = Vector2(2, 40)
	line2.position = Vector2(19, 0)
	line2.color = Color(0.45, 0.3, 0.15)
	body.add_child(line2)
	var corner1 = ColorRect.new()
	corner1.size = Vector2(6, 6)
	corner1.position = Vector2(0, 0)
	corner1.color = Color(0.5, 0.35, 0.18)
	body.add_child(corner1)
	var corner2 = ColorRect.new()
	corner2.size = Vector2(6, 6)
	corner2.position = Vector2(34, 0)
	corner2.color = Color(0.5, 0.35, 0.18)
	body.add_child(corner2)
	var corner3 = ColorRect.new()
	corner3.size = Vector2(6, 6)
	corner3.position = Vector2(0, 34)
	corner3.color = Color(0.5, 0.35, 0.18)
	body.add_child(corner3)
	var corner4 = ColorRect.new()
	corner4.size = Vector2(6, 6)
	corner4.position = Vector2(34, 34)
	corner4.color = Color(0.5, 0.35, 0.18)
	body.add_child(corner4)

func build_cursed_stone():
	var body = ColorRect.new()
	body.name = "Visual"
	body.size = Vector2(45, 35)
	body.position = Vector2(-22, -35)
	body.color = Color(0.15, 0.05, 0.2)
	body.z_index = 3
	add_child(body)
	var crack1 = ColorRect.new()
	crack1.size = Vector2(2, 20)
	crack1.position = Vector2(15, 5)
	crack1.color = Color(0.5, 0.0, 0.8, 0.8)
	body.add_child(crack1)
	var crack2 = ColorRect.new()
	crack2.size = Vector2(18, 2)
	crack2.position = Vector2(10, 18)
	crack2.color = Color(0.5, 0.0, 0.8, 0.8)
	body.add_child(crack2)
	var crack3 = ColorRect.new()
	crack3.size = Vector2(2, 15)
	crack3.position = Vector2(30, 10)
	crack3.color = Color(0.4, 0.0, 0.7, 0.6)
	body.add_child(crack3)
	var glow = ColorRect.new()
	glow.size = Vector2(8, 8)
	glow.position = Vector2(14, 13)
	glow.color = Color(0.7, 0.0, 1.0, 0.5)
	body.add_child(glow)

func build_torii_pillar():
	var pillar = ColorRect.new()
	pillar.name = "Visual"
	pillar.size = Vector2(20, 55)
	pillar.position = Vector2(-10, -55)
	pillar.color = Color(0.75, 0.12, 0.1)
	pillar.z_index = 3
	add_child(pillar)
	var top_beam = ColorRect.new()
	top_beam.size = Vector2(35, 6)
	top_beam.position = Vector2(-7, 0)
	top_beam.color = Color(0.8, 0.15, 0.1)
	pillar.add_child(top_beam)
	var cap = ColorRect.new()
	cap.size = Vector2(40, 4)
	cap.position = Vector2(-10, -5)
	cap.color = Color(0.65, 0.1, 0.08)
	pillar.add_child(cap)
	var band1 = ColorRect.new()
	band1.size = Vector2(22, 3)
	band1.position = Vector2(-1, 15)
	band1.color = Color(0.6, 0.08, 0.06)
	pillar.add_child(band1)
	var band2 = ColorRect.new()
	band2.size = Vector2(22, 3)
	band2.position = Vector2(-1, 40)
	band2.color = Color(0.6, 0.08, 0.06)
	pillar.add_child(band2)

func take_hit(damage: int):
	if is_destroyed:
		return
	hp -= damage
	var visual = get_node_or_null("Visual")
	if visual:
		visual.modulate = Color(1.0, 0.35, 0.35)
		var tw = create_tween()
		if tw:
			tw.tween_property(visual, "modulate", Color.WHITE, 0.15)
	var orig = position
	var stw = create_tween()
	if stw:
		stw.tween_property(self, "position", orig + Vector2(3, 0), 0.03)
		stw.tween_property(self, "position", orig + Vector2(-3, 0), 0.03)
		stw.tween_property(self, "position", orig, 0.03)
	if hp <= 0:
		destroy()

func destroy():
	is_destroyed = true
	var base_color = Color(0.6, 0.4, 0.2)
	match object_type:
		"cursed_stone":
			base_color = Color(0.3, 0.0, 0.4)
		"torii_pillar":
			base_color = Color(0.8, 0.15, 0.1)
	for i in range(8):
		var debris = ColorRect.new()
		debris.size = Vector2(randf_range(6, 14), randf_range(6, 14))
		debris.color = Color(
			base_color.r + randf_range(-0.1, 0.1),
			base_color.g + randf_range(-0.1, 0.1),
			base_color.b + randf_range(-0.1, 0.1), 1.0)
		debris.z_index = 8
		debris.pivot_offset = debris.size / 2
		get_parent().add_child(debris)
		debris.global_position = global_position + Vector2(randf_range(-15, 15), randf_range(-30, 0))
		var a = randf() * TAU
		var d = randf_range(30, 80)
		var dtw = create_tween()
		dtw.set_parallel(true)
		dtw.tween_property(debris, "position", debris.position + Vector2(cos(a) * d, sin(a) * d - 20), 0.5)
		dtw.tween_property(debris, "rotation", randf_range(-3, 3), 0.5)
		dtw.tween_property(debris, "modulate", Color.TRANSPARENT, 0.5)
		dtw.set_parallel(false)
		dtw.tween_callback(debris.queue_free)
	var fl = ColorRect.new()
	fl.size = Vector2(30, 30)
	fl.color = Color(1, 1, 0.7, 0.8)
	fl.z_index = 9
	fl.pivot_offset = Vector2(15, 15)
	get_parent().add_child(fl)
	fl.global_position = global_position - Vector2(15, 25)
	var fltw = create_tween()
	if fltw:
		fltw.set_parallel(true)
		fltw.tween_property(fl, "scale", Vector2(2.5, 2.5), 0.2)
		fltw.tween_property(fl, "modulate", Color.TRANSPARENT, 0.2)
		fltw.set_parallel(false)
		fltw.tween_callback(fl.queue_free)
	queue_free()
