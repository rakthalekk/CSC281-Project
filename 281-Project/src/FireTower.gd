extends Structure

var targets = []

onready var sound = $AudioStreamPlayer2D

func disable_attack():
	$DamageInterval.stop()
	anim_player.play("idle")


func _on_InvincibilityTimer_timeout():
	end_invulnerability()


func _on_DamageInterval_timeout():
	for e in $FireZone.get_overlapping_bodies():
		if e is Enemy:
			e.damage(5, Vector2.ZERO)


func _on_FireZone_body_entered(body):
	if $DamageInterval.time_left == 0:
		$DamageInterval.start()
	
	anim_player.play("fire")
	sound.play()
	targets.append(body)


func _on_HealRingTimer_timeout():
	$HealRing.visible = false


func _on_FireZone_body_exited(body):
	if body in targets:
		targets.erase(body)
	if targets.size() == 0:
		sound.stop()
		disable_attack()
