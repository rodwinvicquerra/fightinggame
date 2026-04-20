extends CanvasLayer

var gojo_preview_texture: Texture2D
var yuta_preview_texture: Texture2D

func _ready():
	layer = 15
	gojo_preview_texture = load("res://assets/gojoskillpreview.png")
	yuta_preview_texture = load("res://assets/yutaskillpreview.png")

func show_skill_preview(pid: int, skill_name: String):
	var preview = TextureRect.new()
	var preview_w = 90
	var preview_h = 120
	if pid == 1:
		preview.texture = yuta_preview_texture
		preview.position = Vector2(4, 80)
	else:
		preview.texture = gojo_preview_texture
		preview.position = Vector2(800 - preview_w - 4, 80)
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(preview_w, preview_h)
	preview.size = Vector2(preview_w, preview_h)
	preview.modulate = Color(1, 1, 1, 0)
	add_child(preview)
	var tw = create_tween()
	tw.tween_property(preview, "modulate", Color(1, 1, 1, 0.9), 0.15)
	tw.tween_interval(0.8)
	tw.tween_property(preview, "modulate", Color.TRANSPARENT, 0.3)
	tw.tween_callback(preview.queue_free)
