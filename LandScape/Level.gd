extends Node2D

@onready var players = $players
@onready var ground = $ground
@onready var projectiles = $projectiles

const WORM = preload("res://Entities/worm.tscn")
const DIRT = preload("res://Entities/dirt.tscn")
@export var noise : FastNoiseLite

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().transparent_bg = true
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
	TwitchService.setup();
	generate_level()
	Events.add_rocket.connect(add_rocket)
	Events.add_explosion.connect(add_explosion)

func add_explosion(explosion):
	add_child(explosion)

func add_rocket(rocket):
	projectiles.add_child(rocket)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_twitch_irc_channel_message_received(from_user, message, _tags):
	var player
	for n in players.get_children():
		if n.PlayerName == from_user:
			player = n
	
	if !player:
		if message == "!join":
			#spawn worm
			spawn_worm(from_user)
	
	else:
		if message.left(2) == "!f":
			#parse fire command
			#find first space
			var fsindex = message.find(" ",0)
			#find second space
			var ssindex = message.find(" ",fsindex+1)
			#angle
			var angle = message.substr(fsindex,ssindex)
			#power
			var power = message.substr(ssindex,message.length()-ssindex)
			#is valid command?
			var a := angle as float
			var p := power as float
			if not a:
				return
			if not p:
				return
			#fire
			player.fire(deg_to_rad(a+90),clampf((p*10),10,1000))
		
		if message.left(2) =="!m":
			#parse move command
			#find first space
			var fsindex = message.find(" ",0)
			#find second space
			var ssindex = message.find(" ",fsindex+1)
			#direction
			var d : int = 0
			match message.substr(fsindex+1,1):
				"r":
					d = 1
				"l":
					d = -1
			#time
			var text = message.substr(ssindex,message.length()-ssindex)
			var t := text as float
			#is valid command?
			if d == 0:
				return
			if not t:
				return
			#send to relevant player
			player.move(d,t)
		
		if message.left(2) == "!j":
			player.jump()

func generate_level():
	randomize()
	#get noise
	#at present sprite size is 32x32
	#need to check value every 32 pixels
	#take a slice
	for y in 700:
		if y < 450:
			continue
		if y % 32 != 0:
			continue
		for x in 1200:
			if x % 32 != 0:
				continue
			var n = noise.get_noise_2d(x,y)
			if n > -0.1:
				var d = DIRT.instantiate()
				d.position = Vector2(x,y)
				ground.add_child(d)
	#drop blocks
	pass

func spawn_worm(user):
	for node in players.get_children():
		if node.PlayerName == user:
			return
	#if we've got this far they're not in the game
	var n = WORM.instantiate()
	#randomise position
	n.position.y = 100
	n.position.x = randi_range(10,1150)
	players.add_child(n)
	n.setName(user)

func _on_deathzone_body_entered(body):
	#dish out points
	body.queue_free()
