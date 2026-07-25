extends Area2D

@export var id: String = "torch"

@onready var spr = $Sprite2D

var plr


func _ready() -> void:
	add_to_group("item")
	if id == "torch":
		add_to_group("torch_item")
	body_entered.connect(_in)
	body_exited.connect(_out)


func _in(b: Node2D) -> void:
	if b.is_in_group("player"):
		b.tgt = self
		spr.modulate = Color(2, 2, 2, 1)

func _out(b: Node2D) -> void:
	if b.is_in_group("player") and b.tgt == self:
		b.tgt = null
		spr.modulate = Color(1, 1, 1, 1)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.toggle_bomb()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.toggle_bomb()
