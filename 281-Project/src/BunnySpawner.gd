extends Node2D


signal spawn_bunny


export(int) var nearby_entity_spawn_time = 6;
export(int) var no_nearby_entity_spawn_time = 12;

var entities_in_range = []
var raid_spawns = 0
var max_spawns

onready var parent = $".."

func _ready():
	connect("spawn_bunny", parent, "_on_Burrow_spawn_bunny")
	max_spawns = int(rand_range(6, 9))
	#$AnimationPlayer.play("normal")


# Initiates Goku Mode
func interact():
	$SpawnTimer.stop()
	$AlertTimer.stop()
	$AnimationPlayer.play("raid")


func raid_spawn():
	if raid_spawns < max_spawns:
		emit_signal("spawn_bunny", global_position)
		raid_spawns += 1
	else:
		$Alert.visible = false
		$AnimationPlayer.stop()
		rotation_degrees = 180


func _on_Timer_timeout():
	# Won't spawn more enemies if there are 4 or more within the radius
	if $SpawnRadius.get_overlapping_bodies().size() < 4:
		$AlertTimer.start()
		$Alert.visible = true
	else:
		$SpawnTimer.start()


func _on_Timer2_timeout():
	emit_signal("spawn_bunny", global_position)
	$Alert.visible = false
	
	var time = no_nearby_entity_spawn_time * rand_range(1, 1.5)
	if entities_in_range.size() > 0:
		time = nearby_entity_spawn_time * rand_range(1, 1.5)
		
	$SpawnTimer.start(time)


func _on_EntityDetectionField_body_entered(body):
	entities_in_range.append(body)


func _on_EntityDetectionField_body_exited(body):
	if entities_in_range.has(body):
		entities_in_range.erase(body)
