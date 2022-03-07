extends RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_text("Player Coords:\nX: " + str(get_parent().get_parent().player.global_position[0]) + "\nY: " + str(get_parent().get_parent().player.global_position[1]))
