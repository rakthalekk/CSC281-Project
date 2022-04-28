extends KinematicBody2D

var parent: KinematicBody2D = null

func follow_parent() -> void:
	self.global_transform.origin = lerp(self.global_transform.origin, 
		parent.global_transform.origin, get_physics_process_delta_time() * 1.5)
	#self.rotation_degrees = lerp(self.rotation_degrees, 
	#	parent.rotation_degrees, get_physics_process_delta_time() * 0)
func _process(delta: float) -> void:
	if (self.global_transform.origin.distance_squared_to(parent.global_transform.origin) > 5000):
		follow_parent()
