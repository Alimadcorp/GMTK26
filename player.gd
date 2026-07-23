extends CharacterBody2D

@export var speed: float = 300.0

@onready var d = $"Direction" # this coz rotating the player rotates the camera too

func _physics_process(_delta: float) -> void:
	move()
	look()
	move_and_slide()

func move() -> void:
	var i_x := Input.get_axis("left", "right")
	var i_y := Input.get_axis("up", "down")
	velocity = Vector2(i_x, i_y) * speed
	# we do not normalize velocity as i guess it makes speedrunning more interesting
	# when you have faster options to do basic things - Ali

func look() -> void:
	d.look_at(get_global_mouse_position())
