extends CanvasLayer

@onready var button : TextureButton = get_node("VBoxContainer/MenuActivator")
@onready var options : MarginContainer = get_node("VBoxContainer/OptionsContainer")
@onready var mentor_toggle : Button = get_node("VBoxContainer/OptionsContainer/Options/ToggleMentor")
@export var expanded_size : Vector2 = Vector2i(128, 600)
var can_drag : bool = false
var drag : bool = false
func _ready() -> void:
	button.pressed.connect(_handle_mouse_input)
	if Weaver._windows.has("Your Mentor"):
		mentor_toggle.text = "Dismiss Mentor"
	else:
		mentor_toggle.text = "Beckon Mentor"
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed && can_drag:
			drag = true
		elif event.button_index == MOUSE_BUTTON_LEFT && event.is_released():
			drag = false
			
func _process(delta: float) -> void:
	if drag:
		#get_window().start_drag()
		var drag_offset = get_window().size/2
		var mouse_pos =  DisplayServer.mouse_get_position()
		var window_pos = mouse_pos - Vector2i(drag_offset.x, drag_offset.y)
		DisplayServer.window_set_position(window_pos, get_window().get_window_id())
		#get_window().position = 
func _on_activation():
	options.visible = !options.visible
func _on_held():
	drag = true
func _on_release():
	drag = false


func _on_close_menu_pressed() -> void:
	options.visible = false
	drag = false
	can_drag = false
func _on_toggle_mentor_pressed() -> void:
	if Weaver._windows.has("Your Mentor"):
		Weaver.seal("Your Mentor")
		mentor_toggle.text = "Beckon Mentor"
	else:
		Weaver.SummonMentor()
		mentor_toggle.text = "Dismiss Mentor"


func _on_exit_application_pressed() -> void:
	get_tree().quit()


func _on_journal_pressed() -> void:
	if Weaver._windows.has("Journal"):
		return
	Weaver.OpenJournal()
	
func _handle_mouse_input():
	if options.visible:
		can_drag = true
	else:
		_on_activation()
		can_drag = false
		drag = false


func _on_settings_pressed() -> void:
	if Weaver._windows.has("Settings"):
		return
	Weaver.OpenSettings()
