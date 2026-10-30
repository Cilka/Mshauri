extends TextureButton

signal activate
signal draging(val)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click:
			activate.emit()
			return
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			draging.emit(true)
		elif event.button_index == MOUSE_BUTTON_LEFT && event.is_released():
			draging.emit(false)
			System.save_quick_menu_position(get_window().position)
