extends Button

@export
var speed : float

@onready var game = get_tree().get_root().find_child("Game", true, false)
@onready var speed_label = get_tree().get_root().find_child("SpeedLabel", true, false)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(on_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_pressed():
	game.adjust_speed(speed)
	
