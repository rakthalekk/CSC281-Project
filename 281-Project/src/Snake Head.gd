class_name SnakeHead
extends KinematicBody2D

#Resource Reference
onready var snake_body = preload("res://src/Snake Body.tscn")
onready var tilemap = get_node("../../../Navigation2D/TileMap")
onready var attackCooldown = $AttackCooldown
onready var segmentAttackCooldown = $SegmentAttackCooldown
onready var invincibilityTimer = $InvincibilityTimer
onready var fleeTimer = $FleeTimer
onready var face = $Sprite
onready var faceTimer = $DirectionVisualChange
onready var hitSoundA = $HitA
onready var hitSoundB = $HitB
onready var animate = $AnimationPlayer
onready var segmentRegenTimer = $SegmentRegenTimer
onready var player = $"../../Player"

#Area Variables
var absoluteMinY = 24 #The absolute minY where the snake will turn around regardless
var minY = 40 #The Y where the snake will start to turn around/max depth of snake wandering
var minX = 0 #The X where the snake will start to turn around
var maxY = 64 # The Y where the Snake is normal
var maxX = 64 #The X where the snake will start to turn around

#Combat Variables
var speed = 200 #The Speed at which the snake moves
var dmg = 20 #Damage dealt by the snake head
var segments = 20 #The number of the snake segments
var segmentDmg = 10 #Damage dealt by the segments
var segmentAttackCooldownTime = 1 #Time between then the sement attacks going through
var max_head_health = 1 #Max health of the snake head
var max_segment_health = 1 #Health of each individual segment
var returnToAreaSpeedScale = 4 #Speed at which the snake returns back to its border
#Total health = head_health + segment_health * segments
var runAfterHitChance = 0.5 #If the snake gets hit, this is the chance it will retreat before attacking again
var attackCooldownTime = 3 #After the snake attacks something, it will wait this long before going for another attack
var attackStructureTime = 1 #Time the snake moves quickly after attacking a structure
var directPathVariance = PI/8 #Variance in the approach path of the snake
var fasterSpeedScale = 2  #When the snake moves faster, how fast will it move relative to normal speed
var chanceToRunWhenAttacked = 0.5#When the snake is hit in the head, this is the chance it will run from the player momentarily
var fleeingTailModifier = 0.5 #The scale for the chance for the snake to flee it's attacked and it still has a tail
var fleeTime = 3 #How long the snake flees after getting hit
var fleeSpeedScale = 2 #When the snake is fleeing, how fast it travels relative to normal
var invincibilityTime = 1.3 #The invincibility time of the head when attacked
var segmentInvincibilityTime = 1.3 #The invincibility time of the segment when attacked
var snakeSegmentRegen = true #If true, the snake will regen segments over time if not damaged
var segmentRegenTime = 7 #Time it takes for a segment to regenerate
var segmentRegenTimeLong = 20  #Time it takes for a segment to regenerate when no segments are left

#Scene Variables
var direction := Vector2.ZERO
var velocity := Vector2.ZERO
var rng = RandomNumberGenerator.new()
var knockback = false
var targets = []
var atBorder = false #a variable to control what the snake does when at the border
var isInAttackCooldown = false #Will be true if the snake is attacking
var hasSegmentAttackCooldown = false #Will be true if a segment has attacked something
var attackedStructure = false #The snake acts differently after attacking a structure
var actualSpeed = speed #Initially set speed
var health = max_head_health #Initially set health
var isFleeing = false #If the snake is fleeing the player, this will be true
var fleeTarget = null #The target being fleed from
var bodies = [] #The bodies of the snake

var dead = false

signal pan_boss_death

#Function needed to determine if the player is hitting the boss
func isBoss():
	return true

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pan_boss_death", player, "_on_BossDeath")
	direction.y = -1
	direction.x = 0
	attackCooldown.wait_time = attackCooldownTime
	fleeTimer.wait_time = fleeTime
	segmentAttackCooldown.wait_time = segmentAttackCooldownTime
	invincibilityTimer.wait_time = invincibilityTime
	segmentRegenTimer.wait_time = segmentRegenTime
	faceTimer.start()
	animate.play("RESET")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Get the Coords of the snake value of the snake
	var tilePos = Vector2(tilemap.world_to_map(global_position)[0], maxY - 1 - tilemap.world_to_map(global_position)[1])
	
	#The snake will turn back around regardless of what it's attacking
	if(tilePos[1] < absoluteMinY && !atBorder):
		atBorder = true
		actualSpeed = speed * returnToAreaSpeedScale
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
	elif(!atBorder && attackedStructure && attackCooldown.time_left < attackStructureTime):
		direction = direction.rotated(rng.randf_range(-0.015,0.015))
		
	#If the snake goes below the minY, it will start to turn itself back around
	elif(tilePos[1] < minY):
		if(direction[0] > 0 && direction[1] > 0):
			direction = direction.rotated(rng.randf_range(-0.2,0)) #Turn Counterclockwise
		elif(direction[0] < 0 && direction[1] > 0):
			direction = direction.rotated(rng.randf_range(0,0.2)) #Turn Clockwise
		#else:
		#	direction = direction.rotated(rng.randf_range(-0.2,0.2))
		
	#The snake will randomly wander when not targeting anything
	else:
		if(atBorder):
			actualSpeed = speed
		atBorder = false
		direction = direction.rotated(rng.randf_range(-0.2,0.2)) #Rotates the vector by a given amount
	
	#Move the snake
	direction = direction.normalized()
	velocity = direction * actualSpeed
	
	if !dead:
		move_and_slide(velocity)

# When the snake head takes damage
func damage(dmg, knockback = Vector2(0,0), hitByPlayer = false):
	#Knockback isn't used by the snake
	if invincibilityTimer.is_stopped() && !dead:
		#eff_anim_player.play("invulnerable")
		#print(str(targets))
		if(bodies.size() == 0):
			hitSoundB.play()
			animate.play("hit")
			start_invulnerability()
			health -= dmg
			if health <= 0:
				dead = true
				face.frame = 0
				animate.play("death")
				emit_signal("pan_boss_death", global_position)

			#If the snake is hit by the player, chance that it will flee
			if(hitByPlayer && rng.randf() <= chanceToRunWhenAttacked):
				isFleeing = true
				actualSpeed = speed * fleeSpeedScale
				fleeTarget = targets[0]
				fleeTimer.start()
		else:
			#Do something here if the snake still has a tail.
			#Here, the snake takes no damage
			hitSoundA.play()
			animate.play("armor_hit")
			if(hitByPlayer && rng.randf() <= chanceToRunWhenAttacked * fleeingTailModifier):
				isFleeing = true
				actualSpeed = speed * fleeSpeedScale
				fleeTarget = targets[0]
				fleeTimer.start()

#When the snake is attacked
func start_invulnerability(body = self):
	body.set_collision_layer_bit(9, false)
	if(body == self):
		body.invincibilityTimer.start()
	else:
		body.getInvincibilityTimer().start()
	

#When the snake ends invincibility
func end_invulnerability(body = self):
	#eff_anim_player.play("RESET")
	body.set_collision_layer_bit(9, true)

#Add things to queue to be attacked if in vision radius
func _on_VisionRadius_body_entered(body):
	#if the target is past the absolute minY
#	if(maxY - 1 - tilemap.world_to_map(body.global_position)[1] < minY):
#		#If the target is less than the absolute min, then they will be removed from the targets
#		var idx = targets.find(body)
#		if idx != -1:
#			targets.remove(idx)
	if body is Player:
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
	if(!isInAttackCooldown && body.has_method("damage") && (body is Player || body is Structure)):#&& !body.has_method("is_snake_body_segment")):
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

#Segment invincibility ending
func _on_segment_end_invincibility(index):
	end_invulnerability(bodies[index])

#Time it takes before the snake stops fleeing
func _on_FleeTimer_timeout():
	isFleeing = false
	actualSpeed = speed
	fleeTarget = null

#Method run when a segment attacks
func _on_segment_attack(index, attackBody):
	#Body is the attacked body, Index is the index of the segment in the array
	#Check if the body is one that can take damage
	if(index < bodies.size() && !hasSegmentAttackCooldown && attackBody.has_method("damage") && (attackBody is Player || attackBody is Structure)):#&& !attackBody.has_method("is_snake_body_segment") && !attackBody.has_method("isBoss")):
		#get the segment that hits the attack
		var segment = bodies[index]
		for body in segment.getHitbox().get_overlapping_bodies():
			if body is Player:
				var dir = (body.position - position).normalized()
				body.damage(segmentDmg, dir)
				hasSegmentAttackCooldown = true
				segmentAttackCooldown.start()
			elif body is Structure:
				body.damage(segmentDmg)
				hasSegmentAttackCooldown = true
				segmentAttackCooldown.start()

#Method run when a segment gets damaged
func _on_segment_damaged(index, dmg):
	#Knockback isn't used by the snake
	if(index >= bodies.size()):
		index = bodies.size() - 1
	var segment = bodies[index]
	if segment.getInvincibilityTimer().is_stopped():
		#eff_anim_player.play("invulnerable")
		start_invulnerability(segment)
		#Handles Segment health loss
		segment.health -= dmg
		#Handles segment death
		if segment.health <= 0:
			#If it's the only thing in the array
			if(bodies.size() == 1):
				segmentRegenTime = segmentRegenTimeLong
				segmentRegenTimer.wait_time = segmentRegenTime
				bodies.remove(0)
			#If the segment is at the front of the array
			elif(index == 0):
				bodies[index + 1].parent = self
				bodies.remove(index)
			#If the segment is at the back of the array
			elif(index == bodies.size() - 1):
				bodies.remove(index)
			#If segment is anywhere in between
			else:
				bodies[index + 1].parent = bodies[index - 1]
				bodies.remove(index)
			#Update all segment indexes
			for i in range(bodies.size()):
				bodies[i].index = i
			#Kill the segment
			segment.queue_free()
			#Start the timer
			segmentRegenTimer.start()

#When the bodies of the snake have been made, it passes the head a reference
func _on_Snake_bodies_ready(bodiesArray):
	bodies = bodiesArray
	for body in bodies:
		#Attach the signals from the bodies to the head
		body.connect("segment_attack", self, "_on_segment_attack")
		body.connect("segment_damaged", self, "_on_segment_damaged")
		body.connect("segment_end_invincibility", self, "_on_segment_end_invincibility")
		#Set the invincibility Timer time for the segment
		body.getInvincibilityTimer().wait_time = segmentInvincibilityTime
		#Set the segment health
		body.health = max_segment_health
	#print(str(bodies))

#When segment cooldown runs out
func _on_SegmentAttackCooldown_timeout():
	hasSegmentAttackCooldown = false

func _on_DirectionVisualChange_timeout():
	var dir = direction.angle_to(Vector2.UP)
	if(!dead):
		if (dir > 0):
			if (dir < 3 * PI / 4):
				if (dir < PI / 4):
					face.frame = 2
				else:
					face.frame = 1 
			else:
				face.frame = 0
		else:
			if (dir > -3 * PI / 4):
				if (dir > -PI / 4):
					face.frame = 2
				else:
					face.frame = 3
			else:
				face.frame = 0

#When the timer goes off for regenerating segments, it will regen one
func _on_SegmentRegenTimer_timeout():
	if(bodies.size() < segments && !dead):
		segmentRegenTimer.wait_time = segmentRegenTime
		segmentRegenTimer.start(segmentRegenTime)
		var new_segment: KinematicBody2D = snake_body.instance()
		#Attach the signals from the bodies to the head
		new_segment.connect("segment_attack", self, "_on_segment_attack")
		new_segment.connect("segment_damaged", self, "_on_segment_damaged")
		new_segment.connect("segment_end_invincibility", self, "_on_segment_end_invincibility")
		#Set the invincibility Timer time for the segment
		new_segment.getInvincibilityTimer().wait_time = segmentInvincibilityTime
		#Set the segment health
		new_segment.health = max_segment_health
		#Set the index
		new_segment.index = bodies.size()
		#Set body parent
		if(bodies.size() == 0):
			new_segment.parent = self
			new_segment.setPosition(self.global_position - get_parent().global_position)#Vector2(2027,530))
		else:
			new_segment.parent = bodies[bodies.size() - 1]
			new_segment.setPosition(bodies[bodies.size() - 1].global_position - get_parent().global_position)
		#Add body to the side
		bodies.append(new_segment)
		get_parent().add_child(new_segment)
	#If snake has max bodies, stop the timer
	if(bodies.size() >= segments):
		segmentRegenTimer.stop()


func _on_SegmentHealTimer_timeout():
	for body in bodies:
		if body.health + 10 < max_segment_health:
			body.health += 10

func onDeathEnd():
	get_tree().change_scene("res://src/WinMenu.tscn")
