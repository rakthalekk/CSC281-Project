extends KinematicBody2D


# Declare member variables here. Examples:
var direction := Vector2.ZERO
var velocity := Vector2.ZERO
var speed = 300
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	direction.y = -1
	direction.x = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	direction = direction.rotated(rng.randf_range(-0.2,0.2))
	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide(velocity)
