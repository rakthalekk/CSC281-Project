extends StaticBody2D

const UNOBTAINIUM = preload("res://src/Unobtainium.tscn")

#Instance will be used if the unobtainium is not spawned
var inst = null
# Max unobtainium that can be at a miner before it will stop producing more
const MAXCOUNT = 5

func _on_Timer_timeout():
	#print("TIMER AT 0")
	if(!is_instance_valid(inst)): # Check for if the unobtainium is gone/collected
		inst = UNOBTAINIUM.instance()
		add_child(inst)
		inst.position = Vector2(0, 64) #This is position relative to the center of the drill
	else: # Add unobtainium to the instance if not beyond max count
		if(inst.count < MAXCOUNT):
			inst.count += 1
		#print("Count is: " + str(inst.count) + " for miner at: " + str(get_position()))
