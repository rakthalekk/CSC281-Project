extends Node

var selected_structure = null

#HUD Item Costs [unobtainium cost, fairy dust cost]
var fairySwatterCost = [1,0]
var unobtainiumDrillCost = [1,0]
var magicTurretCost = [1,1]

func reset_level():
	get_tree().change_scene("res://src/Main.tscn")
