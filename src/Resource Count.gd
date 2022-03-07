extends RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_text("Resource Count:\nUnobtainium:	" + str(get_parent().get_parent().player.unobtainiumCount) + "\nFairy Dust:		 " + str(0))
