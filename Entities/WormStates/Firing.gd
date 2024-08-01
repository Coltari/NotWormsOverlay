extends State

func enter(values := {}):
	owner.firing = true
	owner.weapon.visible = true
	var angle = values.get("angle")
	var thrust = values.get("thrust")
	fire(angle, thrust)

func update(_delta):
	if !owner.firing:
		state_machine.transition_to("Idle")

func fire(angle, thrust):
	var r = owner.ROCKET.instantiate()
	owner.weapon.rotation = angle
	r.position = owner.weapon.muzzle.global_position 
	r.firingdata(angle,thrust)
	owner.progress_bar.visible = true
	#2 seconds is 100%
	#1000 thrust is 100%
	#get thrust %
	var pc = (thrust/1000.0)
	#apply % to max time
	var t = 2*pc
	await get_tree().create_timer(t).timeout
	Events.add_rocket.emit(r)
	owner.progress_bar.value = 0
	owner.progress_bar.visible = false
	owner.firing = false

func exit() -> void:
	owner.weapon.visible = false
