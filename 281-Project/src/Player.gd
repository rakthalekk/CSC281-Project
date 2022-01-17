extends KinematicBody2D

export(int) var speed = 300


func _process(delta):
	var direction := Vector2.ZERO
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction = direction.normalized()
	move_and_slide(direction * speed)
	look_at(get_global_mouse_position())
