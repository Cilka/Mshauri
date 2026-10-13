extends Node

@export var TextSpeed : float = 0.5
#default 5 minutes
@export var WaitToTalkInterval: float:
	set(new_value):
		WaitToTalkInterval = new_value
		WaitToTalkIntervalChanged.emit(new_value)
@export var WaitToCloseDialogInterval: float:
	set(new_value):
		WaitToCloseDialogInterval = new_value
		WaitToCloseDialogIntervalChanged.emit(new_value)
@export var QuietTimeInterval: float:  
	set(new_value):
		QuietTimeInterval = new_value
		QuietTimeIntervalChanged.emit(new_value)
signal QuietTimeIntervalChanged(new_value)
signal WaitToCloseDialogIntervalChanged(new_value)
signal WaitToTalkIntervalChanged(new_value)
var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"
func _ready():
	var err : Error
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		WaitToCloseDialogInterval = 8
		WaitToTalkInterval = 300
		QuietTimeInterval = 0
		config.set_value("Mentor","WaitToTalkInterval",WaitToTalkInterval)
		config.set_value("Mentor","WaitToCloseDialogInterval",WaitToCloseDialogInterval)
		config.set_value("Mentor","QuietTimeInterval",QuietTimeInterval)
		config.save(SETTINGS_FILE_PATH)
	else:
		err = config.load(SETTINGS_FILE_PATH)
	if err:
		print_debug(err)
		return
	load_mentor_settings()
func save(location: String, data: Dictionary ):
	var f  = FileAccess.open(location, FileAccess.WRITE)
	f.store(data)
	f.close()
func save_settings():
	config.set_value("Mentor","WaitToTalkInterval",WaitToTalkInterval)
	config.set_value("Mentor","WaitToCloseDialogInterval",WaitToCloseDialogInterval)
	config.set_value("Mentor","QuietTimeInterval",QuietTimeInterval)
	config.save(SETTINGS_FILE_PATH)
	
func load_mentor_settings():
	WaitToCloseDialogInterval = config.get_value("Mentor","WaitToCloseDialogInterval")
	WaitToTalkInterval = config.get_value("Mentor","WaitToTalkInterval")
	QuietTimeInterval = config.get_value("Mentor","QuietTimeInterval")
