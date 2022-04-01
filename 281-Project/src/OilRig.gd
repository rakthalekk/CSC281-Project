extends Structure

# Dragon Oil Rig Variables
var dragonOilReward = 1 #The dragon oil produced
const MAXCOUNT = 5 # Max dragon oil that can be at a miner before it will stop producing more
var oilRigCooldownTime = 1 #Time in seconds it takes to mine an dragon oil

const DRAGONOIL = preload("res://src/DragonOil.tscn")

#Instance will be used if the dragon oil is not spawned
var inst = null

func _ready():
	$"Timer".wait_time = oilRigCooldownTime;


func _on_Timer_timeout():
	#print("TIMER AT 0")
	if(!is_instance_valid(inst)): # Check for if the dragon oil is gone/collected
		inst = DRAGONOIL.instance()
		add_child(inst)
		inst.position = Vector2(0, 64) #This is position relative to the center of the oil rig
	else: # Add dragon oil to the instance if not beyond max count
		if(inst.count < MAXCOUNT):
			inst.count += dragonOilReward
		#print("Count is: " + str(inst.count) + " for miner at: " + str(get_position()))


func _on_InvincibilityTimer_timeout():
	end_invulnerability()
