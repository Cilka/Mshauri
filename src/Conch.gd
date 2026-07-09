extends Node
var cmd= {}
var base_path : String
func _ready() -> void:
	if OS.has_feature("standalone"):
		base_path = OS.get_executable_path().get_basename()
	else:
		base_path = ProjectSettings.globalize_path("res://")
	base_path = base_path.path_join("sys")
	match OS.get_name():
		"Linux":
			base_path = base_path.path_join("bash")
			cmd.get_or_add("Seek","ls " + "\""+ base_path+ "\"")
		"Windows":
			base_path = base_path.path_join("powershell")
		"macOS":
			base_path = base_path.path_join("ksh")
	print_debug(base_path)
	_restore_commands()
	for c in cmd:
		print_debug(c)

func _restore_commands():
	var shell_out = execute_then_read(cmd["Seek"])
	for c :String in shell_out:
		c =  c.lstrip("\n").rstrip("\n")
		cmd.get_or_add(c, base_path.path_join(c))
func execute_then_read(cmd: String,options: PackedStringArray = PackedStringArray(),\
	 raw_dog: bool=false, show_terminal: bool = false) -> Array:
	var output = Array()
	var thread = Thread.new()
	var callable =  Callable(OS, "execute")
	thread.start(callable)
	if !raw_dog:
		cmd = "\""+cmd+"\""		
	print_debug("cmd: " + cmd)
	callable.call(cmd, options, output,false, show_terminal)
	thread.wait_to_finish()
	return output

	
#HACK: this is probably broken
func read_app_usage() -> Dictionary:
	var output = {}
	var shell_out = execute_then_read(cmd["cmdlog"],PackedStringArray(), true, false)
	var temp = (shell_out[0] as String).split(";")
	#Skipping header
	var index = 5
	
	while index in range(index, temp.size()-1):
		if output.find_key(temp[index+1]):
			index = index+4
			continue
		var app = Application.new()
		app.pid = temp[index]
		app.command = temp[index+1]
		app.time_started =  temp[index+2]
		app.duration= temp[index+3]
		output.get_or_add(app.command,app)
		index = index+4
		
	return output
func sleep(time: int ) -> String:
	match OS.get_name():
		"Windows":		
			return "Start-Sleep -Milliseconds " +str(time)
		_:
			return "sleep " +str(time)
