extends State

var fallstart : float = 0.0

func enter(_msg := {}):
	var val = _msg.get("falltime")
	if val == null:
		fallstart = 0.0
	else:
		fallstart = val

func update(delta):
	if owner.is_on_floor():
		state_machine.transition_to("Idle")
	#add how long we've been falling
	#if it's too long we bounce about and take fall damage
	fallstart += delta
	if fallstart > 2:
		var collision = owner.move_and_collide(owner.velocity * delta)
		if collision:
			owner.velocity = lerp(owner.velocity.bounce(collision.get_normal()), Vector2.ZERO, 0.1)
	else:
		owner.move_and_slide()

func physics_update(delta):
	if owner.facing == owner.facingDirection.RIGHT:
		owner.velocity.x = 1 * owner.AIRSPEED
	else:
		owner.velocity.x = -1 * owner.AIRSPEED
	owner.velocity.y += owner.gravity * delta
