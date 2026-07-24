extends CharacterBody2D

@export var spd: float = 300.0
@export var bat: float = 100.0

@onready var d = $Sprite
@onready var light = $Sprite/Torch
@onready var comp = $Compass

var inv: Array[String] = ["", ""]
var on: bool = false
var tgt: Node2D = null
var tut_tgt: Node2D = null

func _ready() -> void:
	add_to_group("player")

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
	var dir := Vector2(x, y)
	if x != 0.0 and y != 0.0:
		velocity = dir * spd * 1.2
	else:
		velocity = dir * spd

func look() -> void:
	d.look_at(get_global_mouse_position())

func keys() -> void:
	if Input.is_key_pressed(KEY_T):
		if "torch" in inv:
			on = !on
			light.visible = on
	if Input.is_key_pressed(KEY_Q):
		drop()
	if Input.is_key_pressed(KEY_E):
		if tgt and tgt.has_method("use"):
			tgt.use()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and tgt:
		if tgt.is_in_group("item"):
			pick(tgt)

func pick(i: Node2D) -> void:
	if inv[0] == "":
		inv[0] = i.id
	elif inv[1] == "":
		inv[1] = i.id
	else:
		drop_slot(0)
		inv[0] = i.id
	if i.id == "torch":
		tut("fuse")
	i.queue_free()

func drop() -> void:
	if inv[1] != "":
		spwn(inv[1])
		inv[1] = ""
	elif inv[0] != "":
		spwn(inv[0])
		inv[0] = ""

func drop_slot(i: int) -> void:
	if inv[i] != "":
		spwn(inv[i])
		inv[i] = ""

func spwn(id: String) -> void:
	var s = load("res://item.tscn")
	var i = s.instantiate()
	i.id = id
	i.global_position = global_position
	get_parent().add_child(i)

func upd_bat(delta: float) -> void:
	if on and bat > 0.0:
		bat -= delta * 1.5
		light.energy = bat / 100.0
		if bat <= 0.0:
			on = false
			light.visible = false

func tut(id: String) -> void:
	if id == "torch":
		tut_tgt = get_tree().get_first_node_in_group("torch_item")
	elif id == "fuse":
		tut_tgt = get_tree().get_first_node_in_group("fuse_box")

func no_tut() -> void:
	tut_tgt = null
	comp.visible = false

func upd_comp() -> void:
	if tut_tgt:
		comp.visible = true
		comp.look_at(tut_tgt.global_position)
	else:
		comp.visible = false
