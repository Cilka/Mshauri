extends CharacterBody2D
#TODO: Fix Movement so that it uses screen coords
#TODO: Make greeting when mentor first appears on screen
class_name Mentor
var is_moving : bool = false
var is_held : bool = false
var is_hovered : bool = false
var is_talking : bool = false
var do_not_disturb: bool =false
@export var companion_data : Companion
@export var movement_speed :  float = 200
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var movement_timer = $MoveTimer
@onready var talk_timer = $TalkTimer
@onready var colShape = $MouseDetector/CollisionShape2D
var current_tween : Tween
var chat_window : Window
func _ready():
	#print_debug(Conch.read_app_usage())
	Weaver.focused_window_open.connect(_on_focused_window_open)
	Weaver.focused_window_closed.connect(_on_focused_window_closed)
func _process(delta: float) -> void:
	#
	get_window().position = position
	_anim_state()
	pass
func _physics_process(delta: float) -> void:
	move_random()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if is_hovered && event.double_click:
			print_debug("Mouse pos: " + str(event.position))

			#Weaver.OpenSettings()
func open_chat(dialog: Dialectic, autoclose :bool  = true):
	if do_not_disturb:
		return
	#TODO: figure out how to position this given where the metor is on the screen
	chat_window = Weaver.OpenSimpleDialog(get_window().position, dialog.sentence, autoclose)
	_clear_state()
	is_talking  = true
	chat_window.close_requested.connect(_on_chat_close)
	
func move_random():
	var screen = DisplayServer.screen_get_usable_rect(DisplayServer.get_screen_from_rect(get_viewport_rect()))
	if !is_moving && _should_move():
		var chance_to_move =  randi_range(0,9)
		if chance_to_move > 8:
			#DisplayServer.screen_get_size()
			is_moving = true  
			#var sprite_to_screen_pos = Vector2(global_position.x + get_window().position.x, global_position.y +get_window().position.y)
			var rnd_x = randi_range(sprite.get_rect().size.x,screen.size.x)
			var rnd_y = randi_range(sprite.get_rect().size.y,screen.size.y)
			var window_size = get_viewport_rect().size
			if rnd_x < position.x:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			movement_timer.start()
			if !current_tween:
				current_tween = create_tween()
				current_tween.finished.connect(_on_movement_finish)
			else:
				current_tween.stop()
			current_tween.tween_property(self, "position", Vector2(rnd_x,rnd_y) , 8.0)
			
			movement_timer.wait_time = 5 +randi_range(1,4)
			
	#if position.x < 0 || position.x > screen.size.x:
		#velocity.x = 0
		#if position.x < 0:
			#position.x = sprite.get_rect().size.x
		#elif position.x > screen.size.x:
			#position.x = screen.size.x - sprite.get_rect().size.x
	#if position.y < 0 || position.y > screen.size.y:
		#velocity.y = 0
		#if position.y < 0:
			#position.y = sprite.get_rect().size.y
		#elif position.y > screen.size.y:
			#position.y = screen.size.y - sprite.get_rect().size.y
func get_current_window() -> int:
	return get_window().get_window_id()
func _clear_state():
	is_moving = false
	is_hovered = false
	is_talking = false
	is_held = false
func greet():
	pass
func say_random():
	if !is_talking:
		var shouldsay = randi_range(0,100)
		#if shouldsay < 90:
		#	return
		var rand = randi_range(0, companion_data.sayings.idle.size()-1)
		stop_moving()
		_clear_state()
		
		is_talking = true
		open_chat(companion_data.sayings.idle[rand])
func move_viewport():
	pass

func stop_moving():
	movement_timer.stop()
	current_tween.kill()
	is_moving = false
func _on_timer_timeout() -> void:
	is_moving = false
func _update_window(delta :float) -> void:
	get_window().position = Vector2i(get_window().position.x +  global_position.x * delta, get_window().position.y +  global_position.y * delta)
	print_debug('Movie Window Rect Pos:' +str(get_window().position))

func _anim_state():
	if is_moving:
		anim.play("Move")
	elif !is_moving && !is_held:
		anim.play("Idle")
	elif is_talking:
		anim.play("Talk")

func _on_mouse_detector_mouse_entered() -> void:
	stop_moving()
	is_hovered = true
	#velocity = Vector2.ZERO
	print_debug("Found Mouse!")
func _on_mouse_detector_mouse_exited() -> void:
	is_hovered = false
	print_debug("Mouse gone...")
func _should_move() -> bool:
	return !is_hovered && !is_held && !is_talking && !do_not_disturb
func _on_chat_close() -> void:
	is_talking =  false
	talk_timer.start()


func _on_talk_timer_timeout() -> void:
	say_random()
	if !is_talking:
		talk_timer.start()
		
func _on_movement_finish():
	is_moving = false

func _on_focused_window_open():
	do_not_disturb = true
	talk_timer.stop()
	movement_timer.stop()
func _on_focused_window_closed():
	do_not_disturb = false
	talk_timer.start()
