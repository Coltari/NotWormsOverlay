extends Node2D

@onready var players = $players
@onready var ground = $ground
@onready var projectiles = $projectiles
@onready var label = $ui/Label
@onready var wind_bar_right = $ui/WindBarRight
@onready var wind_bar_left = $ui/WindBarLeft
@onready var wind_timer = $WindTimer
@onready var water = $water
@onready var notif_timer = $NotifTimer
@onready var notifback = $ui/notifback
@onready var tile_map = $ground/TileMap

#@onready var twitch_irc_channel = $TwitchIrcChannel

const WORM = preload("res://Entities/worm.tscn")

@export var noise : FastNoiseLite
@export var surfacenoise : FastNoiseLite
@export var WindTimer : float = 30.0

var tcount : int = 0
var windtarget : int = 0
@onready var time : float = 0.0
@onready var blockcount : float = 0.0
var levelready : bool = false

var notifications = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#setDetails()
	setWaterLevel()
	get_viewport().transparent_bg = true
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
	generate_level()
	aChangeInTheWind()
	Events.add_rocket.connect(add_rocket)
	Events.add_explosion.connect(add_explosion)

func setWaterLevel():
	for c in water.get_children():
		if c.get_name() == "back1":
			c.position.y = 600
			c.position.x = 576
		elif c.get_name() == "back2":
			c.position.y = 610
			c.position.x = 576
		elif c.get_name() == "front1":
			c.position.y = 630
			c.position.x = 576
		elif c.get_name() == "front2":
			c.position.y = 640
			c.position.x = 576

func add_explosion(explosion):
	call_deferred("add_child",explosion)
	#add_child(explosion)

func add_rocket(rocket):
	projectiles.add_child(rocket)

func get_sin(a):
	return sin((time*a)*1)*0.5

func get_cos(a):
	return cos((time*a)*1)*0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	regenerateDeadLand()
	checkForNotifications()
	time += _delta
	var i : int = 1
	for c in water.get_children():
		c.position.y += get_sin(i)
		c.position.x += get_cos(i)
		i += 1
	if windtarget > 0:
		if wind_bar_left.value > 0:
			wind_bar_left.value -= 1
		elif wind_bar_right.value > windtarget:
			wind_bar_right.value -=1
		elif wind_bar_right.value < windtarget:
			wind_bar_right.value += 1
	elif windtarget < 0:
		if wind_bar_right.value > 0:
			wind_bar_right.value -= 1
		elif wind_bar_left.value > windtarget * -1:
			wind_bar_left.value -=1
		elif wind_bar_left.value < windtarget * -1:
			wind_bar_left.value += 1
	else:
		wind_bar_left.value = 0
		wind_bar_right.value = 0

func _on_twitch_irc_channel_message_received(data, message, _tags):
	var from_user = data.tags["display-name"]
	message = message.to_lower()
	var player
	for n in players.get_children():
		if n.PlayerName == from_user:
			player = n
	
	if !player:
		if message == "!join":
			#spawn worm
			spawn_worm(from_user)
	
	else:
		if message.left(2) == "!f" or message.left(5) == "!fire":
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
		
		if message.left(2) =="!r" or message.left(5) == "!right":
			#parse move command
			#find first space
			var fsindex = message.find(" ",0)
			#time
			var text = message.substr(fsindex,message.length()-fsindex)
			var t := text as float
			#is valid command?
			if not t:
				return
			#send to relevant player
			player.move(1,t)
		
		if message.left(2) =="!l" or message.left(5) == "!left":
			#parse move command
			#find first space
			var fsindex = message.find(" ",0)
			#time
			var text = message.substr(fsindex,message.length()-fsindex)
			var t := text as float
			#is valid command?
			if not t:
				return
			#send to relevant player
			player.move(-1,t)
		
		if message.left(2) == "!j" or message.left(5) == "!jump":
			player.jump()

func generate_level():
	levelready = false
	blockcount = 0.0
	randomize()
	#get noise
	noise.seed = randi()
	surfacenoise.seed = randi()
	
	for x in 1160:
		if x % 2 != 0:
			continue
		for y in 252:
			if y % 2 != 0:
				continue
			var n = noise.get_noise_2d(x,y)
			#get this value at x.
			var s = surfacenoise.get_noise_1d(x)
			#map it to a y scale
			var perc = (s+1)/2
			var yperc = (252-y)*perc
			if yperc < 45:
			#if y is under scale, place.
				if n > -0.1:
					tile_map.place_at_pos(Vector2i(x,y+400))
	tile_map.update_all_tiles()
	blockcount = tile_map.count_tiles()
	levelready = true

func regenerateDeadLand():
	if levelready:
		var currentblockcount : float = 0.0
		currentblockcount = tile_map.count_tiles()
		
		if blockcount == 0:
			return
		
		if ((currentblockcount / blockcount) * 100) < 40:
			levelready = false
			notifications.append("Rebuilding Level")
			
			#less than 40% regenerate
			var currentplayers = []
			for p in players.get_children():
				currentplayers.append(p.PlayerName)
			
			for n in players.get_children():
				n.queue_free()
				
			tile_map.remove_all_tiles()
			
			generate_level()
			
			await get_tree().create_timer(2).timeout
			
			while currentplayers.size() > 0:
				var player = currentplayers.pop_front()
				print("spawning ", player)
				spawn_worm(player)

func spawn_worm(user):
	for node in players.get_children():
		if node.PlayerName == user:
			return
	#if we've got this far they're not in the game
	var n = WORM.instantiate()
	#randomise position
	var x = randi_range(10,1150)
	#check we still have land beneath this spot.
	var canspawn = false
	while !canspawn:
		for y in range(350,1000):
			if tile_map.is_tile_here(Vector2(x,y)):
				canspawn = true
				break
		#if we reach this point - none of the ground cubes are under this spot so pick another
		x = randi_range(10,1150)
	n.position.y = 100
	n.position.x = x
	players.add_child(n)
	n.setName(user)

func _on_deathzone_body_entered(body):
	#dish out points
	notifications.append(body.PlayerName + " is swimming with the fishies")
	body.queue_free()


func _on_button_pressed():
	spawn_worm("test"+str(tcount))
	tcount+=1


func _on_button_2_pressed():
	for n in players.get_children():
		n.queue_free()
	tile_map.remove_all_tiles()
	generate_level()

func aChangeInTheWind():
	wind_timer.wait_time = WindTimer
	Events.wind = Vector2(randf_range(-1,1),0)
	var a = Events.wind.x
	if a != 0:
		windtarget = int(a * 100)
	else:
		windtarget = 0
	wind_timer.start()

func _on_wind_timer_timeout():
	aChangeInTheWind()


func _on_walldeath_body_entered(body):
		#dish out points
	notifications.append(body.PlayerName + " fell out of the world")
	body.queue_free()

func _on_notif_timer_timeout():
	label.text = ""
	notifback.visible = false

func checkForNotifications():
	if notif_timer.time_left > 0:
		return
	if notifications.size() > 0:
		label.text = notifications.pop_front()
		notifback.visible = true
		notif_timer.start()


func _on_gift_chat_message(sender_data: SenderData, message: Variant) -> void:
	_on_twitch_irc_channel_message_received(sender_data, message, null)
