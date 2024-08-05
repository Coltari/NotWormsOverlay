extends State

var fallstart : float = 0.0

func enter(_msg := {}):
	owner.sprite.play("default")
	owner.sprite.stop()
	var val = _msg.get("falltime")
	if val == null:
		fallstart = 0.0
	else:
		fallstart = val

func update(delta):
	if owner.is_on_floor():
		state_machine.transition_to("Idle")
	#add how long we've been falling
	#if it's too long go ragdoll
	fallstart += delta
	if fallstart > 2:
		state_machine.transition_to("RagDoll")

func physics_update(delta):
	if owner.facing == owner.facingDirection.RIGHT:
		owner.velocity.x = 1 * owner.AIRSPEED
	else:
		owner.velocity.x = -1 * owner.AIRSPEED
	owner.velocity.y += owner.gravity * delta
