extends Node
class_name WordProcessor

const PAUSE_PATTERN := "(<p=\\d([.]\\d+)?[>])"
const METHOD_CALL_PATTERN := "<m=([^>]+)>"
var _pause_regex := RegEx.new()
var _method_regex := RegEx.new()
signal pause_requested(duration)
func _ready() -> void:
	_pause_regex.compile(PAUSE_PATTERN)
	_method_regex.compile(METHOD_CALL_PATTERN)
var _pauses := []
var _methods := []
func extract_flags_from_string(source_string: String) -> String: 
	_pauses = [] 
	_methods =[]
	_find_tags(source_string)
	return _extract_tags(source_string)
	
func _find_pauses(from_string: String) -> void:
	var _found_pauses := _pause_regex.search_all(from_string)
	for _result in _found_pauses:
  
		var _tag_string := _result.get_string() as String
		var _tag_position := _result.get_start() as int  
		var _pause = Pause.new(_tag_position, _tag_string)
		_pauses.append(_pause)
		
func _find_tags(from_string):
	var _found_methods := _method_regex.search_all(from_string)
	var _found_pauses := _pause_regex.search_all(from_string)
	for _result in _found_pauses:  
		var _tag_string := _result.get_string() as String
		var _tag_position := _result.get_start() as int   
		_pauses.append(Pause.new(_tag_position, _tag_string))
	for _result in _found_methods:
		var _tag_string := _result.get_string() as String
		var _tag_position := _result.get_start() as int  
		_methods.append(MethodCall.new(_tag_position, _tag_string))
func _extract_tags(from_string: String) -> String:
	var _custom_regex = RegEx.new()
	_custom_regex.compile("(<(.*?)>)")
	return _custom_regex.sub(from_string, "", true)

func check_at_position(pos : int):
	for _pause in _pauses:
		if _pause.pause_pos == pos:
			pause_requested.emit(_pause.duration)
	for _method in _methods:
		if _method.pos == pos:
			EventFlagger.dialog_request.emit(_method.method_name, _method.args)
