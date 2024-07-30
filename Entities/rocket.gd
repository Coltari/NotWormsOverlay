extends RigidBody2D

const EXPLODE = preload("res://Entities/explode.tscn")

func firingdata(angle, impulse):
	apply_central_impulse(Vector2(0,impulse).rotated(angle))

func _on_area_2d_body_entered(body):
	#explode
	var e = EXPLODE.instantiate()
	e.position = self.position
	Events.add_explosion.emit(e)
	queue_free()
