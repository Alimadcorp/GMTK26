extends Area2D

@export var bomb_num: int = 1
@export var start_time: float = 120.0

var time_left: float
var done: bool = false
var near: bool = false
var active: bool = false
var panel_layer: CanvasLayer = null
var timer_label: Label = null
var wire_red: ColorRect = null
var wire_blue: ColorRect = null
var wire_green: ColorRect = null
var keyhole_rect: ColorRect = null
var cutter_sprite: Sprite2D = null
var cutting_mode: bool = false
var hovering_wire: String = ""

func _ready() -> void:
	time_left = start_time
	add_to_group("bomb_node")
	body_entered.connect(_in)
	body_exited.connect(_out)

func _process(delta: float) -> void:
	if active and not done:
		time_left -= delta
		_update_timer_display()
		if time_left <= 0.0:
			_explode()

func start_ticking() -> void:
	active = true

func _in(b: Node2D) -> void:
	if b.is_in_group("player") and not done:
		near = true
		b.tgt = self
		show_panel(b)

func _out(b: Node2D) -> void:
	if b.is_in_group("player"):
		near = false
		if b.tgt == self:
			b.tgt = null
		hide_panel()

func use() -> void:
	if done:
		return
	
	var p: Node2D = get_tree().get_first_node_in_group("player")
	if not p:
		return
	
	if bomb_num <= 3:
		if not p.has_item("cutter"):
			p.txt("Need wire cutters!", 2.0)
			return
		_start_cutting(p)
	else:
		if not p.has_item("master_key"):
			p.txt("Needs a master key...", 2.0)
			return
		p.consume_item("master_key")
		_defuse_bomb()

func _start_cutting(p: Node2D) -> void:
	if cutting_mode:
		return
	cutting_mode = true
	cutter_sprite = Sprite2D.new()
	var tex: Texture2D = load("res://assets/light.png")
	cutter_sprite.texture = tex
	cutter_sprite.scale = Vector2(0.05, 0.05)
	p.add_child(cutter_sprite)

func _stop_cutting(p: Node2D) -> void:
	cutting_mode = false
	if cutter_sprite:
		cutter_sprite.queue_free()
		cutter_sprite = null
	hovering_wire = ""

func _input(event: InputEvent) -> void:
	if not cutting_mode or not near:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_cut_wire()

func _try_cut_wire() -> void:
	if hovering_wire == "":
		return
	
	var p: Node2D = get_tree().get_first_node_in_group("player")
	if not p:
		return
	
	if hovering_wire == "red":
		p.txt("Wire cut!", 1.5)
		p.consume_item("cutter")
		_defuse_bomb()
	else:
		p.txt("Wrong wire!", 1.0)
		var gm: Node = get_tree().current_scene
		if gm.has_method("boom"):
			gm.boom()

func _defuse_bomb() -> void:
	done = true
	active = false
	cutting_mode = false
	if cutter_sprite:
		cutter_sprite.queue_free()
		cutter_sprite = null
	hide_panel()
	
	var gm: Node = get_tree().current_scene
	if gm.has_method("defuse"):
		gm.defuse()

func _explode() -> void:
	done = true
	active = false
	var gm: Node = get_tree().current_scene
	if gm.has_method("boom"):
		gm.boom()

func show_panel(p: Node2D) -> void:
	if panel_layer:
		return
	
	panel_layer = CanvasLayer.new()
	panel_layer.layer = 5
	p.add_child(panel_layer)
	
	var panel_bg: ColorRect = ColorRect.new()
	panel_bg.color = Color(0.1, 0.1, 0.1, 0.9)
	panel_bg.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_bg.offset_left = -200
	panel_bg.offset_top = 150
	panel_bg.offset_right = 200
	panel_bg.offset_bottom = 400
	panel_layer.add_child(panel_bg)
	
	timer_label = Label.new()
	timer_label.add_theme_font_size_override("font_size", 36)
	timer_label.add_theme_color_override("font_color", Color(1, 0.2, 0.1))
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	timer_label.offset_left = -100
	timer_label.offset_top = 160
	timer_label.offset_right = 100
	timer_label.offset_bottom = 200
	_update_timer_display()
	panel_layer.add_child(timer_label)
	
	if bomb_num <= 3:
		_create_wire_ui(panel_layer)
	else:
		_create_keyhole_ui(panel_layer)

func _create_wire_ui(cl: CanvasLayer) -> void:
	var y_start: float = 220
	var wire_h: float = 30
	var gap: float = 15
	
	wire_red = ColorRect.new()
	wire_red.color = Color(0.9, 0.1, 0.1)
	wire_red.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	wire_red.offset_left = -150
	wire_red.offset_top = y_start
	wire_red.offset_right = 150
	wire_red.offset_bottom = y_start + wire_h
	wire_red.mouse_filter = Control.MOUSE_FILTER_PASS
	cl.add_child(wire_red)
	
	var red_lbl: Label = Label.new()
	red_lbl.text = "--- RED ---"
	red_lbl.add_theme_font_size_override("font_size", 18)
	red_lbl.add_theme_color_override("font_color", Color.WHITE)
	red_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	red_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	red_lbl.offset_left = -150
	red_lbl.offset_top = y_start + 2
	red_lbl.offset_right = 150
	red_lbl.offset_bottom = y_start + wire_h
	red_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(red_lbl)
	
	wire_blue = ColorRect.new()
	wire_blue.color = Color(0.1, 0.3, 0.9)
	wire_blue.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	wire_blue.offset_left = -150
	wire_blue.offset_top = y_start + wire_h + gap
	wire_blue.offset_right = 150
	wire_blue.offset_bottom = y_start + wire_h * 2 + gap
	wire_blue.mouse_filter = Control.MOUSE_FILTER_PASS
	cl.add_child(wire_blue)
	
	var blue_lbl: Label = Label.new()
	blue_lbl.text = "--- BLUE ---"
	blue_lbl.add_theme_font_size_override("font_size", 18)
	blue_lbl.add_theme_color_override("font_color", Color.WHITE)
	blue_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	blue_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	blue_lbl.offset_left = -150
	blue_lbl.offset_top = y_start + wire_h + gap + 2
	blue_lbl.offset_right = 150
	blue_lbl.offset_bottom = y_start + wire_h * 2 + gap
	blue_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(blue_lbl)
	
	wire_green = ColorRect.new()
	wire_green.color = Color(0.1, 0.7, 0.2)
	wire_green.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	wire_green.offset_left = -150
	wire_green.offset_top = y_start + (wire_h + gap) * 2
	wire_green.offset_right = 150
	wire_green.offset_bottom = y_start + (wire_h + gap) * 2 + wire_h
	wire_green.mouse_filter = Control.MOUSE_FILTER_PASS
	cl.add_child(wire_green)
	
	var green_lbl: Label = Label.new()
	green_lbl.text = "--- GREEN ---"
	green_lbl.add_theme_font_size_override("font_size", 18)
	green_lbl.add_theme_color_override("font_color", Color.WHITE)
	green_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	green_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	green_lbl.offset_left = -150
	green_lbl.offset_top = y_start + (wire_h + gap) * 2 + 2
	green_lbl.offset_right = 150
	green_lbl.offset_bottom = y_start + (wire_h + gap) * 2 + wire_h
	green_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(green_lbl)

func _create_keyhole_ui(cl: CanvasLayer) -> void:
	keyhole_rect = ColorRect.new()
	keyhole_rect.color = Color(0.3, 0.3, 0.3)
	keyhole_rect.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	keyhole_rect.offset_left = -50
	keyhole_rect.offset_top = 220
	keyhole_rect.offset_right = 50
	keyhole_rect.offset_bottom = 280
	keyhole_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	cl.add_child(keyhole_rect)
	
	var slot_lbl: Label = Label.new()
	slot_lbl.text = "[ KEYHOLE ]"
	slot_lbl.add_theme_font_size_override("font_size", 20)
	slot_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	slot_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	slot_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	slot_lbl.offset_left = -50
	slot_lbl.offset_top = 220
	slot_lbl.offset_right = 50
	slot_lbl.offset_bottom = 280
	slot_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(slot_lbl)

func hide_panel() -> void:
	if panel_layer:
		cutting_mode = false
		if cutter_sprite:
			cutter_sprite.queue_free()
			cutter_sprite = null
		hovering_wire = ""
		panel_layer.queue_free()
		panel_layer = null
		timer_label = null
		wire_red = null
		wire_blue = null
		wire_green = null
		keyhole_rect = null

func _update_timer_display() -> void:
	if not timer_label:
		return
	var mins: int = int(time_left) / 60
	var secs: int = int(time_left) % 60
	timer_label.text = "%02d:%02d" % [mins, secs]
	
	if time_left < 30.0:
		timer_label.add_theme_color_override("font_color", Color(1, 0.1, 0.1))
	elif time_left < 60.0:
		timer_label.add_theme_color_override("font_color", Color(1, 0.5, 0.1))
