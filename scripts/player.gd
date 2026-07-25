extends CharacterBody2D

@export var spd: float = 300.0
@export var bat: float = 100.0

@onready var d: Sprite2D = $Sprite
@onready var comp: Node2D = $Compass
@onready var l_hand: Node2D = $Sprite/LHand
@onready var r_hand: Node2D = $Sprite/RHand
@onready var sub_label: Label = $SubLabel

var l_item: String = ""
var torch_held: bool = false
var torch_on: bool = false
var tgt: Node2D = null
var tut_tgt: Node2D = null
var txt_timer: SceneTreeTimer = null
var l_hand_node: Node2D = null
var r_hand_node: Node2D = null

func _ready() -> void:
	tut("intro")

func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")
	move()
	look()
	keys()
	upd_bat(delta)
	upd_comp()
	move_and_slide()

func move() -> void:
	var x := Input.get_axis("left", "right")
	var y := Input.get_axis("up", "down")
	var dir := Vector2(x, y).normalized()
	velocity = dir * spd * (1.3 if x != 0.0 and y != 0.0 else 1.0)

func look() -> void:
	d.look_at(get_global_mouse_position())

func keys() -> void:
	if Input.is_action_just_pressed("toggle_torch"):
		if torch_held:
			torch_on = !torch_on
			update_torch_light_state()

	if Input.is_action_just_pressed("interact"):
		_interact_target()

	if Input.is_action_just_pressed("drop_item"):
		drop_left()

func _interact_target() -> void:
	if is_instance_valid(tgt):
		if tgt.has_method("use"):
			tgt.use()
		elif tgt.is_in_group("item"):
			pick(tgt)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_instance_valid(tgt):
			if tgt.has_method("use"):
				tgt.use()
			elif tgt.is_in_group("item"):
				pick(tgt)

func pick(i: Node2D) -> void:
	if not is_instance_valid(i) or i.is_queued_for_deletion():
		return

	if i.is_in_group("fuse_box") or i.get("id") == "fuse" or i.get("id") == "fuse_box":
		return

	var item_id: String = i.get("id") if "id" in i else ""

	if item_id == "torch":
		if r_hand_node:
			drop_right()
		i.reparent(r_hand)
		i.position = Vector2.ZERO
		i.rotation = 0
		i.remove_from_group("item")
		r_hand_node = i
		torch_held = true
		torch_on = true
		update_torch_light_state()
		tut("fuse")
	else:
		if l_hand_node:
			drop_left()
		i.reparent(l_hand)
		i.position = Vector2.ZERO
		i.rotation = 0
		i.remove_from_group("item")
		l_hand_node = i
		l_item = item_id

	tgt = null

func update_torch_light_state() -> void:
	if not r_hand_node:
		return
	
	var light_node: PointLight2D = null
	
	for child in r_hand_node.get_children():
		if child is PointLight2D:
			light_node = child
			break
	
	if not light_node and r_hand_node is PointLight2D:
		light_node = r_hand_node

	if light_node:
		light_node.visible = torch_on
		light_node.enabled = torch_on
		light_node.energy = (bat / 100.0) if torch_on else 0.0

func drop_left() -> void:
	if not l_hand_node:
		return
	
	var dropped: Node2D = l_hand_node
	dropped.reparent(get_parent())
	dropped.global_position = global_position + Vector2(30, 0).rotated(d.rotation)
	dropped.add_to_group("item")
	l_hand_node = null
	l_item = ""

func drop_right() -> void:
	if not r_hand_node:
		return
	
	var dropped: Node2D = r_hand_node
	dropped.reparent(get_parent())
	dropped.global_position = global_position + Vector2(-30, 0).rotated(d.rotation)
	dropped.add_to_group("item")
	r_hand_node = null
	torch_held = false
	torch_on = false

func drop() -> void:
	if l_item != "":
		drop_left()
	elif torch_held:
		drop_right()

func has_item(item_id: String) -> bool:
	if item_id == "torch":
		return torch_held
	return l_item == item_id

func consume_item(item_id: String) -> void:
	if item_id == "torch":
		if r_hand_node:
			r_hand_node.queue_free()
			r_hand_node = null
			torch_held = false
			torch_on = false
		return
	
	if l_item == item_id:
		if l_hand_node:
			l_hand_node.queue_free()
			l_hand_node = null
		l_item = ""

func upd_bat(delta: float) -> void:
	if torch_on and torch_held:
		if bat > 0.0:
			bat -= delta * 1.5
			update_torch_light_state()
			if bat <= 0.0:
				torch_on = false
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
		txt("*snoring*", 2.5)
	elif id == "torch":
		txt("*lights go out*", 3.0)
		tut_tgt = get_tree().get_first_node_in_group("torch_item")
	elif id == "fuse":
		txt("i should check the fuse box", 4.0)
		tut_tgt = get_tree().get_first_node_in_group("fuse_box")

func no_tut() -> void:
	tut_tgt = null
	comp.visible = false

func upd_comp() -> void:
	if tut_tgt and is_instance_valid(tut_tgt):
		comp.visible = true
		comp.look_at(tut_tgt.global_position)
	else:
		comp.visible = false
