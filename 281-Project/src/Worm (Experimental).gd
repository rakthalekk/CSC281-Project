extends KinematicBody2D


# Declare member variables here. Examples:
var velocity := Vector2.ZERO
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = -36
	velocity.y = 0
	pass # Replace with function body.


func _process(delta):
	velocity = velocity.rotated(rng.randf_range(-0.1,0.1))
	move_and_slide(velocity)
