extends Node

@export var TextSpeed : float = 0.5


func save(location: String, data: Dictionary ):
	var f  = FileAccess.open(location, FileAccess.WRITE)
	f.store(data)
	f.close()
