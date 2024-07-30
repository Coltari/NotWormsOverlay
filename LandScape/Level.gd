@tool
extends Node2D

@onready var players = $players
@onready var ground = $ground
@onready var projectiles = $projectiles

const WORM = preload("res://Entities/worm.tscn")
const DIRT = preload("res://Entities/dirt.tscn")
@export var noise : FastNoiseLite
@export var surfacenoise : FastNoiseLite

var tcount : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().transparent_bg = true
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
	TwitchService.setup();
	generate_level()
	Events.add_rocket.connect(add_rocket)
	Events.add_explosion.connect(add_explosion)

func add_explosion(explosion):
	call_deferred("add_child",explosion)
	#add_child(explosion)

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
	noise.seed = randi()
	surfacenoise.seed = randi()
	# for surface noise
	#on every x sum the y noise value.
	#if over threshold place block.
	#take a slice
	var s : float = 0.0

	for x in 1300:
		if x % 8 != 0:
			continue
		for y in 300:
			if y % 8 != 0:
				continue
			var n = noise.get_noise_2d(x,y)
			#get this value at x.
			s = surfacenoise.get_noise_1d(x)
			#map it to a y scale
			var perc = (s+1)/2
			var yperc = (300-y)*perc
			print("percentage ", perc, " y ", 300-y, " yperc ", yperc)
			if yperc < 65:
			#if y is under scale, place.
				if n > -0.1:
					var d = DIRT.instantiate()
					d.position = Vector2(x-8,y+400)
					ground.add_child(d)


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


func _on_button_pressed():
	spawn_worm("test"+str(tcount))
	tcount+=1


func _on_button_2_pressed():
	for n in players.get_children():
		n.queue_free()
	for n in ground.get_children():
		n.queue_free()
	generate_level()
