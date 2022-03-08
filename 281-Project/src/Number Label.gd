extends RichTextLabel

func _on_Player_player_stats_changed(var player):
	set_text(str(player.health) + " / " + str(player.max_health))
