extends RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# get_tree().get_root().find_child("TwitchChat", true, false).message_received.connect(_on_twitch_chat_message_received)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_twitch_chat_message_received(username, message):
	append_text("\n[b]%s[/b]: %s" % [username, message])
