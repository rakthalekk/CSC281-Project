extends Node2D


signal spawn_bunny


func _on_Timer_timeout():
	emit_signal("spawn_bunny", global_position)
