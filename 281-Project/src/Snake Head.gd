class_name SnakeHead
extends KinematicBody2D

#Map Reference
onready var tilemap = get_node("../../Navigation2D/TileMap")
onready var attackCooldown = $AttackCooldown
onready var invincibilityTimer = $InvincibilityTimer
onready var fleeTimer = $FleeTimer

#Area Variables
var absoluteMinY = 24 #The absolute minY where the snake will turn around regardless
var minY = 40 #The Y where the snake will start to turn around/max depth of snake wandering
var minX = 0 #The X where the snake will start to turn around
var maxY = 64 # The Y where the Snake is normal
var maxX = 64 #The X where the snake will start to turn around

#Combat Variables
var speed = 200 #The Speed at which the snake moves
var dmg = 10 #Damage dealt by the snake
var max_health = 100 #Max health of the snake
var runAfterHitChance = 0.5 #If the snake gets hit, this is the chance it will retreat before attacking again
var attackCooldownTime = 3 #After the snake attacks something, it will wait this long before going for another attack
var attackStructureTime = 1 #Time the snake moves quickly after attacking a structure
var directPathVariance = PI/8 #Variance in the approach path of the snake
var fasterSpeedScale = 2  #When the snake moves faster, how fast will it move relative to normal speed
var chanceToRunWhenAttacked = 1 #0.5#When the snake is hit in the head, this is the chance it will run from the player momentarily
var fleeTime = 3 #How long the snake flees after getting hit
var fleeSpeedScale = 2 #When the snake is fleeing, how fast it travels relative to normal

#Scene Variables
var direction := Vector2.ZERO
var velocity := Vector2.ZERO
var rng = RandomNumberGenerator.new()
var knockback = false
var targets = []
var atBorder = false #a variable to control what the snake does when at the border
var isInAttackCooldown = false #Will be true if the 
var attackedStructure = false #The snake acts differently after attacking a structure
var actualSpeed = speed #Initially set speed
var health = max_health #Initially set health
var isFleeing = false #If the snake is fleeing the player, this will be true
var fleeTarget = null #The target being fleed from


#Function needed to determine if the player is hitting the boss
func isBoss():
	return true

# Called when the node enters the scene tree for the first time.
func _ready():
	direction.y = -1
	direction.x = 0
	attackCooldown.wait_time = attackCooldownTime
	fleeTimer.wait_time = fleeTime

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Get the Coords of the snake value of the snake
	var tilePos = Vector2(tilemap.world_to_map(global_position)[0], maxY - 1 - tilemap.world_to_map(global_position)[1])
	
	#The snake will turn back around regardless of what it's attacking
	if(tilePos[1] < absoluteMinY && !atBorder):
		atBorder = true
		if(direction[0] > 0 && direction[1] > 0):
			direction = direction.rotated(rng.randf_range(-0.2,0)) #Turn Counterclockwise
		elif(direction[0] < 0 && direction[1] > 0):
			direction = direction.rotated(rng.randf_range(0,0.2)) #Turn Clockwise
		else:
			direction = direction.rotated(rng.randf_range(-0.2,0.2))
		
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
	
	#If the snake is fleeing
	elif(isFleeing):
		#The snake will auto target the target at the first index
		#var ang = direction.angle_to(global_position.direction_to(targets[0].global_position))
		var ang = direction.angle_to(global_position.direction_to(fleeTarget.global_position))
		if( ang >= -directPathVariance && ang <= directPathVariance):
			direction = direction.rotated(rng.randf_range(-0.2,0.2))
		elif( ang > 0 && ang <= PI):
			direction = direction.rotated(rng.randf_range(-0.2,0)) #Turn Counterclockwise
		else:
			direction = direction.rotated(rng.randf_range(0,0.2)) #Turn Clockwise
	
	#The snake will attack targets if they exists -- won't try to attack if at border or in attack cooldown 
	elif(targets.size() > 0 && !atBorder && !isInAttackCooldown):
		#The snake will auto target the target at the first index
		var ang = direction.angle_to(global_position.direction_to(targets[0].global_position))
		if( ang >= -directPathVariance && ang <= directPathVariance):
			direction = direction.rotated(rng.randf_range(-0.2,0.2))
		elif( ang > 0 && ang <= PI):
			direction = direction.rotated(rng.randf_range(0,0.2)) #Turn Clockwise
		else:
			direction = direction.rotated(rng.randf_range(-0.2,0)) #Turn Counterclockwise
		
	#If the snake attacked a structure, continue in a straight line for a bit before random movement?
	elif(attackedStructure && attackCooldown.time_left < attackStructureTime):
		direction = direction.rotated(rng.randf_range(-0.015,0.015))
		
	#If the snake goes below the minY, it will start to turn itself back around
	elif(tilePos[1] < minY):
		if(direction[0] > 0 && direction[1] > 0):
			direction = direction.rotated(rng.randf_range(-0.2,0)) #Turn Counterclockwise
		elif(direction[0] < 0 && direction[1] > 0):
			direction = direction.rotated(rng.randf_range(0,0.2)) #Turn Clockwise
		else:
			direction = direction.rotated(rng.randf_range(-0.2,0.2))
		
	#The snake will randomly wander when not targeting anything
	else:
		direction = direction.rotated(rng.randf_range(-0.2,0.2)) #Rotates the vector by a given amount
	
	#Move the snake
	direction = direction.normalized()
	velocity = direction * actualSpeed
	move_and_slide(velocity)

# When the snake takes damage
func damage(dmg, knockback = Vector2(0,0), hitByPlayer = false):
	#Knockback isn't used by the snake
	if invincibilityTimer.is_stopped():
		#eff_anim_player.play("invulnerable")
		set_collision_layer_bit(9, false)
		invincibilityTimer.start()
		health -= dmg
		if health <= 0:
			queue_free()
			get_tree().change_scene("res://src/WinMenu.tscn")
		#If the snake is hit by the player, chance that it will flee
		if(hitByPlayer && rng.randf() <= chanceToRunWhenAttacked):
			isFleeing = true
			print("IS FLEEING")
			actualSpeed = speed * fleeSpeedScale
			fleeTarget = targets[0]
			fleeTimer.start()

func end_invulnerability():
	#eff_anim_player.play("RESET")
	set_collision_layer_bit(9, true)

#Add things to queue to be attacked if in vision radius
func _on_VisionRadius_body_entered(body):
	#if the target is past the absolute minY
	if(maxY - 1 - tilemap.world_to_map(body.global_position)[1] < minY):
		#If the target is less than the absolute min, then they will be removed from the targets
		var idx = targets.find(body)
		if idx != -1:
			targets.remove(idx)
	elif body is Player:
		targets.insert(0, body)
	elif body is Structure:
		targets.append(body)

#Remove things from queue to be attacked if they're out of radius
func _on_VisionRadius_body_exited(body):
	var idx = targets.find(body)
	if idx != -1:
		targets.remove(idx)

#If the snake attacks something -- 
# 1: Do damage to that thing
# 2: Put the snake in a state of recoil/delay before going back in again to attack
func _on_HitBox_body_entered(body):
	#Check if the body is one that can take damage
	if(body.has_method("damage")):
		for body in $Hitbox.get_overlapping_bodies():
			if body is Player:
				var dir = (body.position - position).normalized()
				body.damage(dmg, dir)
				isInAttackCooldown = true
				attackCooldown.start()
				actualSpeed = speed * fasterSpeedScale
			elif body is Structure:
				body.damage(dmg)
				isInAttackCooldown = true
				attackedStructure = true
				attackCooldown.start()
				actualSpeed = speed * fasterSpeedScale

#When the timer stops, this triggers so the snake will start looking to attack again
func _on_AttackCooldown_timeout():
	isInAttackCooldown = false
	attackedStructure = false
	actualSpeed = speed

#When the snake gets it, it will have an invinciblility
func _on_InvincibilityTimer_timeout():
	end_invulnerability()

#Time it takes before the snake stops fleeing
func _on_FleeTimer_timeout():
	print("STOPPED FLEEING")
	isFleeing = false
	actualSpeed = speed
	fleeTarget = null
