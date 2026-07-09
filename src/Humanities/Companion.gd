extends Resource

class_name Companion
enum Temperment{
	None,
	Normal,
	Sweet,
	Strict,
	Goofy,
	Kuudere
}

@export var name : String
@export var main_trait : Temperment
@export var secondary_trait : Temperment
@export var bio : String
@export var visage : Visage
@export var alt_visage : Array[Visage]
@export var sayings : Sayings
