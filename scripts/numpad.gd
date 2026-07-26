extends GridContainer

func _on_button_pressed(source: BaseButton) -> void:
	var i = source.name.replace("Button", "")
	get_tree().current_scene.numpad(i)
