extends Node2D

signal next_level
signal tick

enum {UP, DOWN, LEFT, RIGHT, NONE}

const DIRECTION_VECTORS = { UP : Vector2.UP, LEFT : Vector2.LEFT, RIGHT : Vector2.RIGHT, DOWN : Vector2.DOWN, NONE : Vector2.ZERO }
const IMPULSE_MULTIPLIER = 10.0

const GRID_SIZE = 100

@export var TICK_RATE = 1.5
var TICK_LENGTH = 1.0 / TICK_RATE

var votes : Array[float] = [0, 0, 0, 0]

var last_dir = NONE

var candies = 0
var messages = 0

@onready var speed_label : Label = get_tree().get_root().find_child("SpeedLabel", true, false) 
@onready var chatspeed_label : Label = get_tree().get_root().find_child("Chatspeednum", true, false) 

var door_open_1 = preload("res://floors/door_open_1.tscn")
var door_open_3L = preload("res://floors/door_open_3L.tscn")
var door_open_3R = preload("res://floors/door_open_3R.tscn")
var door_open_end = preload("res://floors/door_open_end.tscn")

@onready
var _modebutt : CheckBox = get_tree().get_root().find_child("DemocracyButton", true, false)

@export
var levels : Array[PackedScene]

var level = 0

var current_level

@onready
var label = get_tree().get_root().find_child("Label", true, false)

var is_door_open = false

func clear_direction():
	last_dir = NONE
	
func adjust_speed(delta):
	TICK_RATE += delta
	TICK_LENGTH = 1.0 / TICK_RATE
	current_level.find_child("Player", true, false).TICK_RATE = TICK_RATE
	speed_label.set_deferred("text", ("%.2f" % TICK_RATE) + "x")
	
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().set_transparent_background(true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MOUSE_PASSTHROUGH, true, 0)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true, 0)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true, 0)
	next_level.connect(load_next_level)
	%TwitchChat.message_received.connect(_on_twitch_chat_message_received)
	current_level = get_child(0)
	ready_player()
	adjust_speed(0) # make sure speed display gets updated

func ready_player():
	var player = current_level.find_child("Player", true, false)

	player._direction = DIRECTION_VECTORS[last_dir]

	player._last_direction = player._direction
	player.TICK_RATE = TICK_RATE
	
func open_door():
	var doors = get_tree().get_nodes_in_group("Door")
	if !doors.is_empty():
		var old_door = doors[0]
		
		# what kind of door is it?
		var new_door
		if old_door.is_in_group("WallV"):
			new_door = door_open_1.instantiate()
		elif old_door.is_in_group("WallL"):
			if round(old_door.rotation) in [0, 90]:
				new_door = door_open_3L.instantiate()
			else:
				new_door = door_open_3R.instantiate()
		elif old_door.is_in_group("WallEnd"):
			new_door = door_open_end.instantiate()
		else:
			push_error("Couldn't find compatible open door!") 
		get_child(0).add_child(new_door)
		new_door.global_position = old_door.global_position
		old_door.call_deferred("queue_free")
		is_door_open = true
	else:
		printerr("Couldn't find a door to open!")
		push_error("Couldn't find a door to open!")
	
var t = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	if t > TICK_LENGTH:
		t -= TICK_LENGTH
		_read_keyboard_input()
		execute_tick()
	
	if !is_door_open:
		var pickups_left = get_tree().get_nodes_in_group("Pickups").size()
		if pickups_left == 0:
			open_door()
		

func load_next_level():
	if level+1 < levels.size():
		level+=1
		print("Loading level ", level)
		get_child(0).call_deferred("queue_free")
		var new_level = levels[level].instantiate()
		current_level = new_level
		new_level.position = Vector2(300, 0)
		call_deferred("add_child", new_level)
		call_deferred("ready_player")
		is_door_open = false
		t = 0
		clear_direction()
	
func _read_keyboard_input():
	if (Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)):
		votes[LEFT] += 1
	if (Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)):
		votes[DOWN] += 1
	if (Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)):
		votes[RIGHT] += 1
	if (Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)):
		votes[UP] += 1
	

func execute_tick():
	var dir
		
	chatspeed_label.set_deferred("text", messages)
	messages = 0
	if (votes.max() == 0):
		# nobody voted :( just coast
		dir = last_dir
	else:
		
		if _modebutt.button_pressed: # democracy mode
			# genius algorithm for breaking ties
			votes.assign(votes.map(func(n): return n + randf()))
			
			dir = votes.find(votes.max())
		else: # anarchy mode
			dir = RIGHT

			var v = randi_range(1, votes.reduce(func(i,m): return m + i))
			var n = 0
			for z in [UP, DOWN, LEFT]:
				if votes[z] > 0:
					n += votes[z]
					if v <= n:
						dir = z
						break
	
	# store last direction
	last_dir = dir
	
	# clear vote count
	votes = [0, 0, 0, 0]
	
	# command parade to move in direction
	find_child("Player", true, false).step(DIRECTION_VECTORS[dir])
	tick.emit(TICK_LENGTH)
	
func _on_skip_clicked():
	call_deferred("load_next_level")

func _on_open_clicked():
	call_deferred("open_door")

func _on_twitch_chat_message_received(_username, message : String):
	messages += 1
	if message.contains("left"):
		votes[LEFT] += 1
	elif message.contains("right"):
		votes[RIGHT] += 1
	elif message.contains("up"):
		votes[UP] += 1
	elif message.contains("down"):
		votes[DOWN] += 1


func _on_reset_button_pressed() -> void:
	level -= 1
	call_deferred("load_next_level")
