extends Area2D

@export_multiline var text: String = ""
@export var note_id: String = "note"

var player_near: bool = false
var panel: Node = null

func _ready() -> void:
	add_to_group("note")
	body_entered.connect(_in)
	body_exited.connect(_out)

func _in(b: Node2D) -> void:
	if b.is_in_group("player"):
		player_near = true
		show_note_panel(b)

func _out(b: Node2D) -> void:
	if b.is_in_group("player"):
		player_near = false
		hide_note_panel()

func show_note_panel(p: Node2D) -> void:
	if panel:
		return
	var cl: CanvasLayer = CanvasLayer.new()
	cl.layer = 10
	p.add_child(cl)
	panel = cl
	
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(1152, 648)
	cl.add_child(bg)
	
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.add_theme_color_override("font_color", Color(1, 0.9, 0.7))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	lbl.custom_minimum_size = Vector2(600, 300)
	lbl.offset_left = -300
	lbl.offset_top = -150
	lbl.offset_right = 300
	lbl.offset_bottom = 150
	cl.add_child(lbl)
	
	var hint: Label = Label.new()
	hint.text = "[Press E to close]"
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	hint.offset_left = -100
	hint.offset_top = 120
	hint.offset_right = 100
	hint.offset_bottom = 150
	cl.add_child(hint)

func hide_note_panel() -> void:
	if panel:
		panel.queue_free()
		panel = null
