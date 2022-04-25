extends Structure




func _on_InvincibilityTimer_timeout():
	end_invulnerability()


func _on_HealZone_body_entered(body):
	if body != self:
		body.heal(20)


func _on_ActivateInterval_timeout():
	anim_player.play("heal")


func _on_HealRingTimer_timeout():
	$HealRing.visible = false
