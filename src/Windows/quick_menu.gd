extends CanvasLayer

@onready var button : TextureButton = get_node("VBoxContainer/MenuActivator")
@onready var options : MarginContainer = get_node("VBoxContainer/OptionsContainer")
@onready var mentor_toggle : Button = get_node("VBoxContainer/OptionsContainer/Options/ToggleMentor")
@onready var quiet_buton : Button = get_node("VBoxContainer/OptionsContainer/Options/Quiet")
@onready var quiet_timer_label: Label = get_node("VBoxContainer/OptionsContainer/Options/PanelContainer/Quiet Timer")
@export var expanded_size : Vector2 = Vector2i(128, 600)
var quick_menu_icon_closed : CompressedTexture2D
var quick_menu_icon_open : CompressedTexture2D
var can_drag : bool = false
var drag : bool = false
var is_in_quiet_time : bool = false
var sigil_hover : bool = false
var current_time: float = 0
var quiet_button_text = "Ask for Quiet Time"
signal quiet_time_set(is_on)
func _ready() -> void:
	quick_menu_icon_closed =  load("res://assets/ui/QuickMenuIconClosed.png")
	quick_menu_icon_open = load("res://assets/ui/QuickMenuIconOpen.png")
	button.pressed.connect(_handle_mouse_input)
	button.mouse_entered.connect(_on_sigil_hovered)
	button.mouse_exited.connect(_on_sigil_dormat)
	if Weaver._windows.has("Your Mentor"):
		mentor_toggle.text = "Dismiss Mentor"
	else:
		mentor_toggle.text = "Beckon Mentor"
	button.activate.connect(_on_activation)
	button.draging.connect(_on_drag)
			
func _process(delta: float) -> void:
	if drag && sigil_hover:
		var drag_offset = button.position + button.texture_normal.get_size()/2
		var mouse_pos =  DisplayServer.mouse_get_position()
		var window_pos = mouse_pos - Vector2i(drag_offset.x, drag_offset.y)
		DisplayServer.window_set_position(window_pos, get_window().get_window_id())
	if current_time <= 0 && !quiet_buton.text.contains(quiet_button_text):
		quiet_buton.text = quiet_button_text
		quiet_timer_label.get_parent().visible =  false
	elif current_time > 0:
		if !quiet_buton.text.contains("Focusing..."):
			quiet_buton.text = "Focusing..."
		current_time -= delta
		_on_quite_time_update()	
func _on_activation():
	options.visible = !options.visible
	if options.visible:
		button.texture_normal = quick_menu_icon_open
	else:
		button.texture_normal = quick_menu_icon_closed
func _on_close_menu_pressed() -> void:
	_on_activation()
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
		can_drag = false
		drag = false
func _on_settings_pressed() -> void:
	if Weaver._windows.has("Settings"):
		return
	Weaver.OpenSettings()
func _on_quiet_pressed() -> void:
	is_in_quiet_time = !is_in_quiet_time
	quiet_time_set.emit(is_in_quiet_time)
	quiet_timer_label.get_parent().visible = is_in_quiet_time
	if is_in_quiet_time:
		current_time = System.QuietTimeInterval
	else:
		current_time = 0
		quiet_buton.text = quiet_button_text
func _on_quite_time_update():
	quiet_timer_label.text = _convert_time() 

func _convert_time() -> String:
	var time : String = ""
	if current_time/3600 >= 1:
		time = str((current_time/3600) as int)+ ":" + str((fmod(current_time,3600)/60) as int) + ":" + str(fmod(fmod(current_time,3600),60) as int)
	else:
		time  = str((current_time/60) as int) + ":" + str(fmod(current_time,60))
	return time
func _on_drag(val: bool):
	drag = val
func _on_sigil_hovered():
	sigil_hover = true
func _on_sigil_dormat():
	sigil_hover = false
