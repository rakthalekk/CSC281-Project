extends Node2D


signal spawn_bunny


onready var parent = $".."

func _ready():
	connect("spawn_bunny", parent, "_on_Burrow_spawn_bunny")


func _on_Timer_timeout():
	# Won't spawn more enemies if there are 6 or more within the radius
	if $SpawnRadius.get_overlapping_bodies().size() < 6:
		$Timer2.start()
		$Alert.visible = true
	else:
		$Timer.start()


func _on_Timer2_timeout():
	emit_signal("spawn_bunny", global_position)
	$Alert.visible = false
	$Timer.start()
