extends Node
@export var _window : PackedScene
@export var _dialog_box: PackedScene
@export var _settings: PackedScene
@export var _mentor: PackedScene
@export var _quick_menu : PackedScene
@export var _choice_box: PackedScene

var _window_count : int =0
var _windows : Dictionary[String,Window]
var dialog_box_window 
signal focused_window_open
signal focused_window_closed
func _ready() -> void:
	if !_window:
		_window = load("res://src/Windows/ViewWindow.tscn")
	if !_dialog_box:
		_dialog_box = load("res://src/Windows/Dialog.tscn")
	if !_settings:
		_settings = load("res://src/Windows/ControlBoard.tscn")
	if !_mentor:
		_mentor = load("res://src/Friend.tscn")
	if !_quick_menu:
		_quick_menu = load("res://src/Windows/QuickMenu.tscn")
	if !_choice_box:
		_choice_box = load("res://src/Windows/DialogOption.tscn")
	dialog_box_window = get_node("/root/Main/DialogBox")
func OpenDialog(window_pos : Vector2i, convo :Dialectic) -> Window:	
	var talk = _dialog_box.instantiate()
	var new_window = _weave(window_pos,talk)
	talk.set_conversation(convo)
	talk.autoclose = false	
	return _windows[new_window.title]
	
func OpenSimpleDialog(window_pos : Vector2i, text :String, autoclose :bool = false) -> Window:	
	var talk = _dialog_box.instantiate()
	dialog_box_window.add_child(talk)
	talk.add_text(text, System.TextSpeed)
	talk.autoclose = autoclose
	return dialog_box_window
	
func OpenChoiceDialog(window_pos: Vector2i, question: String, title: String,\
 options : Dictionary[String, Callable]):
	var choice_box =  _choice_box.instantiate()
	_weave(window_pos, choice_box, title)
	_windows[title]\
	.get_node("DialogOption/NinePatchRect/MarginContainer/ChoiceSelection")\
	.setup(question, options)
	
func OpenSettings(window_pos :Vector2i = Center()) -> Window:
	var settings_gui = _settings.instantiate()
	_weave(window_pos, settings_gui,"Settings")	
	return _windows["Settings"]
	
func SummonMentor(window_pos : Vector2i = TopLeft()):
	var m = _mentor.instantiate()
	_weave(window_pos, m, "Your Mentor", false)	
	_windows["Your Mentor"].visible =true
	_windows["Your Mentor"].unresizable = true
	_windows["Your Mentor"].transient=false
	_windows["Your Mentor"].borderless = true
	_windows["Your Mentor"].transparent_bg = true
	_windows["Your Mentor"].transparent = true
	_windows["Your Mentor"].always_on_top = true
	_windows["Your Mentor"].physics_object_picking = true
	_windows["Your Mentor"].initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
	_windows["Your Mentor"].content_scale_mode =Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	_windows["Your Mentor"].content_scale_aspect =Window.CONTENT_SCALE_ASPECT_KEEP
	_windows["Your Mentor"].add_to_group("Mentor")
	return _windows["Your Mentor"]
func OpenQuickMenu(window_pos: Vector2i =Center()):
	var q_menu = _quick_menu.instantiate()
	_weave(window_pos,q_menu, "Quick Menu")
	_windows["Quick Menu"].resize_to_control()
	_windows["Quick Menu"].borderless = false
	_windows["Quick Menu"].transparent = true
	_windows["Quick Menu"].transient = true
	_windows["Quick Menu"].transparent_bg = true
	_windows["Quick Menu"].WINDOW_INITIAL_POSITION_ABSOLUTE
	_windows["Quick Menu"].physics_object_picking = true

	return _windows["Quick Menu"]
func OpenJournal(window_pos: Vector2i = Center()):
	var journal = (load("res://src/Windows/Journal.tscn") as PackedScene).instantiate()
	_weave(window_pos, journal,"Journal")
	return _windows["Journal"]
func CurrentScreen() -> int:
	return DisplayServer.window_get_current_screen(get_window().get_window_id())
	
func Center() -> Vector2i:
	return  Vector2i(DisplayServer.screen_get_size(CurrentScreen()).x/2,DisplayServer.screen_get_size(CurrentScreen()).y/2 )

func TopLeft() -> Vector2i:
	return Vector2i()
func adjust_view(window: String, resize_to :Vector2):
	var old_pos = _windows[window].position
	_windows[window].size = Vector2i(resize_to.x, resize_to.y)
	_windows[window].position = old_pos
func _weave(window_pos : Vector2i,child: Node,window_title :String = "" ,is_ui : bool = true, popup: bool=false ) -> Node:
	var new_window = _window.instantiate()
		
	get_tree().root.get_node("/root/Main").add_child(new_window)
	new_window.ui_view_only = is_ui
	new_window.add_child(child)
	new_window.resize_to_control()
	new_window.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
	new_window.position =  window_pos
	_window_count += 1
	if window_title == "":
		window_title = "Window " + str(_window_count)
	new_window.title = window_title
	_windows[new_window.title] = new_window
	return new_window
func seal(window : String):
	if _windows.has(window):			
		_windows[window].close_requested.emit()
		_windows.erase(window)
func ShowDialogWindow():
	dialog_box_window.show()
func HideDialogWindow():
	dialog_box_window.hide()
