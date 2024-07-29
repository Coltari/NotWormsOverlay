extends CharacterBody2D

@export var PlayerName : String = ""
@onready var movement_timer = $MovementTimer

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var moving : bool = false
var direction : int = 0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if moving:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func move(direction, time):
	movement_timer.wait_time = time
	velocity.x = direction * SPEED
	moving = true
	movement_timer.start()

func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

func _on_movement_timer_timeout():
	moving = false
