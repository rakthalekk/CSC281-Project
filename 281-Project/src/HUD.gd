extends CanvasLayer


func _on_Player_player_stats_changed(var player):
	$"Health Bar/Bar".rect_size.x = 200 * player.health / player.max_health
	
	$"Health Bar/Number Label".set_text(str(player.health) + " / " + str(player.max_health))
	
	$"Unobtainium Display/Number".set_text(str(player.unobtainiumCount))
