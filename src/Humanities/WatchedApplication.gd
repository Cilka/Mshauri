extends Resource
class_name WatchedApplication
enum  AppCategory{
	Business,
	Art,
	Music,
	Video,
	Math,
	School,
	Work,
	Game,
	AudioEditor,
	VideoEditor,
	GraphicalEditor,
	Writing,
	System
}
@export var application : String #use command name
@export var alias : String #For human readability
@export var app_log : Array[Application]
@export var blacklisted : bool
@export var allowed_daily_duration : int #in minutes
@export var whitelisted : bool
@export var type : String
