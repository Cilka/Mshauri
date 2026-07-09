extends Window

@onready var _Camera: Camera2D = $Camera2D

var last_position: = Vector2i.ZERO
var velocity: = Vector2i.ZERO
var ui_view_only :bool = false
func _ready() -> void:
	# Set the anchor mode to "Fixed top-left"
	# Easier to work with since it corresponds to the window coordinates
	#_Camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	
	transient = true # Make the window considered as a child of the main window
	close_requested.connect(queue_free) # Actually close the window when clicking the close button
	close_requested.connect(_on_close_requested)
func _process(delta: float) -> void:
	if ui_view_only:
		position = position
		return
	velocity = position - last_position
	last_position = position
	_Camera.position = get_camera_pos_from_window()

func get_camera_pos_from_window()->Vector2i:
	return position + velocity
#works for windows that have a canvas layer and at least one control with min size
#set
func resize_to_control():
	var control =  get_child(1).get_child(0) as Control
	if !control:
		print_debug("cannot find first control node in canvase layer")
		return
	min_size = Vector2i(control.custom_minimum_size.x,control.custom_minimum_size.y)
func _on_close_requested():
	#TODO: Add yield functionality to 
	queue_free()
