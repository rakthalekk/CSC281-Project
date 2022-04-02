extends Enemy

func _process(delta):
	if hp <= 0:
		queue_free()
		get_tree().change_scene("res://src/WinMenu.tscn")
