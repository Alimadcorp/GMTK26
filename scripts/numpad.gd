extends GridContainer

func _on_button_pressed(source: BaseButton) -> void:
	var i = source.name.replace("Button", "")
	get_parent().get_parent().get_parent().get_parent().get_parent().numpad(i)
