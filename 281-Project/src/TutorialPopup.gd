extends AcceptDialog


var text = ""
var dialog_idx = 0
var cont = true
var dialog = ["Welcome to Operation: Wonderland!\n\nIn this game, you will play as Joe M., a former tax attorney who has recently joined the military.\n\nA fantasy alternate world known as Wonderland was just discovered by the government, and the General wants all troops to investigate this land.",
"Within the stone deposits of Wonderland, there exists an ore with magical properties, known as Unobtanium.\n\nThe military recognizes the potential power that Unobtanium has, and they want to use it for weapons.\n\nYour job is to collect as much Unobtanium as possible, and return to the real world safely.",
"Try walking over to that stone deposit, using the WASD keys, and press the C key to start mining.",
"Good work. Now that you've collected a few chunks of Unobtanium, you can place a drill to mine for you.\n\nSelect the drill icon below (or press the 1 key) and place a drill on the stone deposit. Wait for it to mine, and collect 6 Unobtanium.\n\nThe drill will only mine up to 5 Unobtanium at a time, so make sure to collect it frequently.",
"You can use this Unobtanium to place a few more drills and improve your resource output.\n\nTo de-select a structure, click on it again, press Q, or press the middle mouse button.\n\nOnce you have 10 Unobtanium, click the lock in the lower-right corner. This will unlock the Fairy Zapper.",
"Now that you've obtained the Fairy Zapper, walk north to the glowing log, and press E.\n\nYou can harvest Fairy Dust by interacting next to the log while it is glowing, and create new structures with it.\n\nCollect 3 Fairy Dust.",
"Excellent! To save you some time gathering more resources, here's 50 Unobtanium and Fairy Dust.\n\nNow, why don't you try fighting some enemies? There's a burrow of bunnies off to your left.",
"These bunnies may look cute, but they will hurt you if you get close to them. It's best to defeat them before they can cause problems.\n\nUse the mouse to attack with your suitcase. Guns don't work in Wonderland, and this is all that Joe had with him, so you'll need to make do.\n\nDefeat 3 bunnies.",
"Seems like they just keep coming, and it would be exhausting to keep fighting them on your own.\n\nTry placing a turret a small distance from the burrow. Click the third icon (or press 3) and place a turret.",
"That should fend them off for a bit. You can also place sandbag walls to protect the turret or other structures from being attacked.\n\nClick the second icon (or press 2) to select a wall. Walls can be placed horizontally or vertically; right-click to change the direction.\n\nYou can also disable walls by right-clicking on them, to let you pass through them.",
"Move up further north, and look for some dragon bones. You can harvest oil from them by placing an Oil Rig on them.\n\nClick the fifth icon (or press 5) to select an oil rig, and place it on the bones to gain Dragon Oil.\n\nCollect 5 Dragon Oil.",
"Using Dragon Oil, you can create a Fire Tower (item 6). This is a powerful structure that deals damage to all enemies in its radius.\n\nTry placing one near the burrow, and place a wall in front of it for protection.\n\nNext, press E on the burrow to lure out all of the bunnies. If you defeat all of them, the burrow will close off.",
"Good work! You've completed the tutorial!\n\nThere are two other available structures: the Healing Tower and the Bear Trap. The Healing Tower will heal you and your structures every few seconds, and the Bear Trap will catch any enemy that walks into it (press E to re-activate it).\n\nYou can re-activate this spawner by pressing E on it. Feel free to experiment with the structures, and click Main Menu when you are finished."]

onready var parent = $".."
onready var player = $"../../Entities/Player"
onready var burrow = $"../../Burrows/Burrow"
onready var tilemap = $"../../Navigation2D/TileMap"
onready var enemy_manager = $"../../Entities/EnemyManager"
onready var label = $Text
onready var finish = $"../Finish"

func _ready():
	tilemap.createDragonBones(12, 2)
	burrow.can_raid = false
	show_next_message()


func _process(delta):
	if dialog_idx == 3 && parent.hudUnobtainiumCount >= 2 && $TransitionTimer.time_left == 0:
		player.stop_manual_mining()
		player.emit_signal("is_manual_mining", player)
		$TransitionTimer.start()
	elif dialog_idx == 4 && parent.hudUnobtainiumCount >= 6:
		show_next_message()
	elif dialog_idx == 5 && player.hasFairySwatter:
		show_next_message()
	elif dialog_idx == 6 && parent.hudFairyDustCount >= 3 && $TransitionTimer.time_left == 0:
		$TransitionTimer.start(1)
	elif dialog_idx == 8 && Global.kill_count >= 3:
		show_next_message()
	elif dialog_idx == 9 && Global.kill_count >= 5:
		show_next_message()
	elif dialog_idx == 11 && player.dragonOilCount >= 5:
		show_next_message()
		burrow.can_raid = true
	elif dialog_idx == 12 && !burrow.can_raid && enemy_manager.get_child_count() == 0:
		show_next_message()


func show_next_message():
	show()
	get_tree().paused = true
	label.text = dialog[dialog_idx]
	parent.disable_pause = true
	dialog_idx += 1
	
	if dialog_idx == 3:
		cont = false
	elif dialog_idx == 7:
		cont = true
		player.unobtainiumCount = 50
		player.fairyDustCount = 50
	elif dialog_idx == 8:
		cont = false
		burrow.enable()


func _on_TutorialPopup_confirmed():
	if dialog_idx == 10:
		$TransitionTimer.start(10)
	if dialog_idx == 13:
		burrow.set_reactivatable()
		finish.disabled = false
		finish.visible = true
	if cont:
		show_next_message()
	else:
		get_tree().paused = false
		parent.disable_pause = false


func _on_TransitionTimer_timeout():
	show_next_message()


func _on_Finish_pressed():
	get_tree().change_scene("res://src/Main.tscn")
