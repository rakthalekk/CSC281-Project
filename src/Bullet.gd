extends Area2D

export(int) var speed = 30

var direction := Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += direction * speed


func _on_Timer_timeout():
	queue_free()
