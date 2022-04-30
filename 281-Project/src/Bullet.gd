extends Area2D

export(int) var speed = 2000

var direction := Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(position + direction)
	position += direction * speed * delta


func _on_Timer_timeout():
	queue_free()


func _on_Bullet_body_entered(body):
	if body is Enemy || body.is_in_group("Snake"):
		body.damage(10, Vector2.ZERO)
	queue_free()
