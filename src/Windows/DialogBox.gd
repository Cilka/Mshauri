extends CanvasLayer
#TODO: Try to figure out why clicking on canvas does not close window
var dialog : PackedStringArray
var current_text_speed : float = 0
var _section : int = 0
var _can_close_window : bool = false
var autoclose: bool = false
var choice_select = load("res://src/Windows/Components/ChoiceSelection.tscn") as PackedScene
@onready var message_box : RichTextLabel = $NinePatchRect/MarginContainer/Panel/VBoxContainer/Message
@onready var dialog_panel = $NinePatchRect/MarginContainer/Panel/VBoxContainer
@onready var type_timer : Timer = get_node("TypeTimer")
@onready var pause_timer : Timer = get_node("PauseTimer")
@onready var autoclose_timer : Timer = get_node("AutoCloseTimer")
@onready var processor = get_node("WordProcessor") as WordProcessor
@onready var border = $NinePatchRect
signal talking

func _ready():
	talking.connect(_on_talk_ready)
	EventFlagger.dialog_request.connect(_on_dialog_request)
func _process(delta:float) -> void:
	if dialog && _section >= dialog.size():
		_can_close_window = true
func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT)\
	|| (Input.is_action_just_pressed("accept")):
		print_debug("Text box gfound mouse")
		if is_talking():
			message_box.visible_characters = message_box.text.length()
			type_timer.stop()
		elif !is_talking() && _section < dialog.size():
			talking.emit()
		else:
			if _can_close_window:
				get_parent().close_requested.emit
			
func add_text(text: String, speed: float = System.TextSpeed) -> void:
	dialog = text.split("<br\\>")
	current_text_speed = speed
	_can_close_window = false
	talking.emit()
	
func say() -> void:
	if dialog == null:
		return
	var filtered_text = processor.extract_flags_from_string(dialog[_section])
	if current_text_speed <= 0:
		message_box.bbcode_text = filtered_text
	else:
		message_box.bbcode_text = filtered_text
		message_box.visible_characters = 0
		type_timer.start()
		pass
	_section =  _section + 1
func set_conversation(convo: Dialectic) -> void:	
	add_text(convo.sentence)
	if convo.choices == null || convo.choices.size() ==0:
		return
	var choices = choice_select.instantiate()
	dialog_panel.add_child(choices)
	choices.setup(convo.choices)
	choices.visible = false
	choices.choice_selected.connect(_on_choice_selected.bind(convo.choices))
func _on_type_timer_timeout() -> void:	
	if is_talking():
		message_box.visible_characters += 1
		processor.check_at_position(message_box.visible_characters)
	elif !is_talking()\
	 && _section >= dialog.size():
		_can_close_window = true
		type_timer.stop()
		if autoclose:
			autoclose_timer.start()
			autoclose_timer.timeout.connect(_on_autoclose_timer_timeout)
	else:
		type_timer.stop()
	#if !is_talking() \
	#&& get_node("NinePatchRect/MarginContainer/Panel/VBoxContainer/ChoiceSelection"):
		#get_node("NinePatchRect/MarginContainer/Panel/VBoxContainer/ChoiceSelection")\
		#.visible = true
func _on_talk_ready():
	Weaver.ShowDialogWindow()
	say()
func is_talking() -> bool:
	return message_box.visible_characters < message_box.text.length()
func _close_out():
	var tween = create_tween()
	tween.finished.connect(_on_tween_finished)
	tween.tween_property(border, "position",Vector2(0,200),1).set_ease(Tween.EASE_IN_OUT)
func _on_tween_finished():
	queue_free()
	Weaver.HideDialogWindow()
func _on_autoclose_timer_timeout():
	_close_out()
	#get_parent().close_requested.emit()
func _on_PauseCalculator_pause_requested(duration: float) -> void:
#	_playing_voice = false
	type_timer.stop()
	pause_timer.wait_time = duration
	pause_timer.start()
	
func _on_PauseTimer_timeout() -> void:
#	_playing_voice = true
#	voice_player.play(0)
	type_timer.start()
func _on_dialog_request(function : String, args : Array):
	type_timer.stop()
	match function:
		"OpenInput":
			Weaver.OpenInput()
			pass
func _on_choice_selected(index :int, choices:Array[WordFlow]):
	#probably should figure out what to do with goto
	get_node("NinePatchRect/MarginContainer/Panel/VBoxContainer/ChoiceSelection")\
	.queue_free()
	_section =0
	set_conversation(choices[index].dialog)
