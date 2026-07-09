extends Area2D

var mouse_detected : bool = false


func _on_mouse_entered() -> void:
	mouse_detected = true


func _on_mouse_exited() -> void:
	mouse_detected = false
