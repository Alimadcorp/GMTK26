extends Area2D

@export var tex : String

func _on_body_entered(body: Node2D) -> void:
	if body.name == 'Player' and Input.is_action_just_pressed("interact"):
		body.show_note(tex)

func _on_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		body.show_note(tex, false)
