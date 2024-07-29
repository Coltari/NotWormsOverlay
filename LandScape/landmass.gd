extends Node2D

@onready var players = $players
const WORM = preload("res://Entities/worm.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().transparent_bg = true
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
	TwitchService.setup();
	generate_level()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_twitch_irc_channel_message_received(from_user, message, tags):
	print(from_user, message, tags)
	#coltari
	#test
	#<RefCounted#-9223371901915623200> # don't know what these tags are.
	
	if message == "!join":
		#spawn worm
		spawn_worm(from_user)
	
	if message.left(2) == "!f":
		#parse fire command
		#angle
		#power
		#is valid command?
		#fire
		pass
	
	if message.left(2) =="!m":
		#parse move command
		#direction
		#time
		#is valid command?
		pass
	
	if message.left(2) == "!j":
		#jump
		pass

func generate_level():
	pass

func spawn_worm(user):
	for node in players:
		if node.PlayerName == user:
			return
	#if we've got this far they're not in the game
	var n = WORM.instantiate()
	n.PlayerName = user
	#randomise position
	players.add_child(n)
