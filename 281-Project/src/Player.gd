class_name Player
extends KinematicBody2D

# Player Misc. Stats
var maxHealth : int = 100
export(int) var speed = 300

signal make_bullet
signal create_drill
signal action_pressed_test
# Used to indicate the players' stats have changed
signal player_stats_changed

onready var gun_tip = $GunTip

# Current resources of the player
var unobtainiumCount : int = 0
var fairyDustCount : int = 0

# Current Health of the player
var health : int = 100

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

func _process(delta):
	# Movement
	var direction := Vector2.ZERO
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction = direction.normalized()
	move_and_slide(direction * speed)
	look_at(get_global_mouse_position())
	
	# Stat Checking - will emit signal if stats changed
	if(unobtainiumCount != prevUCount || fairyDustCount != prevFDCount || health != prevHealth):
		emit_signal("player_stats_changed", self)

func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		var pos = gun_tip.global_position
		var dir = (get_global_mouse_position() - pos).normalized()
		emit_signal("make_bullet", pos, dir)
	if event.is_action_pressed("create_drill") && onTile == get_parent().tileUnobtainium: #on Unobtainium
		emit_signal("create_drill", global_position)
