extends Enemy



func _on_Hitbox_body_entered(body):
	if !knockback:
		anim_player.play("bite")
