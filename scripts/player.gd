extends CharacterBody2D

@export var speed: float = 300.0
@export var torch_battery: float = 100.0

@onready var d = $Sprite
@onready var torch_light = $Sprite/Torch

var inv: Array[String] = ["", ""]
var torch_on: bool = false
var target_item: Node2D = null

func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")
	
	move()
	look()
	handle_input()
	update_torch(delta)
	move_and_slide()

func move() -> void:
	var i_x := Input.get_axis("left", "right")
	var i_y := Input.get_axis("up", "down")
	var move_dir := Vector2(i_x, i_y)
	if i_x != 0.0 and i_y != 0.0:
		velocity = move_dir * speed * 1.2
	else:
		velocity = move_dir * speed

func look() -> void:
	d.look_at(get_global_mouse_position())

func handle_input() -> void:
	if Input.is_action_just_pressed("toggle_torch") or Input.is_key_pressed(KEY_T):
		if "torch" in inv:
			torch_on = !torch_on
			torch_light.visible = torch_on

	if Input.is_action_just_pressed("drop_item") or Input.is_key_pressed(KEY_Q):
		drop_held()

	if Input.is_action_just_pressed("interact") or Input.is_key_pressed(KEY_E):
		use_item()

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and target_item:
		pick_up(target_item)

func pick_up(item: Node2D) -> void:
	if inv[0] == "":
		inv[0] = item.item_name
		item.queue_free()
	elif inv[1] == "":
		inv[1] = item.item_name
		item.queue_free()
	else:
		drop_slot(0)
		inv[0] = item.item_name
		item.queue_free()

func drop_held() -> void:
	if inv[1] != "":
		spawn_item(inv[1])
		inv[1] = ""
	elif inv[0] != "":
		spawn_item(inv[0])
		inv[0] = ""

func drop_slot(idx: int) -> void:
	if inv[idx] != "":
		spawn_item(inv[idx])
		inv[idx] = ""

func spawn_item(id: String) -> void:
	var item_scene = load("res://scenes/item.tscn")
	if item_scene:
		var inst = item_scene.instantiate()
		inst.item_name = id
		inst.global_position = global_position
		get_parent().add_child(inst)

func use_item() -> void:
	pass

func update_torch(delta: float) -> void:
	if torch_on and torch_battery > 0.0:
		torch_battery -= delta * 1.5
		torch_light.energy = torch_battery / 100.0
		if torch_battery <= 0.0:
			torch_on = false
			torch_light.visible = false
