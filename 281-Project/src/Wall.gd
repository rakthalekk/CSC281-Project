class_name Wall
extends Structure

var active = true


func _on_InvincibilityTimer_timeout():
	end_invulnerability()


func _on_Button_pressed():
	if active:
		active = false
		$CollisionShape2D.disabled = true
		$Sprite.modulate = Color(1, 1, 1, 0.5)
	else:
		active = true
		$CollisionShape2D.disabled = false
		$Sprite.modulate = Color(1, 1, 1, 1)
