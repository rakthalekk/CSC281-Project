class_name Player
extends KinematicBody2D

export(int) var speed = 300

signal make_bullet
signal create_drill

onready var gun_tip = $GunTip

func _process(delta):
	var direction := Vector2.ZERO
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction = direction.normalized()
	move_and_slide(direction * speed)
	look_at(get_global_mouse_position())


func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		var pos = gun_tip.global_position
		var dir = (get_global_mouse_position() - pos).normalized()
		emit_signal("make_bullet", pos, dir)
	if event.is_action_pressed("create_drill"):
		emit_signal("create_drill", global_position)
