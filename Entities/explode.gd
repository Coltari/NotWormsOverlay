extends AnimatedSprite2D

@onready var gpu_particles_2d = $GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	gpu_particles_2d.emitting = true

func _on_gpu_particles_2d_finished():
	queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("ground"):
		body.queue_free()
