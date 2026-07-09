extends Resource

class_name Dialectic
enum Tone{
	Neutral,
	Serious,
	Stern,
	Silly,
	Empathetic,
	Cheery,
	Disappointed,
	Worried
}
@export var title : String
@export var sentence : String
@export var tone : Tone
@export var context : String
@export var choices : Array[WordFlow]
