extends CharacterBody2D

@export var speed: float = 300.0

@onready var d = $"Sprite"

func _physics_process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")
	move()
	look()
	move_and_slide()

func move() -> void:
	var i_x := Input.get_axis("left", "right")
	var i_y := Input.get_axis("up", "down")
	var move_dir := Vector2(i_x, i_y)
	if i_x != 0.0 and i_y != 0.0:
		velocity = move_dir * speed * 1.2
	# promote use of zigzag diagonal movement, this is an intended mechanic - Ali
	else:
		velocity = move_dir * speed

func look() -> void:
	d.look_at(get_global_mouse_position())
