extends Node

func _ready() -> void:
	var si : StatusIndicator = StatusIndicator.new()
	si.icon = load("res://icon.svg")
	si.tooltip = "Mshauri is running"
	add_child(si)
	DisplayServer.status_indicator_set_icon(2,load("res://icon.svg") as Texture2D)
