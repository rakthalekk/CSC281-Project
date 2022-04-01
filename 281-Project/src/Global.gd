extends Node

var selected_item = null

#HUD Item Costs [unobtainium cost, fairy dust cost]
var fairySwatterCost = [10,0]
var unobtainiumDrillCost = [5,0]
var magicTurretCost = [5,5]

# Fairy Log Variables
var logCooldown = [1,5] #[min time, max time] time in seconds
var fairyDustReward = 1 #Amount of fairy dust collected from logs

func reset_level():
	get_tree().change_scene("res://src/Main.tscn")
