extends CharacterBody2D

@export var PlayerName : String = ""
@onready var movement_timer = $MovementTimer
@onready var label = $Label
@onready var progress_bar = $ProgressBar
@onready var health_bar = $healthBar
@onready var state_machine = $StateMachine
@onready var weapon = $Weapon

const SPEED = 100.0
const AIRSPEED = 80.0
const JUMP_VELOCITY = -300.0
const ROCKET = preload("res://Entities/rocket.tscn")
var health : int = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var moving : bool = false
var direction : int = 0
enum facingDirection {LEFT,RIGHT}
var facing
var firing : bool = false

func _ready():
	health_bar.value = health
	var f = randi_range(0,1)
	if f == 0: 
		facing = facingDirection.LEFT
		weapon.rotation_degrees = 90
	else:
		facing = facingDirection.RIGHT
		weapon.rotation_degrees = 270

func setName(Pname):
	label.text = Pname
	PlayerName = Pname

func _process(_delta):
	if firing:
		progress_bar.value += (50*_delta)

func _physics_process(delta):
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

func takedamage(val):
	health -= val
	health_bar.value = health
