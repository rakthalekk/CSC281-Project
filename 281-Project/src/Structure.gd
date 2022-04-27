class_name Structure
extends StaticBody2D

export(int) var max_health = 100
onready var health = max_health

onready var parent = $"../../.."
onready var anim_player = $AnimationPlayer
onready var eff_anim_player = $EffectsAnimationPlayer
onready var invincibility_timer = $InvincibilityTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("idle")


# Damages the structure
func damage(dmg):
	if invincibility_timer.is_stopped():
		eff_anim_player.play("invulnerable")
		set_collision_layer_bit(8, false)
		invincibility_timer.start()
		health -= dmg
		
		if health <= 0:
			parent.remove_structure(self)


func heal(amount):
	if health < max_health:
		$HealRing.visible = true
		$HealRingTimer.start()
	
	health += amount
	if health > max_health:
		health = max_health


func end_invulnerability():
	eff_anim_player.play("RESET")
	set_collision_layer_bit(8, true)
