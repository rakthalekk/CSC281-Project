extends CanvasLayer


const DRILL_IMG = preload("res://assets/Resources/drillcursor.png")
const TURRET_IMG = preload("res://icon.png")


func _on_Player_player_stats_changed(var player):
	$"Health Bar/Bar".rect_size.x = 200 * player.health / player.max_health
	
	$"Health Bar/Number Label".set_text(str(player.health) + " / " + str(player.max_health))
	
	$"Unobtainium Display/Number".set_text(str(player.unobtainiumCount))


func _on_Drill_Item_toggled(button_pressed):
	if Global.selected_structure != "drill":
		Input.set_custom_mouse_cursor(DRILL_IMG)
		Global.selected_structure = "drill"
	else:
		Input.set_custom_mouse_cursor(null)
		Global.selected_structure = null


func _on_Turret_Item_toggled(button_pressed):
	if Global.selected_structure != "turret":
		Input.set_custom_mouse_cursor(TURRET_IMG)
		Global.selected_structure = "turret"
	else:
		Input.set_custom_mouse_cursor(null)
		Global.selected_structure = null
