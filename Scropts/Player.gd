extends CharacterBody2D

@onready var GRID_SIZE = get_tree().get_root().find_child("Game", true, false).GRID_SIZE
@onready var spawn = position

var count = 0
var t = 0

var step_state = 0
const STEP_2_T = 0.5
const STEP_3_T = 1

var _direction
var _last_direction

var donk_flag = false

var TICK_RATE : float

var current_level : Node
var dying = false
var time_dead = 0

const RESPAWN_TIME = 3

var spin_t = 0

var RESPAWN_SPEED = 2.0
@onready var _target = position

# this should only be called at the end of a step, where position == target!
func step(direction : Vector2):
	
	if !dying:
		t = 0

		var x_pos = position.x
		var y_pos = position.y
		x_pos = round(position.x / GRID_SIZE) * GRID_SIZE
		y_pos = round(position.y / GRID_SIZE) * GRID_SIZE
		position = Vector2(x_pos, y_pos)
				
		var _collision = move_and_collide(direction * GRID_SIZE * 0.9, true)
		if _collision:
			print("Blocked by wall!")
			# we hit a wall
			# ignore the step and keep our current direction
			
			# is new direction safe:
			_collision = move_and_collide(_direction * GRID_SIZE * 0.9, true)
			if !_collision:
				step_state = 0
			else:
				_direction = Vector2.ZERO
			
		else:
			if direction != Vector2(0, 0):
				donk_flag = true
			step_state = 0
			# move in the new direction
			_last_direction = _direction
			
			_direction = direction
			
		_target = position + _direction * GRID_SIZE
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$Eatbox.area_entered.connect(_on_area_entered)
	pass

func _start_step0():
	step_state = 0
	$Sprite.global_rotation_degrees = 0
	
func _start_step1():
	step_state = 1
	$Sound1.play()
	$Sprite.global_rotation_degrees = 15
	
func _start_step2():
	step_state = 2
	$Sound2.play()
	$Sprite.global_rotation_degrees = -15
	
func _start_step3():
	step_state = 3
	
func _unpls():
	if step_state != -1:
		step_state = -1
		if donk_flag:
			donk_flag = false
			$Clunk.play()
	$Sound1.stop()
	$Sound2.stop()
	$Sprite.global_rotation_degrees = 0

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !dying:
		if _direction != null and _direction != Vector2(0, 0):
			position = position.move_toward(_target, GRID_SIZE * TICK_RATE * delta)

			#var _collision = move_and_collide(_direction * GRID_SIZE * delta * TICK_RATE)
			#if (_collision):
				#var x_pos = position.x
				#var y_pos = position.y
				#x_pos = round(position.x / GRID_SIZE) * GRID_SIZE
				#y_pos = round(position.y / GRID_SIZE) * GRID_SIZE
				#position = Vector2(x_pos, y_pos)
				#_direction = Vector2(0, 0)
		
			
			t += delta * TICK_RATE
			
			match step_state:
				0:
					_start_step1()
				1:
					if t > STEP_2_T:
						_start_step2()
				2:
					if t > STEP_3_T:
						_start_step3()
				3:
					pass
		else:
			_unpls()
	else:
		t += delta
		time_dead += delta
		
		if position != spawn:
			rotation_degrees = rotation_degrees + 360 * delta * TICK_RATE
			var move_vector = spawn - position
			position = position.move_toward(spawn, delta * GRID_SIZE * TICK_RATE * RESPAWN_SPEED)
		else:
			rotation_degrees = 0
			if time_dead > RESPAWN_TIME * (1 / TICK_RATE):
				$Sprite.frame = 0
				rotation = 0
				dying = false
				$Eatbox.set_deferred("monitorable", true)
				$Eatbox.set_deferred("monitoring", true)
				_direction = Vector2.ZERO
				_last_direction = _direction
				get_tree().get_root().find_child("Game", true, false).clear_direction()
	
	
func _on_area_entered(area: Area2D) -> void:
	if area.name == "LawnmowerKillbox":
		time_dead = 0
		# fucking die
		$Sprite.frame = 1
		dying = true
		$Eatbox.set_deferred("monitorable", false)
		$Eatbox.set_deferred("monitoring", false)
		$Scream.play()

func register_pickup(area : Area2D):
	area.body_entered.connect(_on_pickup_body_entered)

func _on_pickup_body_entered(body: Node2D) -> void:
	print("Body ", body.name)
