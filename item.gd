extends Area2D

@export var item_name: String = "torch"

@onready var sprite = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.target_item = self

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body.target_item == self:
		body.target_item = null
