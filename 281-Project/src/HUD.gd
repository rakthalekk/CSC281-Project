extends CanvasLayer


const DRILL_IMG = preload("res://assets/Resources/drillcursor.png")
const TURRET_IMG = preload("res://assets/Resources/turretcursor.png")


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


func _on_Player_is_manual_mining(var player):
	if(player.manual_mining_timer.time_left == 0):
		$"Mining Display/Cooldown Display".set_frame_color(Color(0.65,0.65,0.65,1))
		$"Mining Display/Mining Time".set_text("")
	else:
		$"Mining Display/Cooldown Display".set_frame_color(Color(0.65,0.65,0.65,sqrt(player.manual_mining_timer.time_left/player.manual_mining_time)))
		$"Mining Display/Mining Time".set_text(str(player.manual_mining_timer.time_left))
