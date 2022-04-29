extends CanvasLayer

const DRILL_IMG = preload("res://assets/Resources/drillcursor.png")
const TURRET_IMG = preload("res://assets/Resources/turretcursor.png")
const OILRIG_IMG = preload("res://assets/Resources/oilpumpcursor.png")
const FIRETOWER_IMG = preload("res://assets/Resources/flamethrowercursor.png")
const HEALTOWER_IMG = preload("res://assets/Resources/healingtowercursor.png")
const WALL_IMG = preload("res://assets/Resources/wallcursor.png")
const ORE_IMG = preload("res://assets/Resources/ore.png")
const DUST_IMG = preload("res://assets/Resources/fairydust.png")
const OIL_IMG = preload("res://assets/Resources/oilbarrel.png")

# Signal transmitted when the user unlocks the fairy swatter
signal unlocked_fairy_swatter
# Signal transmitted when the user has purchased something
signal just_purchased

# Stored player stats
var hudUnobtainiumCount = 0
var hudFairyDustCount = 0
var hudDragonOilCount = 0

# For use in tutorial
var disable_pause = false

# Misc Constants for HUD
onready var cooldownDisplay = $"Interact Display/Cooldown Display"
onready var interactTime = $"Interact Display/Interact Time"

# Constants for invalidPrices
onready var fairySwatterLock = $"Fairy Swatter/Fairy Swatter Lock"
onready var fairySwatterCostObj = $"Fairy Swatter/Cost Object"
onready var fairySwatterUCost = $"Fairy Swatter/Cost Object/Cost Number"
onready var drillItem = $"Drill Item"
onready var turretItem = $"Turret Item"
onready var oilRigItem = $"Oil Rig Item"
onready var fireTowerItem = $"Fire Tower Item"
onready var healTowerItem = $"Heal Tower Item"
onready var wallItem = $"Wall Item"

func _ready():
	# Set price text box of fairy swatter
	$"Fairy Swatter/Cost Object/Cost Number".set_text(str(Global.fairySwatterCost[0]))
	
func _process(delta):
	$"Coords".set_text("X: " + str(get_parent().playerCoords[0]) + "\nY: " + str(get_parent().playerCoords[1]))
	
	if Global.selected_item:
		if Global.selected_item == "drill":
			Input.set_custom_mouse_cursor(DRILL_IMG)
		elif Global.selected_item == "wall":
			Input.set_custom_mouse_cursor(WALL_IMG)
		elif Global.selected_item == "turret":
			Input.set_custom_mouse_cursor(TURRET_IMG)
		elif Global.selected_item == "healtower":
			Input.set_custom_mouse_cursor(HEALTOWER_IMG)
		elif Global.selected_item == "oilrig":
			Input.set_custom_mouse_cursor(OILRIG_IMG)
		elif Global.selected_item == "firetower":
			Input.set_custom_mouse_cursor(FIRETOWER_IMG)
	else:
		Input.set_custom_mouse_cursor(null)

func _unhandled_input(event):
	if(event.is_action_pressed("deselect_item")):
		if(Global.selected_item != null):
			Input.set_custom_mouse_cursor(null)
			Global.selected_item = null


func _on_Player_player_stats_changed(var player):
	$"Health Bar/Bar".rect_size.x = 206 * player.health / player.max_health
	
	$"Health Bar/Number Label".set_text(str(player.health) + "/" + str(player.max_health))
	
	$"Unobtainium Display/Number".set_text(str(player.unobtainiumCount))
	hudUnobtainiumCount = player.unobtainiumCount
	
	$"Fairy Dust Display/Number".set_text(str(player.fairyDustCount))
	hudFairyDustCount = player.fairyDustCount
	
	$"Dragon Oil Display/Number".set_text(str(player.dragonOilCount))
	hudDragonOilCount = player.dragonOilCount
	
	invalidPrices()


func invalidPrices():
	# Check price of fairy swatter - changes to red lock and red text if cannot unlock
	if(hudUnobtainiumCount < Global.fairySwatterCost[0] || hudFairyDustCount < Global.fairySwatterCost[1]):
		fairySwatterLock.texture_normal = load("res://assets/Resources/lockred.png")
		fairySwatterUCost.set_text("")
		fairySwatterUCost.push_color(Color(1,0,0,1))
		fairySwatterUCost.append_bbcode(str(Global.fairySwatterCost[0]))
		fairySwatterUCost.pop()
	else:
		fairySwatterLock.texture_normal = load("res://assets/Resources/lock.png")
		fairySwatterUCost.set_text("")
		fairySwatterUCost.push_color(Color(1,1,1,1))
		fairySwatterUCost.append_bbcode(str(Global.fairySwatterCost[0]))
		fairySwatterUCost.pop()
	
	cantAfford(drillItem,Global.unobtainiumDrillCost,"res://assets/Structures/drillupscaled.png","res://assets/Structures/drillupscaled grayscale.png")
	cantAfford(turretItem,Global.magicTurretCost,"res://assets/Structures/turret.png","res://assets/Structures/turret grayscale.png")
	cantAfford(oilRigItem,Global.oilRigCost,"res://assets/Structures/oilpump.png", "res://assets/Structures/oilpumpgrey.png")
	cantAfford(fireTowerItem,Global.fireTowerCost,"res://assets/Structures/flamethrowerv2up.png", "res://assets/Structures/flamethrowerv2up.png")
	cantAfford(healTowerItem,Global.healTowerCost,"res://assets/Structures/healingtower.png", "res://assets/Structures/healingtower.png")
	cantAfford(wallItem,Global.wallCost,"res://assets/Structures/wallicon.png", "res://assets/Structures/wallicon.png")


func cantAfford(parentItem, globalCost, normalTexture, lockedTexture):
	var amounts = [hudUnobtainiumCount, hudFairyDustCount, hudDragonOilCount]
	var resourceCount = 0
	var hasResourceCount = 0
	for node in parentItem.get_children():
		var index = -1
		resourceCount += 1
		match node.name: # Get the index of the global array for each resource
			"Unobtainium Cost":
				index = 0
			"Fairy Dust Cost":
				index = 1
			"Oil Cost":
				index = 2
			_:
				resourceCount -= 1 #remove one since checked node isn't a resource label
				print("Not a resource node: " + str(node.name))
				continue
		if(amounts[index] < globalCost[index]):
			setText(node.get_node("Cost Number"), Color(1,0,0,1), str(globalCost[index]))
		else:
			setText(node.get_node("Cost Number"), Color(1,1,1,1), str(globalCost[index]))
			hasResourceCount += 1
	if(hasResourceCount == resourceCount):
		parentItem.disabled = false
		parentItem.texture_normal = load(normalTexture)
	else:
		parentItem.disabled = true
		parentItem.texture_normal = load(lockedTexture)


func setText(node, color, text):
	node.set_text("")
	node.push_color(color)
	node.append_bbcode(text)
	node.pop()


func _on_Drill_Item_toggled(button_pressed):
	if Global.selected_item != "drill":
		Global.selected_item = "drill"
	else:
		Input.set_custom_mouse_cursor(null)
		Global.selected_item = null


func _on_Turret_Item_toggled(button_pressed):
	if Global.selected_item != "turret":
		Global.selected_item = "turret"
	else:
		Input.set_custom_mouse_cursor(null)
		Global.selected_item = null


func _on_Player_is_manual_mining(var player):
	$"Interact Display".texture = ORE_IMG
	if(player.manual_mining_timer.time_left == 0):
		cooldownDisplay.set_frame_color(Color(0.65,0.65,0.65,1))
		$"Interact Display".visible = false
		interactTime.set_text("")
	else:
		$"Interact Display".visible = true
		cooldownDisplay.set_frame_color(Color(0.65,0.65,0.65,sqrt(player.manual_mining_timer.time_left/player.manual_mining_time)))
		interactTime.set_text(str(stepify(player.manual_mining_timer.time_left,0.01)))


func _on_Fairy_Swatter_Lock_pressed():
	if(hudUnobtainiumCount >= Global.fairySwatterCost[0] && hudFairyDustCount >= Global.fairySwatterCost[1]):
		hudUnobtainiumCount -= Global.fairySwatterCost[0]
		hudFairyDustCount -= Global.fairySwatterCost[1]
		fairySwatterLock.disabled = true
		fairySwatterLock.visible = false
		fairySwatterCostObj.visible = false
		emit_signal("unlocked_fairy_swatter")
		emit_signal("just_purchased", hudUnobtainiumCount, hudFairyDustCount, hudDragonOilCount);


func _on_Player_is_interacting(player):
	$"Interact Display".texture = DUST_IMG
	if(player.harvest_timer.time_left == 0):
		cooldownDisplay.set_frame_color(Color(0.65,0.65,0.65,1))
		$"Interact Display".visible = false
		interactTime.set_text("")
	else:
		$"Interact Display".visible = true
		cooldownDisplay.set_frame_color(Color(0.65,0.65,0.65,sqrt(player.harvest_timer.time_left/player.manual_mining_time)))
		interactTime.set_text(str(stepify(player.harvest_timer.time_left,0.01)))


func _on_Player_place_structure(pos: Vector2):
	# Structure placing handled in player
	if(get_parent().valid_place): #checks to make sure the place is valid before costing price
		if Global.selected_item == "drill":
			hudUnobtainiumCount -= Global.unobtainiumDrillCost[0]
			hudFairyDustCount -= Global.unobtainiumDrillCost[1]
			hudDragonOilCount -= Global.unobtainiumDrillCost[2]
			if(hudUnobtainiumCount < Global.unobtainiumDrillCost[0] || hudFairyDustCount < Global.unobtainiumDrillCost[1] || hudDragonOilCount < Global.unobtainiumDrillCost[2]):
				Global.selected_item = null
				Input.set_custom_mouse_cursor(null)
		elif Global.selected_item == "turret":
			hudUnobtainiumCount -= Global.magicTurretCost[0]
			hudFairyDustCount -= Global.magicTurretCost[1]
			hudDragonOilCount -= Global.magicTurretCost[2]
			if(hudUnobtainiumCount < Global.magicTurretCost[0] || hudFairyDustCount < Global.magicTurretCost[1] || hudDragonOilCount < Global.magicTurretCost[2]):
				Global.selected_item = null
				Input.set_custom_mouse_cursor(null)
		elif Global.selected_item == "oilrig":
			hudUnobtainiumCount -= Global.oilRigCost[0]
			hudFairyDustCount -= Global.oilRigCost[1]
			hudDragonOilCount -= Global.oilRigCost[2]
			if(hudUnobtainiumCount < Global.oilRigCost[0] || hudFairyDustCount < Global.oilRigCost[1] || hudDragonOilCount < Global.oilRigCost[2]):
				Global.selected_item = null
				Input.set_custom_mouse_cursor(null)
		elif Global.selected_item == "firetower":
			hudUnobtainiumCount -= Global.fireTowerCost[0]
			hudFairyDustCount -= Global.fireTowerCost[1]
			hudDragonOilCount -= Global.fireTowerCost[2]
			if(hudUnobtainiumCount < Global.fireTowerCost[0] || hudFairyDustCount < Global.fireTowerCost[1] || hudDragonOilCount < Global.fireTowerCost[2]):
				Global.selected_item = null
				Input.set_custom_mouse_cursor(null)
		elif Global.selected_item == "healtower":
			hudUnobtainiumCount -= Global.healTowerCost[0]
			hudFairyDustCount -= Global.healTowerCost[1]
			hudDragonOilCount -= Global.healTowerCost[2]
			if(hudUnobtainiumCount < Global.healTowerCost[0] || hudFairyDustCount < Global.healTowerCost[1] || hudDragonOilCount < Global.healTowerCost[2]):
				Global.selected_item = null
				Input.set_custom_mouse_cursor(null)
		elif Global.selected_item == "wall":
			hudUnobtainiumCount -= Global.wallCost[0]
			hudFairyDustCount -= Global.wallCost[1]
			hudDragonOilCount -= Global.wallCost[2]
			if(hudUnobtainiumCount < Global.wallCost[0] || hudFairyDustCount < Global.wallCost[1] || hudDragonOilCount < Global.wallCost[2]):
				Global.selected_item = null
				Input.set_custom_mouse_cursor(null)
		emit_signal("just_purchased", hudUnobtainiumCount, hudFairyDustCount, hudDragonOilCount);


func _on_Oil_Rig_Item_toggled(button_pressed):
	if Global.selected_item != "oilrig":
		Global.selected_item = "oilrig"
	else:
		Input.set_custom_mouse_cursor(null)
		Global.selected_item = null


func _on_Fire_Tower_Item_toggled(button_pressed):
	if Global.selected_item != "firetower":
		Global.selected_item = "firetower"
	else:
		Global.selected_item = null


func _on_Heal_Tower_Item_toggled(button_pressed):
	if Global.selected_item != "healtower":
		Global.selected_item = "healtower"
	else:
		Global.selected_item = null


func _on_Wall_Item_toggled(button_pressed):
	if Global.selected_item != "wall":
		Global.selected_item = "wall"
	else:
		Input.set_custom_mouse_cursor(null)
		Global.selected_item = null
