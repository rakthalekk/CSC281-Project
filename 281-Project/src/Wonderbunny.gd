extends Enemy

func _process(delta):
	if hp <= 0:
		queue_free()
		get_tree().change_scene("res://src/WinMenu.tscn")
	if knockback:
		velocity = direction * knockback_speed
	elif targets.size() > 0:
		$Sprite.texture = ANGRY
		pursue_target()
	else:
		$Sprite.texture = CALM
		wander(walk_speed)
	
	velocity = move_and_slide(velocity)
