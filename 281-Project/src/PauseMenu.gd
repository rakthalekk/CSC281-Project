extends PopupDialog


onready var parent = $".."

func _unhandled_input(event):
	if !parent.disable_pause:
		if event.is_action_pressed("pause"):
			if get_tree().paused:
				_on_Button_pressed()
			else:
				show()
				get_tree().paused = true


func _on_Button_pressed():
	hide()
	get_tree().paused = false
