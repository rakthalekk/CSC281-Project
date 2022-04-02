extends Node

var selected_item = null

#HUD Item Costs [unobtainium cost, fairy dust cost, dragon oil?]
var fairySwatterCost = [10,0,0]
var unobtainiumDrillCost = [5,0,0]
var magicTurretCost = [5,5,0]
var oilRigCost = [10,10,0]
var fireTowerCost = [10,0,10]


func reset_level():
	get_tree().change_scene("res://src/Main.tscn")
