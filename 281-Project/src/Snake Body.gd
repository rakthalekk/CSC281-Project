extends KinematicBody2D

var parent: KinematicBody2D = null

#If the segment attacks something, lets the head know to react
signal segment_attack
#If the segment receives damage, lets the head know to react
signal segment_damaged
#If the segment's invincibility timer finishes
signal segment_end_invincibility

#The current index of the body
var index = -1
#The current health of the segment
var health = -1

#Function used to determine if the affected object is a body segment of the snake
func is_snake_body_segment():
	return true

#Returns the timer for the segment
func getInvincibilityTimer():
	return $InvincibilityTimer

func follow_parent() -> void:
	self.global_transform.origin = lerp(self.global_transform.origin, 
		parent.global_transform.origin, get_physics_process_delta_time() * 1.5)
	#self.rotation_degrees = lerp(self.rotation_degrees, 
	#	parent.rotation_degrees, get_physics_process_delta_time() * 0)

func _process(delta: float) -> void:
	if (self.global_transform.origin.distance_squared_to(parent.global_transform.origin) > 5000):
		follow_parent()

#If the segment attacks something
func _on_Hitbox_body_entered(attackedBody):
	emit_signal("segment_attack", index, attackedBody)

#If it takes damage
func damage(dmg, knockback = Vector2(0,0), hitByPlayer = false):
	print("SEGMENT HIT BY SOMETHING")
	emit_signal("segment_damaged", index, dmg)


func _on_InvincibilityTimer_timeout():
	emit_signal("segment_end_invincibility", index)
