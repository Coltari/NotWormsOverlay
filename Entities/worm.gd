extends CharacterBody2D

@export var PlayerName : String = ""
@onready var movement_timer = $MovementTimer
@onready var label = $Label
@onready var progress_bar = $ProgressBar

const SPEED = 300.0
const AIRSPEED = 250.0
const JUMP_VELOCITY = -400.0
const ROCKET = preload("res://Entities/rocket.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var moving : bool = false
var direction : int = 0
enum facingDirection {LEFT,RIGHT}
var facing
var firing : bool = false

func _ready():
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

func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

func _on_movement_timer_timeout():
	moving = false
