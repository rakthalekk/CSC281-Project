class_name Player
extends KinematicBody2D

# Universal Vars for the Player
export(int) var run_speed = 300
export(int) var knockback_speed = 400
export(int) var dmg = 10
export(int) var max_health = 100
export(int) var manual_mining_time = 5
export(int) var harvesting_time = 3
export var onTile = "None"

# Player Signals
signal make_bullet
signal create_drill
signal update_health
signal place_structure

# Used to indicate the players' stats have changed
signal player_stats_changed
# Used to show when the player is mining
signal is_manual_mining
# Used to show when the player is interacting
signal is_interacting

onready var anim_player = $AnimationPlayer
onready var sound_player = $Jackhammer
onready var eff_anim_player = $EffectsAnimationPlayer
onready var invincibility_timer = $InvincibilityTimer
onready var manual_mining_timer = $ManualMiningTimer
onready var harvest_timer = $HarvestTimer
onready var combatTimer = $CombatTimer
onready var regenTimer = $RegenTimer

var direction := Vector2.ZERO
var speed = run_speed
var velocity := Vector2.ZERO

# Current resources of the player
export(int) var unobtainiumCount : int = 0
export(int) var fairyDustCount : int = 0
export(int) var dragonOilCount : int = 0
var knockback = false
var attacking = false
var manual_mining = false
var interacting = false
var can_attack = true


# Variables for detecting bein near fairy trees
var harvest_fairy_dust = false #if the player is near a fairy tree
var nearLog = null #reference to the fairy tree the player is near

# Current Health of the player
onready var health : int = max_health

# Used to detect when the players' stats have changed to update the HUD
var prevUCount : int = unobtainiumCount
var prevFDCount : int = fairyDustCount
var prevDOCount : int = dragonOilCount
onready var prevHealth : int = health

# Used to check whether the player has specific things
var hasFairySwatter = false

func _ready():
	#emit the initial stats of the player,
	if(Global.difficulty == 0):
		combatTimer.waitTime = 10
	if(Global.difficulty == 2):
		combatTimer.waitTime = 99999
	emit_signal("player_stats_changed", self)
	emit_signal("is_manual_mining", self)

# Process function called every frame
func _process(delta):
	if health <= 0:
		#Global.reset_level()
		get_tree().change_scene("res://src/DeathMenu.tscn")

	if knockback:
		velocity = direction * knockback_speed
	else:
		direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
		direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		direction = direction.normalized()
		velocity = direction * speed
	
	# Play animation based on player walk direction
	if !attacking && !knockback:
		if !manual_mining:
			if sound_player.playing:
				sound_player.stop()
		if manual_mining:
			anim_player.play("jackhammer")
			if !sound_player.playing:
				sound_player.play()
		elif direction.x > 0:
			anim_player.play("walk_right")
		elif direction.x < 0:
			anim_player.play("walk_left")
		elif direction.y > 0:
			anim_player.play("walk_down")
		elif direction.y < 0:
			anim_player.play("walk_up")
		else:
			anim_player.play("idle")
			sound_player.stop()
	
	move_and_slide(velocity)
	
	# Stat Checking - will emit signal if stats changed
	if(unobtainiumCount != prevUCount || fairyDustCount != prevFDCount || dragonOilCount != prevDOCount || health != prevHealth):
		prevUCount = unobtainiumCount
		prevFDCount  = fairyDustCount
		prevDOCount  = dragonOilCount
		prevHealth = health
		emit_signal("player_stats_changed", self)
	
	# Handles Manual Mining
	if(manual_mining):
		if(onTile == "Unobtainium" && $ManualMiningTimer.time_left == 0):
			$ManualMiningTimer.start(manual_mining_time)
		if(onTile != "Unobtainium"):
			stop_manual_mining()
		emit_signal("is_manual_mining", self)
	elif interacting:
		emit_signal("is_interacting", self)


func stop_manual_mining():
	manual_mining = false
	$ManualMiningTimer.stop()
	$ManualMiningTimer.set_wait_time(manual_mining_time)

# Handles input
func _unhandled_input(event):
	#Manual Mining
	if (Input.is_action_just_pressed("manual_mine")):
		if !manual_mining:
			manual_mining = true
		else:
			stop_manual_mining()
			emit_signal("is_manual_mining", self)

	elif (Input.is_action_just_pressed("interact_key")):
		#harvest_fairy_dust is true when in the radius of a log
		if harvest_fairy_dust && hasFairySwatter:
			if !interacting:
				interacting = true
				$HarvestTimer.start()
			else:
				stop_interacting()
		for area in $InteractBox.get_overlapping_areas():
			area.get_parent().interact()
	
	elif event.is_action_pressed("click"):
		
		if Global.selected_item:
			emit_signal("place_structure", get_global_mouse_position())
		
		elif !knockback && !manual_mining:
			if can_attack:
				var dir = (get_global_mouse_position() - global_position).normalized()
				
				attacking = true
				can_attack = false
				$AttackCooldown.start()
				
				if dir.x >= 0.6:
					anim_player.play("attack_right")
				elif dir.x <= -0.6:
					anim_player.play("attack_left")
				elif dir.y <= 0:
					anim_player.play("attack_up")
				else:
					anim_player.play("attack_down")
	
	elif event.is_action_pressed("right_click"):
		if Global.selected_item == "wall":
			Global.horizontal_wall = !Global.horizontal_wall
	
	elif event.is_action_pressed("structure_up"):
		if Global.selected_item != null:
			Global.move_queue(-1)
			while !check_afford(Global.get_structure_idx(0)):
				Global.move_queue(-1)
	
	elif event.is_action_pressed("structure_down"):
		if Global.selected_item != null:
			Global.move_queue(1)
			while !check_afford(Global.get_structure_idx(0)):
				Global.move_queue(1)
	elif event.is_action_pressed("1"):
		if check_afford(0):
			Global.set_selected_item(0)
	elif event.is_action_pressed("2"):
		if check_afford(1):
			Global.set_selected_item(1)
	elif event.is_action_pressed("3"):
		if check_afford(2):
			Global.set_selected_item(2)
	elif event.is_action_pressed("4"):
		if check_afford(3):
			Global.set_selected_item(3)
	elif event.is_action_pressed("5"):
		if check_afford(4):
			Global.set_selected_item(4)
	elif event.is_action_pressed("6"):
		if check_afford(5):
			Global.set_selected_item(5)
	elif event.is_action_pressed("7"):
		if check_afford(6):
			Global.set_selected_item(6)


func check_afford(idx):
	var costs = Global.cost_list[idx]
	return !(unobtainiumCount < costs[0] || fairyDustCount < costs[1] || fairyDustCount < costs[2])


func stop_interacting():
	interacting = false
	$HarvestTimer.stop()
	$HarvestTimer.set_wait_time(harvesting_time)
	emit_signal("is_interacting", self)


# Damages the player and knocks them back in the given direction
func damage(dmg, dir):
	if invincibility_timer.is_stopped():
		combatTimer.start()
		regenTimer.stop()
		eff_anim_player.play("invulnerable")
		set_collision_layer_bit(8, false)
		invincibility_timer.start()
		knockback = true
		if attacking:
			attacking = false
			end_attack_animation()
		direction = dir
		if dir.angle_to(Vector2.UP) > 0:
			anim_player.play("damaged_right")
		else:
			anim_player.play("damaged_left")
		health -= dmg
		emit_signal("player_stats_changed", self)


func heal(amount):
	if health < max_health:
		$HealRing.visible = true
		$HealRingTimer.start()
	
	health += amount
	if health > max_health:
		health = max_health


func end_attack_animation():
	attacking = false
	call_deferred("disable_attack_collider")


func disable_attack_collider():
	$AttackHitbox/CollisionShape2D.disabled = true

# Turns off knockback after animation
func disable_knockback():
	knockback = false


# Damages whatever's in the attack hitbox
func _on_AttackHitbox_body_entered(body):
	var dir = (body.position - position).normalized()
	if(body.has_method("isBoss")): #If the attacked entity is a boss
		body.damage(dmg, dir, true) #Let the boss know the player attacked it
	else:
		body.damage(dmg, dir)


func _on_InvincibilityTimer_timeout():
	eff_anim_player.play("RESET")
	set_collision_layer_bit(8, true)


func _on_ManualMiningTimer_timeout():
	unobtainiumCount += 1;


func _on_HUD_unlocked_fairy_swatter():
	hasFairySwatter = true;


func _on_HUD_just_purchased(hudUnobtainiumCount, hudFairyDustCount, hudDragonOilCount):
	unobtainiumCount = hudUnobtainiumCount
	fairyDustCount = hudFairyDustCount
	dragonOilCount = hudDragonOilCount
	emit_signal("player_stats_changed", self)


func _on_HarvestTimer_timeout():
	if(nearLog != null):
		if(nearLog.canHarvest):
			#fairyDustCount += fairyDustReward
			nearLog.harvested(self)
	else:
		print("SOMEHOW NEARTREE IS NULL??")
	stop_interacting()


func _on_HealRingTimer_timeout():
	$HealRing.visible = false


func _on_AttackCooldown_timeout():
	can_attack = true

func _on_CombatTimer_timeout():
	regenTimer.start()

func _on_RegenTimer_timeout():
	if(Global.difficulty == 0):
		health += 10
	if(Global.difficulty == 1):
		health += 5
	if health > max_health:
		health = max_health
