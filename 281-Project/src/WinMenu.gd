extends Control


func _ready():
	var minutes = int(Global.time / 60)
	var seconds = Global.time - minutes * 60
	
	$TimeLabel.set_text("Completed in " + ("%02d" % minutes) + ":" + ("%02d" % seconds))


func _on_StartButton_pressed():
	get_tree().change_scene("res://src/Main.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_MainMenuButton_pressed():
	get_tree().change_scene("res://src/MainMenu.tscn")
