extends CanvasLayer

@onready var talk_interval = $TabContainer/Mentor/MarginContainer/VBoxContainer/TalkIntervalContainer/TalkInterval
@onready var dialog_close_interval = $TabContainer/Mentor/MarginContainer/VBoxContainer/DialogCloseContainer/DialogClose
@onready var quite_time_interval =$TabContainer/Mentor/MarginContainer/VBoxContainer/QuietTimeInterval/QuietTime
@onready var talk_interval_display= $TabContainer/Mentor/MarginContainer/VBoxContainer/TalkIntervalContainer/TalkIntervalValueLabel
@onready var dialog_close_display= $TabContainer/Mentor/MarginContainer/VBoxContainer/DialogCloseContainer/DialogCloseValueLabel
@onready var quiet_time_display= $TabContainer/Mentor/MarginContainer/VBoxContainer/QuietTimeInterval/QuietTimeValueLabel

func _ready() -> void:
	talk_interval.value_changed.connect(_on_talk_value_changed)
	dialog_close_interval.value_changed.connect(_on_dialog_close_value_changed)
	quite_time_interval.value_changed.connect(_on_quite_time_value_changed)
	talk_interval.value = System.WaitToTalkInterval
	dialog_close_interval.value = System.WaitToCloseDialogInterval
	quite_time_interval.value = System.QuietTimeInterval
	get_node("TabContainer/Mentor/MarginContainer/Apply").pressed.connect(_on_apply)
	get_node("TabContainer/Mentor/MarginContainer/Exit").pressed.connect(_on_exit)
	
func _on_apply():
	System.WaitToCloseDialogInterval = dialog_close_interval.value
	System.WaitToTalkInterval = talk_interval.value
	System.QuietTimeInterval = quite_time_interval.value
	System.save_settings()
	_on_exit()
func _on_exit():
	get_window().close_requested.emit()
func _on_talk_value_changed(val):
	talk_interval_display.text = str(val) + " seconds"
func _on_dialog_close_value_changed(val):
	dialog_close_display.text = str(val) + " seconds"
func _on_quite_time_value_changed(val):
	quite_time_interval.text = str(val) + " minutes"
