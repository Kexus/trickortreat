using Godot;
using System;
using TwitchLib.Client;
using TwitchLib.Client.Enums;
using TwitchLib.Client.Events;
using TwitchLib.Client.Extensions;
using TwitchLib.Client.Models;
using TwitchLib.Communication.Clients;
using TwitchLib.Communication.Events;
using TwitchLib.Communication.Models;
using static Godot.GD;

public partial class TwitchChat : Node
{
	[Signal]
	public delegate void ClientConnectedEventHandler();

	[Signal]
	public delegate void ClientDisconnectedEventHandler();

	[Signal]
	public delegate void MessageReceivedEventHandler();

	[Signal]
	public delegate void ConnectionErrorEventHandler();

	TwitchClient client;
	bool connected = false;

	GodotObject gdnode;
	
	public void Init(GodotObject obj, String channel)
	{
		gdnode = obj;
        //ConnectionCredentials creds = new ConnectionCredentials(user, key);
        ConnectionCredentials creds = new ConnectionCredentials("justinfan12345", "");
        client = new TwitchClient(new WebSocketClient());
		client.Initialize(creds, channel);
		
		client.OnMessageReceived += Client_OnMessageReceived;
		client.OnConnectionError += Client_OnConnectionError;
		client.OnConnected += Client_OnConnected;
		client.OnDisconnected += Client_OnDisconnect;

		client.Connect();
	}

	public void Close()
	{
		connected = false;
		client.Disconnect();
	}

    private void Client_OnDisconnect(object sender, OnDisconnectedEventArgs e)
    {
		connected = false;
		Print("[C#] Disconnected!");
		EmitSignal(SignalName.ClientDisconnected);
    }

    private void Client_OnConnectionError(object? sender, OnConnectionErrorArgs e)
	{
		Print("[C#] Connection Error");
        EmitSignal(SignalName.ConnectionError);
    }

	private void Client_OnConnected(object? sender, OnConnectedArgs e)
	{
		connected = true;
		Print("[C#] Connected!");
        EmitSignal(SignalName.ClientConnected);
    }

	private void Client_OnMessageReceived(object? sender, OnMessageReceivedArgs e)
	{
		Print(String.Format("[C#] Got Message {0}", e.ChatMessage.Message));
		EmitSignal(SignalName.MessageReceived, e.ChatMessage.Username, e.ChatMessage.Message);
	}

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
