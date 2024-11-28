extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed_scale = 0
	var r = roundf(global_rotation_degrees)
	while (r < 0):
		r += 360
	while (r > 360):
		r -= 360
	r /= 90
	r = int(floor(r))
	frame += r
	global_rotation_degrees = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
