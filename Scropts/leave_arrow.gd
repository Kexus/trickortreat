extends Area2D

var armed = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

var t = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t += delta
	
	var _scale = abs(sin(t))*0.1 + 0.1
	$Sprite2D.scale = Vector2(_scale, _scale)
	
func _on_body_entered(body: Node2D):
	if armed and body.name == "Player":
		armed = false
		get_tree().get_root().find_child("Game", true, false).next_level.emit()
