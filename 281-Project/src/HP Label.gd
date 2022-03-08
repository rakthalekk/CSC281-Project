extends RichTextLabel


func _on_Player_update_health(hp):
	set_text("HP: " + str(hp))
