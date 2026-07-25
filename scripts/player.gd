extends CharacterBody2D

@export var spd: float = 300.0
@export var bat: float = 100.0

@onready var d = $Sprite
@onready var comp = $Compass
@onready var l_hand = $Sprite/LHand
@onready var r_hand = $Sprite/RHand
@onready var sub_label = $Camera2D/Label

# left, right
var inv: Array = [null, null] 
var on: bool = false
var tgt: Node2D = null
var tut_tgt: Node2D = null
var txt_timer: SceneTreeTimer = null

func _ready() -> void:
	tut("intro")

var time = 123

func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")
	move()
	look()
	keys()
	upd_bat(delta)
	upd_comp()
	move_and_slide()

func _process(delta: float) -> void:
	var minutes: int = int(time) / 60
	var seconds: int = int(time) % 60
	var text = "%02d:%02d" % [minutes, seconds]
	$CanvasLayer/bomb/Panel/TextureRect/Label.text = text
	if $CanvasLayer/bomb.visible == true:
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
		if inv[0] != null and inv[0]["id"] == "torch":
			on = !on
			update_torch_light_state()

	if Input.is_action_just_pressed("drop_item"):
		drop()

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

	var current_tgt = i
	tgt = null

	var item_data = {
		"id": current_tgt.id,
		"scale": current_tgt.scale,
		"rotation": current_tgt.rotation
	}

	var slot_idx: int = 0
	if current_tgt.id == "torch":
		slot_idx = 0
		if inv[0] != null:
			drop_slot(0)
	else:
		if inv[0] == null:
			slot_idx = 0
		elif inv[1] == null:
			slot_idx = 1
		else:
			drop_slot(0)
			slot_idx = 0

	inv[slot_idx] = item_data
	attach_hand_visual(slot_idx, current_tgt)

	if current_tgt.id == "torch":
		tut("fuse")

	current_tgt.queue_free()

func attach_hand_visual(slot_idx: int, original_node: Node2D) -> void:
	var hand_node = l_hand if slot_idx == 0 else r_hand
	
	for child in hand_node.get_children():
		child.queue_free()
		
	var visual = original_node.duplicate()
	visual.position = Vector2.ZERO
	visual.rotation = 0
	visual.remove_from_group("item")
	
	hand_node.add_child(visual)

	if slot_idx == 0 and original_node.id == "torch":
		on = true
		update_torch_light_state()

func update_torch_light_state() -> void:
	var light_node = l_hand.find_child("*Light*", true, false)
	if not light_node:
		light_node = l_hand.find_child("*Torch*", true, false)

	if not light_node:
		for child in l_hand.get_children():
			if child is PointLight2D:
				light_node = child
				break
			elif child.has_node("PointLight2D"):
				light_node = child.get_node("PointLight2D")
				break

	if light_node and light_node is PointLight2D:
		light_node.visible = on
		light_node.enabled = on
		light_node.energy = (bat / 100.0) if on else 0.0

func drop() -> void:
	if inv[1] != null:
		drop_slot(1)
	elif inv[0] != null:
		drop_slot(0)

func drop_slot(idx: int) -> void:
	if inv[idx] != null:
		spwn(inv[idx])
		inv[idx] = null
		
		var hand_node = l_hand if idx == 0 else r_hand
		for child in hand_node.get_children():
			child.queue_free()
			
		if idx == 0:
			on = false

func spwn(item_data: Dictionary) -> void:
	var s = load("res://item.tscn")
	var i = s.instantiate()
	i.id = item_data["id"]
	i.scale = item_data["scale"]
	i.global_position = global_position + Vector2(30, 0).rotated(rotation)
	get_parent().add_child(i)

func has_item(item_id: String) -> bool:
	for slot in inv:
		if slot != null and slot["id"] == item_id:
			return true
	return false

func consume_item(item_id: String) -> void:
	for i in range(inv.size()):
		if inv[i] != null and inv[i]["id"] == item_id:
			inv[i] = null
			var hand_node = l_hand if i == 0 else r_hand
			for child in hand_node.get_children():
				child.queue_free()
			if i == 0 and item_id == "torch":
				on = false
			break

func upd_bat(delta: float) -> void:
	if on and inv[0] != null and inv[0]["id"] == "torch":
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

func toggle_bomb():
	$CanvasLayer/bomb.visible = !$CanvasLayer/bomb.visible
