extends CanvasLayer

@onready var button : TextureButton = get_node("MenuActivator")
@onready var options : MarginContainer = get_node("OptionsContainer")
@onready var mentor_toggle : Button = get_node("OptionsContainer/Options/ToggleMentor")
@export var collapsed_size : Vector2i = Vector2i(48,48)
@export var expanded_size : Vector2 = Vector2i(128, 600)
var drag : bool = false
func _ready() -> void:
	button.pressed.connect(_on_activation)
	button.button_down.connect(_on_held)
	button.button_up.connect(_on_release)
	get_parent().borderless = true
	get_parent().transparent = true
	if Weaver._windows.has("Your Mentor"):
		mentor_toggle.text = "Dismiss Mentor"
	else:
		mentor_toggle.text = "Beckon Mentor"
		
func _process(delta: float) -> void:
	if drag:
		get_window().position = DisplayServer.mouse_get_position()
func _on_activation():
	options.visible = !options.visible
	if options.visible:
		Weaver.adjust_view(get_parent().title, expanded_size)
	else:
		Weaver.adjust_view(get_parent().title, button.custom_minimum_size)
func _on_held():
	drag = true
func _on_release():
	drag = false


func _on_close_menu_pressed() -> void:
	options.visible = false
	Weaver.adjust_view(get_parent().title, button.custom_minimum_size)


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
	
