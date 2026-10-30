extends CanvasLayer

@onready var talk_interval = $TabContainer/Mentor/MarginContainer/VBoxContainer/TalkIntervalContainer/TalkInterval
@onready var dialog_close_interval = $TabContainer/Mentor/MarginContainer/VBoxContainer/DialogCloseContainer/DialogClose
@onready var quite_time_interval =$TabContainer/Mentor/MarginContainer/VBoxContainer/QuietTimeInterval/QuietTime
@onready var talk_interval_display= $TabContainer/Mentor/MarginContainer/VBoxContainer/TalkIntervalContainer/TalkIntervalValueLabel
@onready var dialog_close_display= $TabContainer/Mentor/MarginContainer/VBoxContainer/DialogCloseContainer/DialogCloseValueLabel
@onready var quiet_time_display= $TabContainer/Mentor/MarginContainer/VBoxContainer/QuietTimeInterval/QuietTimeValueLabel
@onready var window_options = $TabContainer/System/MarginContainer/VBoxContainer/MainWindowContiner/WindowOptions
func _ready() -> void:
	Weaver.focused_window_open.emit()
	talk_interval.value_changed.connect(_on_talk_value_changed)
	dialog_close_interval.value_changed.connect(_on_dialog_close_value_changed)
	quite_time_interval.value_changed.connect(_on_quite_time_value_changed)
	talk_interval.value = System.WaitToTalkInterval
	dialog_close_interval.value = System.WaitToCloseDialogInterval
	quite_time_interval.value = System.QuietTimeInterval/60
	talk_interval.changed.emit()
	for i in range(DisplayServer.get_screen_count()):
		window_options.add_item("Display " + str(i),i)
	window_options.set_item_id(System.MainWindow, System.MainWindow)
	window_options.item_selected.connect(_on_window_selected)
	get_node("Apply").pressed.connect(_on_apply)
	get_node("Exit").pressed.connect(_on_exit)
	
func _on_apply():
	System.WaitToCloseDialogInterval = dialog_close_interval.value
	System.WaitToTalkInterval = talk_interval.value
	System.QuietTimeInterval = quite_time_interval.value * 60
	System.save_settings()
	System.save_main_window()
	_on_exit()
func _on_exit():
	Weaver.focused_window_closed.emit()
	Weaver.seal(get_window().title)
func _on_talk_value_changed(val):
	talk_interval_display.text = str(val) + " seconds"
func _on_dialog_close_value_changed(val):
	dialog_close_display.text = str(val) + " seconds"
func _on_quite_time_value_changed(val):
	quiet_time_display.text = str(val) + " minutes"
func _on_window_selected(index : int):
	System.MainWindow = index
	
