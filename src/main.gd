extends Node

@onready var cam : Camera2D = $Camera2D

@onready var _mainWindow: Window = get_window()
@onready var player_size: Vector2i = Vector2i(64,64)
@export_range(0, 19) var player_visibility_layer: int = 1
@export_range(0, 19) var world_visibility_layer: int = 0
@onready var _main_camera: Camera2D = $Camera2D
var mentor_window
var mentor : Mentor
var has_profile : bool = false
signal profile_in_progress
func _ready():
	get_tree().get_root().set_transparent_background(true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# Can also break on some systems
	ProjectSettings.set_setting("display/window/per_pixel_transparency/allowed", true)
	#mentor_window = Weaver.SummonMentor()
	#System tray is not supported in 4.4.1 for Linux Systems
	#if OS.get_name() == "Linux":
		#Weaver.OpenQuickMenu()
	# Set the window settings - most of them can be set in the project settings
	_mainWindow.borderless = true		# Hide the edges of the window
	_mainWindow.unresizable = true		# Prevent resizing the window
	_mainWindow.always_on_top = true	# Force the window always be on top of the screen
	_mainWindow.gui_embed_subwindows = false # Make subwindows actual system windows <- VERY IMPORTANT
	_mainWindow.transparent = true		# Allow the window to be transparent
	# Settings that cannot be set in project settings
	_mainWindow.transparent_bg = true	# Make the window's background transparent
	_mainWindow.min_size = player_size
	_mainWindow.size = _mainWindow.min_size
	_mainWindow.mouse_passthrough = true
	_mainWindow.set_canvas_cull_mask_bit(player_visibility_layer, false)
	_mainWindow.set_canvas_cull_mask_bit(world_visibility_layer, true)
	
	#mentor_window.set_canvas_cull_mask_bit(player_visibility_layer, true)
	#mentor_window.set_canvas_cull_mask_bit(world_visibility_layer, false)	
	#
	#mentor_window.get_viewport().world_2d = get_viewport().world_2d
	#mentor = _get_mentor()
	profile_in_progress.connect(_setup_profile)
	if !has_profile:
		profile_in_progress.emit()

func _process(delta: float) -> void:
	cam.position = get_window().position
	_mainWindow.position= get_window_pos_from_camera()
	pass

func _get_mentor() -> Mentor:
	if get_tree().get_first_node_in_group("Mentor"):
		return get_tree().get_first_node_in_group("Mentor")
	return null
	#add ability to read mentor data chosen by the mentee

func get_window_pos_from_camera()->Vector2i:
	return Vector2i(_main_camera.global_position + _main_camera.offset) - player_size / 2

func _setup_profile():
	var fts = load("res://assets/FirstTimeSetupDialog.tres") as Dialectic
	Weaver.OpenDialog(Weaver.Center(),fts)
