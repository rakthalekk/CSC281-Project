extends Structure

signal make_bullet

var targets = []
var target = null
var frame = 0

var bullet_queue = false


func _on_VisionRadius_body_entered(body):
	targets.append(body)


func _on_VisionRadius_body_exited(body):
	targets.erase(body)


func _on_ShootInterval_timeout():
	if target:
		bullet_queue = true


func _on_InvincibilityTimer_timeout():
	end_invulnerability()


func _on_RotateAnimationFrame_timeout():
	target = null
	var smallest_distance = 9999
	for t in targets:
		var distance = global_position.distance_to(t.global_position)
		if distance < smallest_distance:
			target = t
			smallest_distance = distance
	
	if target:
		anim_player.play("sighting")
		
		var dir = (target.global_position - global_position).normalized()
		var angle = rad2deg(dir.angle_to(Vector2.DOWN))
		if angle < 0:
			angle = angle + 360

		frame = int(round(angle / (360 / 16)))
		if frame == 16:
			frame = 0
	elif anim_player.current_animation != "idle":
		anim_player.play("idle")
		anim_player.advance(frame / 10.0)
	
	if $AnimationPlayer.current_animation == "sighting":
		var up = (frame - $Sprite.frame) % 16
		var down = ($Sprite.frame - frame) % 16
		
		if down < up:
			if $Sprite.frame + 1 == 16:
				$Sprite.frame = 0
			else:
				$Sprite.frame += 1
		elif up < down:
			if $Sprite.frame - 1 == -1:
				$Sprite.frame = 15
			else:
				$Sprite.frame -= 1
		elif bullet_queue:
			var direction = (target.global_position - global_position).normalized()
			emit_signal("make_bullet", global_position, direction)
			bullet_queue = false


func _on_HealRingTimer_timeout():
	$HealRing.visible = false
