extends Structure

# Unobtainium Drill Variables
var unobtainiumReward = 1 #The unobtainium produced
const MAXCOUNT = 5 # Max unobtainium that can be at a miner before it will stop producing more
var drillCooldownTime = 5 #Time in seconds it takes to mine an unobtainium ore

const UNOBTAINIUM = preload("res://src/Unobtainium.tscn")

#Instance will be used if the unobtainium is not spawned
var inst = null

func _ready():
	$"Timer".wait_time = drillCooldownTime;
	anim_player.play("place")


func play_idle():
	anim_player.play("idle")


func _on_Timer_timeout():
	#print("TIMER AT 0")
	if(!is_instance_valid(inst)): # Check for if the unobtainium is gone/collected
		inst = UNOBTAINIUM.instance()
		add_child(inst)
		inst.position = Vector2(0, 64) #This is position relative to the center of the drill
	else: # Add unobtainium to the instance if not beyond max count
		if(inst.count < MAXCOUNT):
			inst.count += unobtainiumReward
		#print("Count is: " + str(inst.count) + " for miner at: " + str(get_position()))


func _on_InvincibilityTimer_timeout():
	end_invulnerability()


func _on_HealRingTimer_timeout():
	$HealRing.visible = false
