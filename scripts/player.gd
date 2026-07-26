extends CharacterBody2D

@export var speed: float = 1000.0
var spd = 0.0
@export var bat: float = 300.0

@onready var d = $Sprite
@onready var comp = $Compass
@onready var l_hand = $Sprite/LHand
@onready var r_hand = $Sprite/RHand
@onready var sub_label = $Camera2D/Label

var shouldpliers = false

var l_item: Node2D = null
var torch_item: Node2D = null
var pliers = false
var on: bool = false
var tgt: Node2D = null
var tut_tgt: Node2D = null
var txt_timer: SceneTreeTimer = null

var current_correct_wire

func _ready() -> void:
	add_to_group("player")
	tut("intro")

func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")
	if spd > 1:
		move()
		look()
		keys()
		upd_bat(delta)
		upd_comp()
		move_and_slide()

func _process(delta: float) -> void:
	var time = get_parent().time
	var minutes: int = int(time) / 60
	var seconds: int = int(time) % 60
	var text = "%02d:%02d" % [minutes, seconds]
	
	if has_node("CanvasLayer/bomb/Panel/TextureRect/Label"):
		$CanvasLayer/bomb/Panel/TextureRect/Label.text = text
		
	if $CanvasLayer/bomb.visible and pliers and shouldpliers:
		Input.set_custom_mouse_cursor(preload("res://assets/bomb/plieropen.png"))
		if Input.is_action_pressed("lmb"):
			Input.set_custom_mouse_cursor(preload("res://assets/bomb/plierclose.png"))
	else:
		Input.set_custom_mouse_cursor(null)

func move() -> void:
	var x := Input.get_axis("left", "right")
	var y := Input.get_axis("up", "down")
	var dir := Vector2(x, y).normalized()
	velocity = dir * spd * (1.3 if x != 0.0 and y != 0.0 else 1.0)

func look() -> void:
	d.look_at(get_global_mouse_position())

func keys() -> void:
	if Input.is_action_just_pressed("toggle_torch"):
		if is_instance_valid(torch_item):
			on = !on
			update_torch_light_state()

	if Input.is_action_just_pressed("drop_item"):
		drop_left_hand()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_instance_valid(tgt):
			if tgt.has_method("use"):
				tgt.use()
			elif tgt.is_in_group("item") or tgt.is_in_group("torch_item"):
				pick(tgt)

func pick(i: Node2D) -> void:
	if not is_instance_valid(i) or i.is_queued_for_deletion():
		return

	if i.is_in_group("fuse_box") or i.get("id") == "fuse" or i.get("id") == "fuse_box":
		return

	var item_id: String = i.get("id") if i.get("id") else ""

	if item_id == "torch":
		if is_instance_valid(torch_item):
			return
		
		torch_item = i
		torch_item.reparent(r_hand)
		torch_item.position = Vector2.ZERO
		torch_item.rotation = 0
		
		on = true
		update_torch_light_state()
		tut("fuse")
		tgt = null
		return
	elif item_id == "pliers":
		pliers = true

	if is_instance_valid(l_item):
		drop_left_hand()

	l_item = i
	l_item.reparent(l_hand)
	l_item.position = Vector2.ZERO
	l_item.rotation = 0
	tgt = null

func drop_left_hand() -> void:
	if is_instance_valid(l_item):
		l_item.reparent(get_parent())
		l_item.global_position = global_position + Vector2(30, 0).rotated(rotation)
		l_item = null

func update_torch_light_state() -> void:
	if not is_instance_valid(torch_item):
		return

	var light_node = torch_item.find_child("*Light*", true, false)
	if not light_node:
		light_node = torch_item.find_child("*Torch*", true, false)

	if not light_node:
		for child in torch_item.get_children():
			if child is PointLight2D:
				light_node = child
				break

	if light_node and light_node is PointLight2D:
		light_node.visible = on
		light_node.enabled = on
		light_node.energy = (bat / 100.0) if on else 0.0

func has_item(item_id: String) -> bool:
	if is_instance_valid(l_item) and l_item.get("id") == item_id:
		return true
	if is_instance_valid(torch_item) and torch_item.get("id") == item_id:
		return true
	return false

func has(item_id: String) -> bool:
	return has_item(item_id)

func consume_item(item_id: String) -> void:
	if is_instance_valid(l_item) and l_item.get("id") == item_id:
		l_item.queue_free()
		l_item = null

func upd_bat(delta: float) -> void:
	if on and is_instance_valid(torch_item):
		if bat > 0.0:
			bat -= delta * 1.5
			update_torch_light_state()
			if bat <= 0.0:
				on = false
				update_torch_light_state()

func txt(msg: String, duration: float = 3.0) -> void:
	if sub_label:
		sub_label.text = msg
		sub_label.visible = true
		if txt_timer:
			txt_timer.disconnect("timeout", Callable(self, "_clear_txt"))
		txt_timer = get_tree().create_timer(duration)
		txt_timer.timeout.connect(_clear_txt)

func _clear_txt() -> void:
	if sub_label:
		sub_label.visible = false

func tut(id: String) -> void:
	if id == "intro":
		txt("*bro sleeping...*", 2.5)
	elif id == "torch":
		txt("*lights go out*", 3.0)
		tut_tgt = get_tree().get_first_node_in_group("torch_item")
	elif id == "fuse":
		txt("i should check the fuse box", 4.0)
		tut_tgt = get_tree().get_first_node_in_group("fuse_box")
	elif id == "oh_shit":
		txt("ts has been sabotaged :noooovanish:", 4.0)

func no_tut() -> void:
	tut_tgt = null
	comp.visible = false

func upd_comp() -> void:
	if tut_tgt and is_instance_valid(tut_tgt):
		comp.visible = true
		comp.look_at(tut_tgt.global_position)
	else:
		comp.visible = false

func expl():
	$CanvasLayer/VideoStreamPlayer.play()

func toggle_bomb(val, plier):
	$CanvasLayer/bomb.visible = val
	shouldpliers = plier

func setcorwire(wire):
	current_correct_wire = wire

func _on_red_pressed() -> void:
	if current_correct_wire != "red":
		expl()

func _on_yellow_pressed() -> void:
	if current_correct_wire != "yellow":
		expl()

func _on_black_pressed() -> void:
	if current_correct_wire != "black":
		expl()
