extends CharacterBody2D

@export var PlayerName : String = ""
@onready var movement_timer = $MovementTimer
@onready var label = $Label
@onready var progress_bar = $ProgressBar
@onready var health_bar = $healthBar

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
	else:
		facing = facingDirection.RIGHT

func setName(Pname):
	label.text = Pname
	PlayerName = Pname

func _process(_delta):
	if firing:
		progress_bar.value += (50*_delta)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if facing == facingDirection.RIGHT:
			velocity.x = 1 * AIRSPEED
		else:
			velocity.x = -1 * AIRSPEED
		velocity.y += gravity * delta
	elif moving:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func move(dir, time):
	if dir > 0:
		facing = facingDirection.RIGHT
	else:
		facing = facingDirection.LEFT
	direction = dir
	movement_timer.wait_time = time
	velocity.x = direction * SPEED
	moving = true
	movement_timer.start()

func fire(angle,thrust):
	var r = ROCKET.instantiate()
	r.position = self.position
	r.firingdata(angle,thrust)
	progress_bar.visible = true
	firing = true
	#2 seconds is 100%
	#1000 thrust is 100%
	#get thrust %
	var pc = (thrust/1000.0)
	#apply % to max time
	var t = 2*pc
	await get_tree().create_timer(t).timeout
	Events.add_rocket.emit(r)
	firing = false
	progress_bar.value = 0
	progress_bar.visible = false

func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

func _on_movement_timer_timeout():
	moving = false

func takedamage(val):
	health -= val
	health_bar.value = health
