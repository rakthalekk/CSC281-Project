extends Node

var selected_item = null
var horizontal_wall = true
var the_chosen_one = null
var kill_count = 0
var frog_num = 0
var time = 0.0

var difficulty = 1 # 0, 1, or 2
var music = 0.5
var sound = 0.5

#HUD Item Costs [unobtainium cost, fairy dust cost, dragon oil?]
var fairySwatterCost = [10,0,0]
var unobtainiumDrillCost = [2,0,0]
var wallCost = [2,0,0]
var bearTrapCost = [3,0,0]
var magicTurretCost = [5,5,0]
var healTowerCost = [5,10,0]
var oilRigCost = [2,5,0]
var fireTowerCost = [5,0,5]

var cost_list = [unobtainiumDrillCost, wallCost, bearTrapCost, magicTurretCost, healTowerCost, oilRigCost, fireTowerCost]

var structure_queue = ["drill", "wall", "beartrap", "turret", "healtower", "oilrig", "firetower"]

#Dragon Bones Oil Rig Placement Range (tile radius around dragon bones where oil rigs can be placed)
var oilRigTileRadius = 0

func reset_level():
	get_tree().change_scene("res://src/Main.tscn")


func move_queue(offset):
	selected_item = structure_queue[get_structure_idx(offset)]


func get_structure_idx(offset):
	var idx = structure_queue.find(selected_item) + offset
	if idx == -1:
		idx = structure_queue.size() - 1
	elif idx == structure_queue.size():
		idx = 0
	return idx

func set_selected_item(idx: int):
	selected_item = structure_queue[idx]
