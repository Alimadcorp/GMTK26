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
		if p and p.has_item(req):
			p.consume_item(req)
			done = true
			get_tree().current_scene.defuse()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.toggle_bomb()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.toggle_bomb()

func _in(b: Node2D) -> void:
	if b.is_in_group("player"):
		near = true
		b.tgt = self

func _out(b: Node2D) -> void:
	if b.is_in_group("player"):
		near = false
		if b.tgt == self:
			b.tgt = null
