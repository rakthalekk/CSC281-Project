extends Area2D

# This is the value for how much unobtainium is in a stack
var count : int = 1

func _on_Unobtainium_body_entered(body):
	if body is Player:
		queue_free() #this deletes the entity when it is collected
		body.unobtainiumCount += count
