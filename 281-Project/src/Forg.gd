extends Enemy


var queue_attack = false


func play_jump():
	anim_player.play("hop")


func manage_animation():
	if !knockback && queue_attack && anim_player.current_animation == "stance":
		anim_player.play("attack")
		queue_attack = false
	
	if !knockback && anim_player.current_animation == "attack":
		velocity = Vector2.ZERO
	elif !knockback && anim_player.current_animation != "hop":
		velocity = Vector2.ZERO
		anim_player.play("stance")


func _on_EntityDetect_body_entered(body):
	queue_attack = true
	$Tounge.look_at(body.global_position - Vector2(0, 20))


func _on_Tounge_body_entered(body):
	if body is Player:
		var dir = (body.position - position).normalized()
		body.damage(dmg, dir)
	else:
		body.damage(dmg)
