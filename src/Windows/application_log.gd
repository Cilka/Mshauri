extends CanvasLayer

@onready var log_container = get_node("Panel/logcontainer/VBoxContainer")
var app_row =preload("res://src/Windows/Components/app_header.tscn") as PackedScene


#TODO: use conch to load the application data for each app row
func _ready() -> void:
	pass
