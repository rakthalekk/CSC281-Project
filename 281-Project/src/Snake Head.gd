extends KinematicBody2D

#Map Reference
onready var tilemap = get_node("../../Navigation2D/TileMap")

#Modifiable Variables
var absoluteMinY = 32 #The absolute minY where the snake will turn around regardless
var minY = 40 #The Y where the snake will start to turn around
var maxY = 64#tilemap.fieldWidth # The Y where the Snake is normal
var minX = 0 #The X where the snake will start to turn around
var maxX = 64#tilemap.fieldLength #The X where the snake will start to turn around
var speed = 200 #The Speed at which the snake moves

#Scene Variables
#var target = null
var knockback = false
var targets = []
#var atBorder = false #a variable to control what the snake does when at the border

# Declare member variables here. Examples:
var direction := Vector2.ZERO
var velocity := Vector2.ZERO
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	direction.y = -1
	direction.x = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Get the Coords of the snake value of the snake
	var tilePos = Vector2(tilemap.world_to_map(global_position)[0], 64 - 1 - tilemap.world_to_map(global_position)[1])
	
	#Wander toward a target if it has one
	#The snake will turn back around regardless of what it's attacking
	if(tilePos[1] < absoluteMinY):# && !atBorder):
		#atBorder = true
		if(direction[0] > 0 && direction[1] > 0):
			direction = direction.rotated(rng.randf_range(-0.2,0)) #Turn Counterclockwise
		elif(direction[0] < 0 && direction[1] > 0):
			direction = direction.rotated(rng.randf_range(0,0.2)) #Turn Clockwise
		else:
			direction = direction.rotated(rng.randf_range(-0.2,0.2))
	#The snake will attack targets if they exists
	elif(targets.size() > 0):# && !atBorder):
		#The snake will auto target the target at the first index
		var ang = direction.angle_to(global_position.direction_to(targets[0].global_position))
		if( ang > 0 && ang <= PI):
			direction = direction.rotated(rng.randf_range(0,0.2)) #Turn Clockwise
		else:
			direction = direction.rotated(rng.randf_range(-0.2,0)) #Turn Counterclockwise
		
	#If the snake goes below the minY, it will start to turn itself back around
	elif(tilePos[1] < minY):
		if(direction[0] > 0 && direction[1] > 0):
			direction = direction.rotated(rng.randf_range(-0.2,0)) #Turn Counterclockwise
		elif(direction[0] < 0 && direction[1] > 0):
			direction = direction.rotated(rng.randf_range(0,0.2)) #Turn Clockwise
		else:
			direction = direction.rotated(rng.randf_range(-0.2,0.2))
		#print(str(actualY) + " " + str(direction))
	#Going off the top side of the map
	elif(tilePos[1] >= maxY):
		if(direction[0] < 0 && direction[1] < 0):
			direction = direction.rotated(rng.randf_range(-0.2,0)) #Turn Counterclockwise
		elif(direction[0] > 0 && direction[1] < 0):
			direction = direction.rotated(rng.randf_range(0,0.2)) #Turn Clockwise
		else:
			direction = direction.rotated(rng.randf_range(-0.2,0.2))
	#Going off the left side of the map
	elif(tilePos[0] <= minX):
		if(direction[1] > 0 && direction[0] < 0):
			direction = direction.rotated(rng.randf_range(-0.2,0)) #Turn Counterclockwise
		elif(direction[1] < 0 && direction[0] < 0):
			direction = direction.rotated(rng.randf_range(0,0.2)) #Turn Clockwise
		else:
			direction = direction.rotated(rng.randf_range(-0.2,0.2))
	#Going off the right side of the map
	elif(tilePos[0] >= maxX):
		if(direction[1] < 0 && direction[0] > 0):
			direction = direction.rotated(rng.randf_range(-0.2,0)) #Turn Counterclockwise
		elif(direction[1] > 0 && direction[0] > 0):
			direction = direction.rotated(rng.randf_range(0,0.2)) #Turn Clockwise
		else:
			direction = direction.rotated(rng.randf_range(-0.2,0.2))
	#The snake will randomly wander when not targeting anything
	else:
		#atBorder = false
		direction = direction.rotated(rng.randf_range(-0.2,0.2)) #Rotates the vector by a given amount
	direction = direction.normalized()
	velocity = direction * speed
	#print(str(velocity))
	move_and_slide(velocity)


func _on_VisionRadius_body_entered(body):
	if(Vector2(tilemap.world_to_map(body.global_position)[0], 64 - 1 - tilemap.world_to_map(body.global_position)[1])):
		pass
	if body is Player:
		#target = body
		targets.insert(0, body)
	elif body is Structure:
		targets.append(body)


func _on_VisionRadius_body_exited(body):
	var idx = targets.find(body)
	if idx != -1:
		targets.remove(idx)

	#if body is Player:
	#	target = null
