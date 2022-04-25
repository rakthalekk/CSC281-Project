class_name Wall
extends Structure

const VERTICAL_IMG = preload("res://assets/Structures/sandbagsvertical.png")

var active = true
var vertical = false

func set_vertical():
	vertical = true
	$CollisionShape2D.rotation_degrees = 90
	$Sprite.texture = VERTICAL_IMG
	$ButtonControl.rotation_degrees = 90


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


func _on_HealRingTimer_timeout():
	$HealRing.visible = false
