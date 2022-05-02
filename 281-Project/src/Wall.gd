class_name Wall
extends Structure

const VERTICAL_IMG = preload("res://assets/Structures/sandbagsvertical.png")

var active = true
var vertical = false
var mouse_inside = false


func _unhandled_input(event):
	if event.is_action_pressed("right_click") && mouse_inside:
		change_active()


func change_active():
	if active:
		active = false
		$CollisionShape2D.disabled = true
		$Sprite.modulate = Color(1, 1, 1, 0.5)
	else:
		active = true
		$CollisionShape2D.disabled = false
		$Sprite.modulate = Color(1, 1, 1, 1)


func set_vertical():
	vertical = true
	$CollisionShape2D.rotation_degrees = 90
	$Sprite.texture = VERTICAL_IMG
	$ClickableArea.rotation_degrees = 90


func _on_InvincibilityTimer_timeout():
	end_invulnerability()


func _on_HealRingTimer_timeout():
	$HealRing.visible = false


func _on_ClickableArea_mouse_entered():
	mouse_inside = true


func _on_ClickableArea_mouse_exited():
	mouse_inside = false
