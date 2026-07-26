extends Area2D

@export var req: String = "cutter"

var done: bool = false
var near: bool = false

@export var wire = "red"

func _ready() -> void:
	body_entered.connect(_in)
	body_exited.connect(_out)

func use() -> void:
	if near and not done and req == 'key':
		var p = get_tree().get_first_node_in_group("player")
		if p and p.has_item(req):
			p.consume_item(req)
			done = true
			get_tree().current_scene.defuse()
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if req == "pliers":
			body.c_bomb = self
			body.toggle_bomb(true, true)
			body.setcorwire(wire)
		else:
			body.toggle_bomb(true, false)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.toggle_bomb(false, false)

func _in(b: Node2D) -> void:
	if b.is_in_group("player"):
		near = true
		b.tgt = self

func _out(b: Node2D) -> void:
	if b.is_in_group("player"):
		near = false
		if b.tgt == self:
			b.tgt = null
