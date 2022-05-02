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
			Global.selected_item = null
			Input.set_custom_mouse_cursor(null)


func _on_Button_pressed():
	hide()
	get_tree().paused = false


func _on_Main_Menu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://src/MainMenu.tscn")
