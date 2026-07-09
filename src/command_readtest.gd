extends CanvasLayer
@onready  var btn = $Button
@onready var text = $RichTextLabel



var window  = Window.new()
func _on_btn_clicked():
	var output = Array()
	var thread = Thread.new()
	var callable =  Callable(OS, "execute")
	thread.start(callable)
	callable.call("pwd", PackedStringArray(), output,false, true)
	thread.wait_to_finish()
	
	for s in output:
		text.text += str(s)
	
	pass  


func _on_button_pressed() -> void:
	_on_btn_clicked()


func _on_new_window_pressed() -> void:
	var window  = Window.new()
	add_child(window)
	window.visible = true
	window.position = Vector2 ()
	window.title = "Chee"
	window.size = Vector2(400,600)
	window.close_requested.connect(_on_window_closed)
	pass # Replace with function body.
func _on_window_closed():
	window.queue_free()
