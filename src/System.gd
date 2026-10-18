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
const MENTOR_PATH = "user://councle"
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
	if !DirAccess.dir_exists_absolute(MENTOR_PATH):
		DirAccess.make_dir_absolute(MENTOR_PATH)
	
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
	
func load_mentor_data(file_name)-> Companion:
	var file = FileAccess.open(file_name, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	var persona : Companion = Companion.new()
	if data is Dictionary:
		if data.has("bio"):
			persona.bio = data["Bio"]
		persona.name = data["Name"]
		persona.main_trait = Companion.Temperment.get(data["Main_Trait"])
		persona.secondary_trait = Companion.Temperment.get(data["Secondary_Trait"])
		if data.has("Visage"):
			persona.visage = _obtain_visage(data["Visage"])
		if data.has("Alt_Visage"):
			persona.alt_visage = _obtain_alt_visage(data["Alt_Visage"])
		persona.sayings = _obtain_sayings(data["Sayings"])
	else: 
		print("Error loading persona: " + file_name)
	return persona

func _obtain_visage(data) -> Visage:
	var v : Visage
	return v
func _obtain_alt_visage(data) -> Array[Visage]:
	var v : Array[Visage]
	return v
func _obtain_sayings(data : Dictionary):
	var sayings : Sayings = Sayings.new()
	if data.has("idle"):
		var idle = data["idle"] as Array[Dictionary]
		for i in range(idle.size()-1):
			var key_value = _build_lexicon(idle[i],"idle", str(i +1))
			sayings.idle[key_value.keys()[0]] = key_value[key_value.keys()[0]]
	if data.has("greeting"):
		var greeting = data["greeting"] as Array[Dictionary]
		for i in range(greeting.size()-1):
			var key_value = _build_lexicon(greeting[i],"greeting", str(i +1))
			sayings.greeting[key_value.keys()[0]] = key_value[key_value.keys()[0]]
	if data.has("intro"):
		var intro =  data["intro"] as Array[Dictionary]
		for i in range(intro.size()-1):
			var key_value = _build_lexicon(intro[i],"intro", str(i +1))
			sayings.intro[key_value.keys()[0]] = key_value[key_value.keys()[0]]
	if data.has("working"):
		var working = data["working"] as Array[Dictionary]
		for i in range(working.size()-1):
			var key_value = _build_lexicon(working[i],"working", str(i +1))
			sayings.working[key_value.keys()[0]] = key_value[key_value.keys()[0]]
	if data.has("emote_review"):
		var emote_review = data["emote_review"] as Array[Dictionary]
		for i in range(emote_review.size()-1):
			var key_value = _build_lexicon(emote_review[i],"emote_review", str(i +1))
			sayings.emote_review[key_value.keys()[0]] = key_value[key_value.keys()[0]]
	if data.has("crisis"):
		var crisis  = data["crisis"] as Array[Dictionary]
		for i in range(crisis.size()-1):
			var key_value = _build_lexicon(crisis[i],"crisis", str(i +1))
			sayings.crisis[key_value.keys()[0]] = key_value[key_value.keys()[0]]
	if data.has("operation"):
		var operation = data["operation"] as Array[Dictionary]
		for i in range(operation.size()-1):
			var key_value = _build_lexicon(operation[i],"operation", str(i +1))
			sayings.operation[key_value.keys()[0]] = key_value[key_value.keys()[0]]
	return sayings
func _build_lexicon(dialetic: Dictionary,section:String ,tempTitle:String = "") -> Dictionary[String,Dialectic]:
	var dialog  = Dialectic.new()
	dialog.sentence = dialetic["sentence"]
	dialog.category = dialetic["category"]
	if dialetic.find_key("title"):
		dialog.title = dialetic["title"]
		tempTitle =section + ":" + dialog.title
	else:
		tempTitle = section +":"+tempTitle
	if dialetic.find_key("context"):
		dialog.context = dialetic["context"]
	if dialetic.find_key("goto"):
		dialog.goto = dialetic["goto"]
	if dialetic.find_key("choices"):
		for i in  dialetic["choices"].size()-1:
			dialog.choices[i] = dialetic["choices"][i]
	return {tempTitle: dialog}
	
func FileSeperator() -> String:
	if OS.get_name() == "Windows":
		return "\\"
	else:
		return "/"
