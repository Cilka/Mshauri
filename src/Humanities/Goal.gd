extends Resource

class_name Goal

@export var title : String
@export var description : String
@export var daily_regimine_in_minutes : int
#will prioritize this goal over others if checked
@export var focused : bool
#command,options
@export var crafting_tools: Dictionary[String, PackedStringArray]
## So applications don't have to be loaded all at once
@export var wait_time_in_miliseconds : int = 500

func set_up_workspace():
	if crafting_tools == null:
		print_debug("There's no tools for your goal")
		return
		
	for i in crafting_tools:
		
		Conch.execute_then_read(i,crafting_tools[i])
		if wait_time_in_miliseconds > 0:
			await Conch.execute_then_read(Conch.sleep(wait_time_in_miliseconds))
