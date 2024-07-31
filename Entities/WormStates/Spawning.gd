extends State

func physics_update(delta):
	owner.velocity.y += owner.gravity * delta

func update(_delta):
	if owner.is_on_floor():
		state_machine.transition_to("Idle")
