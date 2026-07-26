extends Area2D
var done: bool = false
var near: bool = false

func _process(delta: float) -> void:
	if done:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _ready() -> void:
	add_to_group("fuse_box")
	body_entered.connect(_in)
	body_exited.connect(_out)

func use() -> void:
	if near and not done and get_parent().state == 'won':
		done = true
		get_tree().current_scene.sab()

func _in(b: Node2D) -> void:
	if b.is_in_group("player"):
		near = true
		b.tgt = self

func _out(b: Node2D) -> void:
	if b.is_in_group("player"):
		near = false
		if b.tgt == self:
			b.tgt = null
