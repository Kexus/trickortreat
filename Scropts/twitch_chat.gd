extends Node

signal client_connected
signal client_disconnected
signal message_received
signal connection_error

var twitch_chat : Node = null

var connected = false

@onready var button = get_tree().get_root().find_child("ConnectButton", true, false)

# Called when the node enters the scene tree for the first time.
func _ready():
	twitch_chat = load("res://Scropts/TwitchChat.cs").new()

	twitch_chat.ClientConnected.connect(_client_connected_handler)
	twitch_chat.ClientDisconnected.connect(_client_disconnected_handler)
	twitch_chat.MessageReceived.connect(_message_received_handler)
	twitch_chat.ConnectionError.connect(_connection_error_handler)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _client_connected_handler():
	print("client connected")
	call_deferred("emit_signal", "client_connected")
	button.set_deferred("text", "Disconnect")
	connected = true
	#client_connected.emit()
	
func _client_disconnected_handler():
	print("client disconnected")
	call_deferred("emit_signal", "client_disconnected")
	button.set_deferred("text", "Connect")
	connected = false
	#client_disconnected.emit()
	
func _message_received_handler(username, message):
	print("%s: %s" % [username, message])
	call_deferred("emit_signal", "message_received", username, message)
	#message_received.emit(username, message)

func _connection_error_handler():
	print("connection error")
	call_deferred("emit_signal", "connection_error")
	#connection_error.emit()

	
func _on_button_pressed():
	print("button clicked!")
	if connected:
		twitch_chat.Close()
	else:
		print("Connecting...")
		var channel = %ChannelInput.text
			
		twitch_chat.Init(self, channel);
