extends Structure

signal make_bullet

var targets = []


func _on_VisionRadius_body_entered(body):
	targets.append(body)


func _on_VisionRadius_body_exited(body):
	targets.erase(body)


func _on_ShootInterval_timeout():
	var target = null
	var smallest_distance = 9999
	for t in targets:
		var distance = global_position.distance_to(t.global_position)
		if distance < smallest_distance:
			target = t
			smallest_distance = distance
	
	if target:
		var direction = (target.global_position - global_position).normalized()
		emit_signal("make_bullet", global_position, direction)


func _on_InvincibilityTimer_timeout():
	end_invulnerability()
