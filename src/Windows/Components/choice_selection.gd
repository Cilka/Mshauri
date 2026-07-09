extends VBoxContainer
@export var column_size : int
@onready var options = get_node("Options")
signal choice_selected(index: int)
func setup(choices : Array):
	var col_count = 0
	var row = HBoxContainer.new()	
	options.add_child(row)
	var index : int = 0
	for option in choices:		
		if col_count > 1:
			row = HBoxContainer.new()
			options.add_child(row)
			col_count = 0
		var button  = Button.new()
		row.add_child(button)
		if option is WordFlow:
			button.text = option.dialog.title
		else:
			if option:
				button.text = option
		button.pressed.connect(_on_choice_selected.bind(index))
		index += 1
		col_count += 1

func _on_choice_selected(index : int):
	choice_selected.emit(index)
