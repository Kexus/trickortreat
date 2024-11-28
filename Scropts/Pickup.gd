extends Area2D

func be_eaten():
	call_deferred("queue_free")

var t = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_rotation = 0
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	add_to_group("Pickups")


func _on_area_entered(area : Node2D):
	if area.name.contains("Eatbox"):
		be_eaten()
	
func _on_body_entered(body : Node2D):
	pass
	#print(body.name)
	#call_deferred("queue_free")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	t = t + _delta
	global_rotation_degrees = sin(t * 4)*15
