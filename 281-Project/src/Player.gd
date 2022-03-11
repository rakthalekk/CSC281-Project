class_name Player
extends KinematicBody2D

export(int) var run_speed = 300
export(int) var knockback_speed = 400
export(int) var dmg = 10
export(int) var max_health = 100

signal make_bullet
signal create_drill
signal action_pressed_test
signal update_health
signal place_structure

# Used to indicate the players' stats have changed
signal player_stats_changed


onready var gun_tip = $GunTip
onready var anim_player = $AnimationPlayer


var direction := Vector2.ZERO
var speed = run_speed
var velocity := Vector2.ZERO

# Current resources of the player
var unobtainiumCount : int = 0
var fairyDustCount : int = 0
var knockback = false
var attacking = false

# Current Health of the player
var health : int = max_health

# Used to detect when the players' stats have changed to update the HUD
var prevUCount : int = unobtainiumCount
var prevFDCount : int = fairyDustCount
var prevHealth : int = health

var onTile = "None"
#Tiles accounted for:
"""
ID	||	NAME   ||	Reference
------------------------------
-1		"NONE"		tileNone
0		"Grass"		tileGrass
1	"Unobtainium"	tileUnobtainium
"""

func _ready():
	#emit the initial stats of the player,
	emit_signal("player_stats_changed", self)

# Process function called every frame
func _process(delta):
	if health <= 0:
		queue_free()

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

# Handles input
func _unhandled_input(event):
	if event.is_action_pressed("click"):
		
		if Global.selected_structure:
			emit_signal("place_structure", get_global_mouse_position())
		
		elif !knockback:
			var dir = (get_global_mouse_position() - global_position).normalized()
			
			attacking = true
			
			if dir.x >= 0.6:
				anim_player.play("attack_right")
				$AttackHitbox/CollisionShape2D/ColorRect.rect_position = Vector2(-30, -45)
				$AttackHitbox/CollisionShape2D/ColorRect.rect_size = Vector2(56, 96)
			elif dir.x <= -0.6:
				anim_player.play("attack_left")
				$AttackHitbox/CollisionShape2D/ColorRect.rect_position = Vector2(-30, -45)
				$AttackHitbox/CollisionShape2D/ColorRect.rect_size = Vector2(56, 96)
			elif dir.y <= 0:
				anim_player.play("attack_up")
				$AttackHitbox/CollisionShape2D/ColorRect.rect_position = Vector2(-48, -29)
				$AttackHitbox/CollisionShape2D/ColorRect.rect_size = Vector2(96, 56)
			else:
				anim_player.play("attack_down")
				$AttackHitbox/CollisionShape2D/ColorRect.rect_position = Vector2(-48, -29)
				$AttackHitbox/CollisionShape2D/ColorRect.rect_size = Vector2(96, 56)
				
			$AttackHitbox/CollisionShape2D/ColorRect.visible = true
		
#	if event.is_action_pressed("create_drill") && onTile == get_parent().tileUnobtainium: #on Unobtainium
#		emit_signal("create_drill", global_position)


# Damages the player and knocks them back in the given direction
func damage(dmg, dir):
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
	$AttackHitbox/CollisionShape2D/ColorRect.visible = false
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

