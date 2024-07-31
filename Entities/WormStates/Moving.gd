extends State

func enter(values := {}):
	var dir = values.get("direction")
	var time = values.get("time")
	
	if dir > 0:
		owner.facing = owner.facingDirection.RIGHT
	else:
		owner.facing = owner.facingDirection.LEFT
	owner.direction = dir
	owner.movement_timer.wait_time = time
	owner.moving = true
	owner.movement_timer.start()

func update(_delta):
	if !owner.is_on_floor():
		state_machine.transition_to("Falling")

func physics_update(_delta):
	if owner.moving:
		owner.velocity.x = owner.direction * owner.SPEED
	else:
		state_machine.transition_to("Idle")
