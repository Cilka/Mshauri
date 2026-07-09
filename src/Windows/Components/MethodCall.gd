extends Resource
class_name MethodCall

var pos : int
var method_name : String
var args : Array
	
func _init(_position: int, _tag_string: String) -> void:
	pos = int(clamp(_position - 1, 0, abs(_position)))
	var text = _tag_string.split(",")
	method_name = text.get(0).split("=").get(1).replace(" ","")
	if text.size() > 1:
		for  index in range(1,text.size()-1):
			var arg = text.get(index)
			if arg.is_valid_int():
				arg = arg.to_int()
			elif  arg.is_valid_float():
				arg = arg.to_float()
			elif arg.begins_with("("):
				#only doing vector2 for window positions
				var temp = arg.replace("(","").replace(")","").split("\\,")
				arg = Vector2i(temp.get(0), temp.get(1))
			args.append(arg)
	
