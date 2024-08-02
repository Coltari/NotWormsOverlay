extends State

var explosionforce : Vector2 = Vector2.ZERO
var falltime : float

func enter(values := {}):
	var val = values.get("force")
	if val != null:
		explosionforce = val
		owner.velocity = explosionforce * owner.AIRSPEED

func physics_update(delta):
	#apply gravity
	owner.velocity.y += owner.gravity * delta
	#lerp velocity to 0
	owner.velocity.x = move_toward(owner.velocity.x, 0, 0.5)
	#check collisions for bounce
	var collision = owner.move_and_collide(owner.velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("knock_back"):
			collider.knock_back(owner.global_position,clamp(abs(owner.velocity.x),0.0,5.0),false)
		owner.velocity = lerp(owner.velocity.bounce(collision.get_normal()), Vector2.ZERO, 0.5)
		if falltime >= 0.5:
			owner.damaccum += int(falltime*2)
		falltime = 0.0
	#if on floor still - exit ragdoll state to idle.
	if owner.velocity.x == 0 and (owner.velocity.y > -6 and owner.velocity.y < -4):
		state_machine.transition_to("Idle")

func update(delta):
	falltime += delta
