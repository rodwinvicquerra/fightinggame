extends CanvasLayer

var gojo_preview_texture: Texture2D
var yuta_preview_texture: Texture2D

func _ready():
	layer = 15
	gojo_preview_texture = load("res://assets/gojoskillpreview.png")
	yuta_preview_texture = load("res://assets/yutaskillpreview.png")

func show_skill_preview(pid: int, skill_name: String):
	var preview = TextureRect.new()
	if pid == 1:
		preview.texture = yuta_preview_texture
		preview.position = Vector2(10, 150)
	else:
		preview.texture = gojo_preview_texture
		preview.position = Vector2(610, 150)
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(170, 230)
	preview.size = Vector2(170, 230)
	preview.modulate = Color(1, 1, 1, 0)
	add_child(preview)
	var tw = create_tween()
	tw.tween_property(preview, "modulate", Color(1, 1, 1, 0.9), 0.15)
	tw.tween_interval(0.8)
	tw.tween_property(preview, "modulate", Color.TRANSPARENT, 0.3)
	tw.tween_callback(preview.queue_free)
