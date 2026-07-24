extends Area2D

@export var req: String = "cutter"

var done: bool = false
var near: bool = false

func _ready() -> void:
	body_entered.connect(_in)
	body_exited.connect(_out)

func use() -> void:
	if near and not done:
		var p = get_tree().get_first_node_in_group("player")
		if req in p.inv:
			done = true
			get_tree().current_scene.defuse()

func _in(b: Node2D) -> void:
	if b.is_in_group("player"):
		near = true
		b.tgt = self

func _out(b: Node2D) -> void:
	if b.is_in_group("player"):
		near = false
		if b.tgt == self:
			b.tgt = null
