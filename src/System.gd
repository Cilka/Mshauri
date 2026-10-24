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
@export var QuickMenuPosition : Vector2i
@export var PreferredMentor :String
signal QuietTimeIntervalChanged(new_value)
signal WaitToCloseDialogIntervalChanged(new_value)
signal WaitToTalkIntervalChanged(new_value)
var config = ConfigFile.new()
var screen = DisplayServer.screen_get_size()
const SETTINGS_FILE_PATH = "user://settings.ini"
const MENTOR_PATH = "user://councle"
func _ready():
	var err : Error	
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		WaitToCloseDialogInterval = 8
		WaitToTalkInterval = 60
		QuietTimeInterval = 7200
		PreferredMentor = "Rin"
		config.set_value("Mentor","WaitToTalkInterval",WaitToTalkInterval)
		config.set_value("Mentor","WaitToCloseDialogInterval",WaitToCloseDialogInterval)
		config.set_value("Mentor","QuietTimeInterval",QuietTimeInterval)
		config.set_value("Mentor","PreferredMentor",PreferredMentor)
		config.set_value("Quick Menu", "Position", screen/2)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		err = config.load(SETTINGS_FILE_PATH)
	if err:
		print_debug(err)
		return
	if !DirAccess.dir_exists_absolute(MENTOR_PATH):
		var rins_path = MENTOR_PATH+ "/Rin"
		DirAccess.make_dir_recursive_absolute(rins_path)
		DirAccess.copy_absolute("res://data/Rin/persona.json",rins_path+"/persona.json")
		DirAccess.copy_absolute("res://data/Rin/Rin.png",rins_path+"/Rin.png")
	load_mentor_settings()
	load_quick_menu_position()
func save(location: String, data: Dictionary ):
	var f  = FileAccess.open(location, FileAccess.WRITE)
	f.store(data)
	f.close()
func save_settings():
	config.set_value("Mentor","WaitToTalkInterval",WaitToTalkInterval)
	config.set_value("Mentor","WaitToCloseDialogInterval",WaitToCloseDialogInterval)
	config.set_value("Mentor","QuietTimeInterval",QuietTimeInterval)
	config.save(SETTINGS_FILE_PATH)

func save_quick_menu_position(position: Vector2i):
	config.set_value("Quick Menu", "Position", position)
func load_quick_menu_position():	
	QuickMenuPosition = config.get_value("Quick Menu","Position", screen/2)
func load_mentor_settings():
	WaitToCloseDialogInterval = config.get_value("Mentor","WaitToCloseDialogInterval")
	WaitToTalkInterval = config.get_value("Mentor","WaitToTalkInterval")
	QuietTimeInterval = config.get_value("Mentor","QuietTimeInterval")
	PreferredMentor = config.get_value("Mentor","PreferredMentor")
func load_mentor_data(file_name)-> Companion:
	var file = FileAccess.open(file_name, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	var persona : Companion = Companion.new()
	if data is Dictionary:
		if data.has("bio"):
			persona.bio = data["bio"]
		persona.name = data["name"]
		persona.main_trait = Companion.Temperment.get(data["main_trait"])
		persona.secondary_trait = Companion.Temperment.get(data["secondary_trait"])
		if data.has("visage"):
			persona.visage = _obtain_visage(data["visage"])
		if data.has("alt_visage"):
			persona.alt_visage = _obtain_alt_visage(data["alt_visage"])
		persona.sayings = _obtain_sayings(data["sayings"])
	else: 
		print("Error loading persona: " + file_name)
	return persona

func _obtain_visage(data : Dictionary) -> Visage:
	var v : Visage =Visage.new()
	v.image = data["image"]
	v.hframes = data["hframes"]
	v.vframes = data["vframes"]
	v.is_pixel = data["is_pixel"]
	v.animations = AnimationLibrary.new()
	var animations = data["animations"] as Array[Dictionary]
	for i in range(animations.size()):
		var anim =  _set_animation(animations[i])
		var err = v.animations.add_animation(anim.resource_name,anim)
		if err:
			print_debug(err)
	return v
func _obtain_alt_visage(data: Dictionary) -> Array[Visage]:
	var v : Array[Visage]
	if data.has("alt_visage"):
		for i in range(data["alt_visage"].size() -1):
			v[i] = _obtain_visage(data["alt_visage"][i])
	return v
func _set_animation(raw : Dictionary) -> Animation:
	var anim = Animation.new()
	anim.resource_name = raw["name"]
	anim.length = raw["length"]
	var track_index = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_index, "Sprite2D:frame")
	anim.value_track_set_update_mode(track_index,Animation.UpdateMode.UPDATE_DISCRETE)
	anim.track_set_interpolation_type(track_index, Animation.InterpolationType.INTERPOLATION_LINEAR)
	anim.track_set_interpolation_loop_wrap(track_index,false)
	if raw["loop"] == true:
		anim.loop_mode = Animation.LOOP_LINEAR
	for i in range(raw["keys"].size()):
		var easing : float = 1.0
		if raw["keys"][i].has("easing"):
			easing  = raw["keys"][i]["easing"]
		anim.track_insert_key(track_index, raw["keys"][i]["time"],\
		 raw["keys"][i]["frame"],\
		 easing)
	return anim
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
func get_prefered_mentor() -> String:
	return MENTOR_PATH + "/" + PreferredMentor + "/persona.json"
func get_persona_file(mentor_name: String):
	return MENTOR_PATH + "/" + mentor_name + "/persona.json"
