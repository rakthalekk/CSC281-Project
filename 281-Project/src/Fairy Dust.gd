extends Area2D


func _on_Fairy_Dust_body_entered(body):
	if body is Player:
		queue_free() #this deletes the entity when it is collected
		body.fairyDustCount += 1
