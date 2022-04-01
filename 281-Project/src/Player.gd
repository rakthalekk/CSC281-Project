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
onready var eff_anim_player = $EffectsAnimationPlayer
onready var invincibility_timer = $InvincibilityTimer
onready var manual_mining_timer = $ManualMiningTimer
onready var harvest_timer = $HarvestTimer

var direction := Vector2.ZERO
var speed = run_speed
var velocity := Vector2.ZERO

# Current resources of the player
var unobtainiumCount : int = 20
var fairyDustCount : int = 0
var knockback = false
var attacking = false
var manual_mining = false
var interacting = false
var harvest_fairy_dust = false

# Current Health of the player
var health : int = max_health

# Used to detect when the players' stats have changed to update the HUD
var prevUCount : int = unobtainiumCount
var prevFDCount : int = fairyDustCount
var prevHealth : int = health

# Used to check whether the player has specific things
var hasFairySwatter = false

func _ready():
	#emit the initial stats of the player,
	emit_signal("player_stats_changed", self)
	emit_signal("is_manual_mining", self)

# Process function called every frame
func _process(delta):
	if health <= 0:
		Global.reset_level()

	if knockback:
		velocity = direction * knockback_speed
	else:
		direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
		direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		direction = direction.normalized()
		velocity = direction * speed
	
	# Play animation based on player walk direction
	if !attacking && !knockback:
		if direction.x > 0:
			anim_player.play("walk_right")
		elif direction.x < 0:
			anim_player.play("walk_left")
		elif direction.y > 0:
			anim_player.play("walk_down")
		elif direction.y < 0:
			anim_player.play("walk_up")
		else:
			anim_player.play("idle")
	
	move_and_slide(velocity)
	
	# Stat Checking - will emit signal if stats changed
	if(unobtainiumCount != prevUCount || fairyDustCount != prevFDCount || health != prevHealth):
		emit_signal("player_stats_changed", self)
	
	# Handles Manual Mining
	if(manual_mining):
		if(onTile == "Unobtainium" && $ManualMiningTimer.time_left == 0):
			$ManualMiningTimer.start(manual_mining_time)
		if(onTile != "Unobtainium"):
			#manual_mining = false
			$ManualMiningTimer.stop()
			$ManualMiningTimer.set_wait_time(manual_mining_time)
		emit_signal("is_manual_mining", self)
	elif interacting:
		emit_signal("is_interacting", self)

# Handles input
func _unhandled_input(event):
	#Manual Mining
	if (event.is_action_pressed("manual_mine")):
		manual_mining = true
	if (event.is_action_pressed("interact_key")):
		if harvest_fairy_dust && hasFairySwatter:
			interacting = true
			$HarvestTimer.start()

	if (event.is_action_released("interact_key")):
		interacting = false
		$HarvestTimer.stop()
		$HarvestTimer.set_wait_time(harvesting_time)
		emit_signal("is_interacting", self)

	#Stop mining when key is released
	if (event.is_action_released("manual_mine")):
		manual_mining = false
		$ManualMiningTimer.stop()
		$ManualMiningTimer.set_wait_time(manual_mining_time)
		emit_signal("is_manual_mining", self)
	
	if event.is_action_pressed("click"):
		
		if Global.selected_item:
			emit_signal("place_structure", get_global_mouse_position())
		
		elif !knockback && !manual_mining:
			var dir = (get_global_mouse_position() - global_position).normalized()
			
			attacking = true
			
			if dir.x >= 0.6:
				anim_player.play("attack_right")
			elif dir.x <= -0.6:
				anim_player.play("attack_left")
			elif dir.y <= 0:
				anim_player.play("attack_up")
			else:
				anim_player.play("attack_down")


# Damages the player and knocks them back in the given direction
func damage(dmg, dir):
	if invincibility_timer.is_stopped():
		eff_anim_player.play("invulnerable")
		set_collision_layer_bit(8, false)
		invincibility_timer.start()
		knockback = true
		if attacking:
			attacking = false
			end_attack_animation()
		anim_player.play("damaged")
		direction = dir
		health -= dmg
		emit_signal("player_stats_changed", self)


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
	body.damage(dmg, dir)


func _on_InvincibilityTimer_timeout():
	eff_anim_player.play("RESET")
	set_collision_layer_bit(8, true)


func _on_ManualMiningTimer_timeout():
	unobtainiumCount += 1;


func _on_HUD_unlocked_fairy_swatter():
	hasFairySwatter = true;


func _on_HUD_just_purchased(hudUnobtainiumCount, hudFairyDustCount):
	unobtainiumCount = hudUnobtainiumCount
	fairyDustCount = hudFairyDustCount
	emit_signal("player_stats_changed", self)


func _on_HarvestTimer_timeout():
	fairyDustCount += 1
