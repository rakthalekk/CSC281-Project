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

onready var gun_tip = $GunTip
onready var anim_player = $AnimationPlayer

var hp = max_health
var direction := Vector2.ZERO
var speed = run_speed
var velocity := Vector2.ZERO

var unobtainiumCount : int = 0
var fairyDustCount : int = 0
var knockback = false

var onTile = "None"
#Tiles accounted for:
"""
ID	||	NAME   ||	Reference
------------------------------
-1		"NONE"		tileNone
0		"Grass"		tileGrass
1	"Unobtainium"	tileUnobtainium
"""

# Process function called every frame
func _process(delta):
	if knockback:
		velocity = direction * knockback_speed
	else:
		direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
		direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		direction = direction.normalized()
		velocity = direction * speed
		
		look_at(get_global_mouse_position())
	move_and_slide(velocity)


# Handles input
func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		# Disable shoot for now
		#var pos = gun_tip.global_position
		#var dir = (get_global_mouse_position() - pos).normalized()
		#emit_signal("make_bullet", pos, dir)
		
		anim_player.play("attack")
		
	if event.is_action_pressed("create_drill") && onTile == get_parent().tileUnobtainium: #on Unobtainium
		emit_signal("create_drill", global_position)


# Damages the player and knocks them back in the given direction
func damage(dmg, dir):
	knockback = true
	anim_player.play("damaged")
	direction = dir
	hp -= dmg
	emit_signal("update_health", hp)


# Turns off knockback after animation
func disable_knockback():
	knockback = false


# Damages whatever's in the attack hitbox
func _on_AttackHitbox_body_entered(body):
	var dir = (body.position - position).normalized()
	body.damage(dmg, dir)
