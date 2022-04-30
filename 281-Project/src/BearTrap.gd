extends Structure

var enabled = true

func interact():
	if $HitArea/CollisionShape2D.disabled:
		anim_player.play("unsnap")
		enabled = true


func reactivate():
	call_deferred("toggle_hitbox", false)
	anim_player.play("idle")


func snap():
	for target in $HitArea.get_overlapping_bodies():
		if target is Enemy:
			target.damage(50, Vector2.ZERO)
		elif target.is_in_group("Snake"):
			target.damage(20)
	call_deferred("toggle_hitbox", true)


func toggle_hitbox(off):
	$HitArea/CollisionShape2D.disabled = off
	$CollisionShape2D.disabled = !off


func _on_HitArea_body_entered(body):
	if enabled:
		anim_player.play("snap")
		enabled = false


func _on_HealRingTimer_timeout():
	$HealRing.visible = false


func _on_InvincibilityTimer_timeout():
	end_invulnerability()
