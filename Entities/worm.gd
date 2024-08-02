extends CharacterBody2D

@export var PlayerName : String = ""
@onready var movement_timer = $MovementTimer
@onready var label = $Label
@onready var health_bar = $healthBar
@onready var state_machine = $StateMachine
@onready var weapon = $Weapon
@onready var damagelabels = $damagelabels
@onready var sprite = $AnimatedSprite2D

const SPEED = 100.0
const AIRSPEED = 80.0
const JUMP_VELOCITY = -300.0
const ROCKET = preload("res://Entities/rocket.tscn")
var health : int = 100
var iframes : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var moving : bool = false
var direction : int = 0
enum facingDirection {LEFT,RIGHT}
var facing
var firing : bool = false
var damaccum : int = 0

func _ready():
	health_bar.value = health
	var f = randi_range(0,1)
	if f == 0: 
		facing = facingDirection.LEFT
		weapon.rotation_degrees = 90
	else:
		facing = facingDirection.RIGHT
		weapon.rotation_degrees = 270

func checksprite():
	if facing == facingDirection.LEFT:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

func setName(Pname):
	label.text = Pname
	PlayerName = Pname

func _process(_delta):
	checksprite()
	if firing:
		weapon.update_progress(50*_delta)
	for c in damagelabels.get_children():
		var color : Color = c.get("theme_override_colors/font_color")
		if color.a > 0.0:
			c.position.y -= 1
			var nc : Color = Color(color.r, color.g, color.b, color.a-0.01)
			c.set("theme_override_colors/font_color",nc)
		else:
			c.queue_free()

func _physics_process(_delta):
	if state_machine.state != $StateMachine/RagDoll:
		move_and_slide()

func move(dir, time):
	if state_machine.state.has_method("canMove"):
		state_machine.state.canMove(dir, time)

func fire(angle,thrust):
	if state_machine.state.has_method("canFire"):
		state_machine.state.canFire(angle,thrust)

func jump():
	if state_machine.state.has_method("canJump"):
		state_machine.state.canJump()

func _on_movement_timer_timeout():
	moving = false

func takedamage():
	if damaccum > 0:
		health -= damaccum
		health_bar.value = health
		var a = Label.new()
		a.position = self.position
		a.text = str(damaccum)
		a.size.x = 150
		a.size.y = 50
		a.set("theme_override_colors/font_color",Color(1,1,1,1))
		damagelabels.add_child(a)
		damaccum = 0

func knock_back(source,strength,dealdamage):
	if !iframes:
		iframes = true
		#get distance from source
		var kbdirection = source.direction_to(global_position)
		var explosion_force = kbdirection * strength
		if dealdamage:
			#take damage based on that
			var dist = global_position.distance_to(source)
			dist = clamp(abs(dist),0.0,49.0)
			var damage = int((strength * 5) - dist)
			damaccum += damage
		#move to ragdoll state
		var values : Dictionary = {"force":explosion_force}
		state_machine.transition_to("RagDoll",values)
		#apply knockback force
		await get_tree().create_timer(0.5).timeout
		iframes = false
