extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_pressed():
	pass # Replace with function body.


func _on_twitch_chat_client_connected():
	disabled = true


func _on_twitch_chat_client_disconnected():
	disabled = false
