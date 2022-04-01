extends Area2D

export(int) var speed = 30

var direction := Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(position + direction)
	position += direction * speed


func _on_Timer_timeout():
	queue_free()


func _on_Bullet_body_entered(body):
	if body is Enemy:
		body.damage(5, Vector2.ZERO)
	queue_free()
