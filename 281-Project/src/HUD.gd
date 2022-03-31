extends CanvasLayer

const DRILL_IMG = preload("res://assets/Resources/drillcursor.png")
const TURRET_IMG = preload("res://assets/Resources/turretcursor.png")

# Signal transmitted when the user unlocks the fairy swatter
signal unlocked_fairy_swatter
# Signal transmitted when the user has purchased something
signal just_purchased

# Stored player stats
var hudUnobtainiumCount = 0
var hudFairyDustCount = 0

# Misc Constants for HUD
onready var cooldownDisplay = $"Mining Display/Cooldown Display"
onready var miningTime = $"Mining Display/Mining Time"

# Constants for invalidPrices
onready var fairySwatterLock = $"Fairy Swatter/Fairy Swatter Lock"
onready var fairySwatterCostObj = $"Fairy Swatter/Cost Object"
onready var fairySwatterUCost = $"Fairy Swatter/Cost Object/Cost Number"
onready var drillItem = $"Drill Item"
onready var turretItem = $"Turret Item"


func _ready():
	# Set price text box of fairy swatter
	$"Fairy Swatter/Cost Object/Cost Number".set_text(str(Global.fairySwatterCost[0]))

func _unhandled_input(event):
	if(event.is_action_pressed("escape_key")):
		if(Global.selected_structure != null):
			Input.set_custom_mouse_cursor(null)
			Global.selected_structure = null

func _on_Player_player_stats_changed(var player):
	$"Health Bar/Bar".rect_size.x = 200 * player.health / player.max_health
	
	$"Health Bar/Number Label".set_text(str(player.health) + " / " + str(player.max_health))
	
	$"Unobtainium Display/Number".set_text(str(player.unobtainiumCount))
	hudUnobtainiumCount = player.unobtainiumCount
	
	$"Fairy Dust Display/Number".set_text(str(player.fairyDustCount))
	hudFairyDustCount = player.fairyDustCount
	
	invalidPrices()

func invalidPrices():
	# Check price of fairy swatter - changes to red lock and red text if cannot unlock
	if(hudUnobtainiumCount < Global.fairySwatterCost[0] || hudFairyDustCount < Global.fairySwatterCost[1]):
		fairySwatterLock.texture_normal = load("res://assets/Resources/Red Lock Icon.png")
		fairySwatterUCost.set_text("")
		fairySwatterUCost.push_color(Color(1,0,0,1))
		fairySwatterUCost.append_bbcode(str(Global.fairySwatterCost[0]))
		fairySwatterUCost.pop()
	else:
		fairySwatterLock.texture_normal = load("res://assets/Resources/Lock Icon.png")
		fairySwatterUCost.set_text("")
		fairySwatterUCost.push_color(Color(1,1,1,1))
		fairySwatterUCost.append_bbcode(str(Global.fairySwatterCost[0]))
		fairySwatterUCost.pop()
	
	cantAfford(drillItem,Global.unobtainiumDrillCost,"res://assets/Structures/drillupscaled.png","res://assets/Structures/drillupscaled grayscale.png")
	cantAfford(turretItem,Global.magicTurretCost,"res://assets/Structures/turret.png","res://assets/Structures/turret grayscale.png")
	

	
func cantAfford(parentItem, globalCost, normalTexture, lockedTexture):
	if(hudUnobtainiumCount < globalCost[0] || hudFairyDustCount < globalCost[1]):
		parentItem.disabled = true
		parentItem.texture_normal = load(lockedTexture)
		if(hudUnobtainiumCount < globalCost[0]):
			setText(parentItem.get_node("Unobtainium Cost").get_node("Cost Number"), Color(1,0,0,1), str(globalCost[0]))
		else:
			setText(parentItem.get_node("Unobtainium Cost").get_node("Cost Number"), Color(1,1,1,1), str(globalCost[0]))
			
		if(hudFairyDustCount < globalCost[1]):
			setText(parentItem.get_node("Fairy Dust Cost").get_node("Cost Number"), Color(1,0,0,1), str(globalCost[1]))
		else:
			setText(parentItem.get_node("Fairy Dust Cost").get_node("Cost Number"), Color(1,1,1,1), str(globalCost[1]))
	else:
		parentItem.disabled = false
		parentItem.texture_normal = load(normalTexture)
		setText(parentItem.get_node("Unobtainium Cost").get_node("Cost Number"), Color(1,1,1,1), str(globalCost[0]))
		setText(parentItem.get_node("Fairy Dust Cost").get_node("Cost Number"), Color(1,1,1,1), str(globalCost[1]))


func setText(node, color, text):
	node.set_text("")
	node.push_color(color)
	node.append_bbcode(text)
	node.pop()

func _on_Drill_Item_toggled(button_pressed):
	if Global.selected_structure != "drill":
		Input.set_custom_mouse_cursor(DRILL_IMG)
		Global.selected_structure = "drill"
	else:
		Input.set_custom_mouse_cursor(null)
		Global.selected_structure = null


func _on_Turret_Item_toggled(button_pressed):
	if Global.selected_structure != "turret":
		Input.set_custom_mouse_cursor(TURRET_IMG)
		Global.selected_structure = "turret"
	else:
		Input.set_custom_mouse_cursor(null)
		Global.selected_structure = null


func _on_Player_is_manual_mining(var player):
	if(player.manual_mining_timer.time_left == 0):
		cooldownDisplay.set_frame_color(Color(0.65,0.65,0.65,1))
		miningTime.set_text("")
	else:
		cooldownDisplay.set_frame_color(Color(0.65,0.65,0.65,sqrt(player.manual_mining_timer.time_left/player.manual_mining_time)))
		miningTime.set_text(str(stepify(player.manual_mining_timer.time_left,0.01)))


func _on_Fairy_Swatter_Lock_pressed():
	if(hudUnobtainiumCount >= Global.fairySwatterCost[0] && hudFairyDustCount >= Global.fairySwatterCost[1]):
		hudUnobtainiumCount -= Global.fairySwatterCost[0]
		hudFairyDustCount -= Global.fairySwatterCost[1]
		fairySwatterLock.disabled = true
		fairySwatterLock.visible = false
		fairySwatterCostObj.visible = false
		emit_signal("unlocked_fairy_swatter", true)
		emit_signal("just_purchased", hudUnobtainiumCount, hudFairyDustCount);


func _on_Player_place_structure(pos: Vector2):
	# Structure placing handled in main
	if Global.selected_structure == "drill":
		hudUnobtainiumCount -= Global.unobtainiumDrillCost[0]
		hudFairyDustCount -= Global.unobtainiumDrillCost[1]
		if(hudUnobtainiumCount < Global.unobtainiumDrillCost[0] || hudFairyDustCount < Global.unobtainiumDrillCost[1]):
			Global.selected_structure = null
			Input.set_custom_mouse_cursor(null)
	elif Global.selected_structure == "turret":
		hudUnobtainiumCount -= Global.magicTurretCost[0]
		hudFairyDustCount -= Global.magicTurretCost[1]
		if(hudUnobtainiumCount < Global.magicTurretCost[0] || hudFairyDustCount < Global.magicTurretCost[1]):
			Global.selected_structure = null
			Input.set_custom_mouse_cursor(null)
	emit_signal("just_purchased", hudUnobtainiumCount, hudFairyDustCount);
