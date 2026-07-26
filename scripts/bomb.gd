extends Area2D

@export var req: String = "cutter"

var done: bool = false
var near: bool = false

@export var wire = "red"

func _ready() -> void:
	body_entered.connect(_in)
	body_exited.connect(_out)

func use() -> void:
	# TODO: ok guys this is not the right way, 
	# when the player left clocks on a bomb which has req == 'pliers'
	# it is actually a left click on the bomb UI
	# we have to determine which wire was clicked, and if that specific wire correct
	# then we make the bomb diffused (call game_manager.diffuse())
	if near and not done:
		var p = get_tree().get_first_node_in_group("player")
		if p and p.has_item(req):
			p.consume_item(req)
			done = true
			get_tree().current_scene.defuse()
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if(body.has("key") and req == "key"):
			get_tree().current_scene.defuse()
		elif req == "pliers":
			body.toggle_bomb(true, true)
			body.setcorwire(wire)
		else:
			body.toggle_bomb(false,false)

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
