extends CanvasLayer
@onready var close = get_node("NinePatchRect/CloseJournal")
@onready var left_page = get_node("NinePatchRect/MarginContainer/LeftPage")
@onready var right_page = get_node("NinePatchRect/MarginContainer/RightPage")

func _ready():
	var window : Window = get_parent()
	window.grab_focus()
	Weaver.focused_window_open.emit()
	


func _on_close_journal_pressed() -> void:
	if get_children().any(func(c): return c is ConfirmationDialog):
		return
	var confirm = ConfirmationDialog.new()
	add_child(confirm)
	confirm.title = "Finished for now?"
	confirm.ok_button_text = "Finish Writing"
	confirm.cancel_button_text = "No... Not yet."
	confirm.confirmed.connect(_close)
	confirm.visible = true
	


func _close():
	Weaver.focused_window_closed.emit()
	Weaver.seal(get_window().title)
