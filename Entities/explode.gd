extends AnimatedSprite2D

@onready var gpu_particles_2d = $GPUParticles2D
@onready var area_2d = $Area2D

var strength : float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	gpu_particles_2d.emitting = true

func _on_gpu_particles_2d_finished():
	queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("ground"):
		if body is TileMap:
			Events.remove_cell.emit(self.global_position, 50)
	else:
		if body.has_method("knock_back"):
			body.knock_back(self.global_position, strength,true)
