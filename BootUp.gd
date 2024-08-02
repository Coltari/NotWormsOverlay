extends CanvasLayer

@onready var ClientID = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextEdit
@onready var ClientSecret = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextEdit2
@onready var ChannelName = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextEdit3
@onready var OAuthURL = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextEdit4
@onready var popup = $CenterContainer/popup

const LEVEL = preload("res://LandScape/Level.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var x = load_cached()
	if x == 1:
		#saved details go straight to boot
		get_tree().change_scene_to_packed(LEVEL)
	elif x == 0:
		#need to prompt for info
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_button_pressed():
	if ClientID.text == "":
		ClientID.grab_focus()
		return
	if ClientSecret.text == "":
		ClientSecret.grab_focus()
		return
	if ChannelName.text == "":
		ChannelName.grab_focus()
		return
	if OAuthURL.text == "":
		OAuthURL.text = "http://localhost:7170"
	#store the enetered deets
	cache_details()
	#set the globals
	Events.clientID = ClientID.text
	Events.clientSecret = ClientSecret.text
	Events.channelName = ChannelName.text
	Events.redirectURL = OAuthURL.text
	ProjectSettings.set_setting("twitch/auth/client_id",Events.clientID)
	ProjectSettings.set_setting("twitch/auth/client_secret",Events.clientSecret)
	ProjectSettings.set_setting("twitch/auth/redirect_url",Events.redirectURL)
	ProjectSettings.save()
	#then restart
	popup.visible = true

func load_cached():
	if not FileAccess.file_exists("user://CachedCreds.save"):
		return 0 # Error! We don't have a save to load.
	var save_file = FileAccess.open("user://CachedCreds.save", FileAccess.READ)
	save_file.seek(0)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var node_data = json.get_data()
		Events.clientID = node_data["ClientId"]
		Events.clientSecret = node_data["ClientSecret"]
		Events.channelName = node_data["ChannelName"]
		Events.redirectURL = node_data["OAuthURL"]
	#launch
	return 1

func cache_details():
	var save_file = FileAccess.open("user://CachedCreds.save", FileAccess.WRITE)
	var data = {"ClientId" : ClientID.text, "ClientSecret" : ClientSecret.text, "ChannelName" : ChannelName.text, "OAuthURL" : OAuthURL.text}
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)

func _on_button_2_pressed():
	get_tree().quit()
