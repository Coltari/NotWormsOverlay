extends RigidBody2D

const EXPLODE = preload("res://Entities/explode.tscn")

func firingdata(angle, impulse):
	#rotation_degrees = angle
	apply_central_impulse(Vector2(0,impulse).rotated(angle))

func _on_area_2d_body_entered(_body):
	#explode
	var e = EXPLODE.instantiate()
	e.position = self.position
	Events.add_explosion.emit(e)
	queue_free()

func _physics_process(_delta):
	apply_central_force(Events.wind*100)

func _process(_delta):
	#rotation = atan2(linear_velocity.y,linear_velocity.x) + PI /2
	pass
