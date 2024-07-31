extends State

var explosionforce : Vector2 = Vector2.ZERO

func enter(values := {}):
	explosionforce = values.get("force")

func physics_update(delta):
	owner.velocity = explosionforce * owner.AIRSPEED
	explosionforce = lerp(explosionforce, Vector2.ZERO, 0.01)
	owner.velocity.y += owner.gravity * delta
	var collision = owner.move_and_collide(owner.velocity * delta)
	if collision:
		owner.velocity = lerp(owner.velocity.bounce(collision.get_normal()), Vector2.ZERO, 0.1)
		state_machine.transition_to("Falling",{"falltime":2.0})

func update(_delta):
	if explosionforce.x < 1 and explosionforce.x > -1 and explosionforce.y < 1 and explosionforce.y > -1:
		state_machine.transition_to("Falling",{"falltime":2.0})
