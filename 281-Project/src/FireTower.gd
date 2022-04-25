extends Structure



func disable_attack():
	$DamageInterval.stop()
	anim_player.play("idle")


func _on_InvincibilityTimer_timeout():
	end_invulnerability()


func _on_ActivateInterval_timeout():
	anim_player.play("fire")
	$DamageInterval.start()


func _on_DamageInterval_timeout():
	for e in $FireZone.get_overlapping_bodies():
		if e is Enemy:
			e.damage(5, Vector2.ZERO)


func _on_FireZone_body_entered(body):
	if body is Enemy:
		body.damage(10, Vector2.ZERO)


func _on_HealRingTimer_timeout():
	$HealRing.visible = false
