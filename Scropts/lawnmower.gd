extends CharacterBody2D

var sprite_t = 0
var t = 0

enum Mode { Clockwise, BackAndForth, Stationary }
@export var mode : Mode

@onready var GRID_SIZE = get_tree().get_root().find_child("Game", true, false).GRID_SIZE

@onready var _direction : Vector2 = Vector2.RIGHT.rotated(rotation)
@onready var _target : Vector2 = position + _direction * GRID_SIZE


@export
var speed : float # in tiles per tick

@onready var TICK_LENGTH = get_tree().get_root().find_child("Game", true, false).TICK_LENGTH
@onready var TICK_RATE = get_tree().get_root().find_child("Game", true, false).TICK_RATE

var sprite : Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite = find_child("Sprite", true, false)
	
	if mode != Mode.Stationary:
		get_tree().get_root().find_child("Game", true, false).tick.connect(process_tick)

func test_direction(rot):
	var old_rotation = rotation
	rot = deg_to_rad(rot)
	var new_direction = _direction.rotated(rot)
	rotate(rot)
	var _collision = move_and_collide(new_direction * GRID_SIZE, true)
	if (_collision):
		rotation = old_rotation
		return false
	else:
		_direction = new_direction
		_target = position + _direction * GRID_SIZE
		var x_temp = round(_target.x / GRID_SIZE) * GRID_SIZE
		var y_temp = round(_target.y / GRID_SIZE) * GRID_SIZE
		_target = Vector2(x_temp, y_temp)
		return true

func process_tick(period : float):
	t = 0
	TICK_LENGTH = period
	TICK_RATE = 1 / period
	# can we move forward?
	var x_temp = round(position.x / GRID_SIZE) * GRID_SIZE
	var y_temp = round(position.y / GRID_SIZE) * GRID_SIZE
	position = Vector2(x_temp, y_temp)
	_direction = Vector2.RIGHT.rotated(rotation)
	
	if mode == Mode.Clockwise:
		if !test_direction(0):
			if !test_direction(90):
				if !test_direction(-90):
					if !test_direction(180):
						_direction = Vector2.ZERO

	elif mode == Mode.BackAndForth:
		if !test_direction(0):
			if !test_direction(180):
				_direction = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sprite_t += delta * 100
	var x_scale
	
	rotation_degrees = fmod(rotation_degrees, 360)
	if rotation_degrees < 0:
		rotation_degrees += 360
	if roundf(rotation_degrees) == 180:
		x_scale = -1
	else:
		x_scale = 1
	sprite.set_scale(Vector2(x_scale, 1.0 + sin(sprite_t)*0.05) * x_scale)
	
	if mode != Mode.Stationary:
		position = position.move_toward(_target, GRID_SIZE * delta * TICK_RATE)
	#var _collision = move_and_collide(_direction * GRID_SIZE * delta * TICK_RATE)
	#if (_collision):
		#move_and_collide(_direction * -1)
		#print(_collision.get_collider().name)
		#var x_pos = position.x
		#var y_pos = position.y
		#x_pos = round(position.x / GRID_SIZE) * GRID_SIZE
		#y_pos = round(position.y / GRID_SIZE) * GRID_SIZE
		#position = Vector2(x_pos, y_pos)
		#_direction = Vector2(0, 0)
