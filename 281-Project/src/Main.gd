extends Node2D

# Structure References
const DRILL = preload("res://src/Drill.tscn")
const TURRET = preload("res://src/Turret.tscn")
const OILRIG = preload("res://src/OilRig.tscn")
const FIRETOWER = preload("res://src/FireTower.tscn")
const HEALTOWER = preload("res://src/HealTower.tscn")
const WALL = preload("res://src/Wall.tscn")

# Enemy References
const BUNNY = preload("res://src/Wonderbunny.tscn")

# Misc References
const BULLET = preload("res://src/Bolt.tscn")

#signal update_resource_counts

var structures = []
var valid_place = false

onready var player = $Entities/Player
onready var bullet_manager = $BulletManager
onready var enemy_manager = $Entities/EnemyManager
onready var structure_manager = $Entities/StructureManager
onready var tilemap = $Navigation2D/TileMap
onready var nav = $Navigation2D
onready var tile_highlight = $TileHighlight

onready var tileNone = "None"
onready var tileGrass = "Grass"
onready var tileUnobtainium = "Unobtainium"
onready var tilePath = "Path"

onready var playerCoords = Vector2(0,0)

func _ready():
	for pos in tilemap.logLocations:
		update_log_navigation(pos)

func _process(delta):
	#Vector2(tilemap.world_to_map(player.global_position))
	playerCoords = Vector2(2*tilemap.world_to_map(player.global_position)[0], 63) - tilemap.world_to_map(player.global_position)#player.global_position
	var cell = tilemap.world_to_map(player.global_position)
	var tile_id = tilemap.get_cellv(cell)
	# -1 if out of bounds, 0 if on the grass, 1 if on the stone
	# Cell is the block the coords of the tile the player is on: (X, Y)
	# print("TileID: " + str(tile_id) + "    Cell: " + str(cell))
	match tile_id:
		-1: #Out of bounds
			player.onTile = tileNone
		2: #On Grass
			player.onTile = tileGrass
		3: #On Stone
			player.onTile = tileUnobtainium
		4: #On Grass (no nav)
			player.onTile = tileGrass
		5: #On Stone (no nav)
			player.onTile = tileUnobtainium
		7:
			player.onTile = tilePath
		9:
			player.onTile = tilePath
	
	if Global.selected_item:
		tile_highlight.visible = true
		var mouse_tile_pos = tilemap.map_to_world(tilemap.world_to_map(get_global_mouse_position()))
		
		if Global.selected_item == "wall":
			if Global.horizontal_wall:
				tile_highlight.rect_size = Vector2(256, 64)
				tile_highlight.rect_global_position = mouse_tile_pos - Vector2(64, 0)
			else:
				tile_highlight.rect_size = Vector2(64, 256)
				tile_highlight.rect_global_position = mouse_tile_pos - Vector2(0, 64)
		else:
			tile_highlight.rect_size = Vector2(128, 128)
			tile_highlight.rect_global_position = mouse_tile_pos
		
		## CHANGE OIL RIG WHEN OIL TILES ARE IMPLEMENTED
		if (Global.selected_item == "drill") && get_stone_tile_count(mouse_tile_pos) < 3:
			tile_highlight.color = Color(1, 0, 0, 0.2)
			valid_place = false
		elif(Global.selected_item == "oilrig" && get_near_dragon_bones_count(mouse_tile_pos) < 4):
			print("BONES COUNT: " + str(get_near_dragon_bones_count(mouse_tile_pos)))
			tile_highlight.color = Color(1, 0, 0, 0.2)
			valid_place = false
		elif Global.selected_item != "wall" && !check_no_nav_tiles(mouse_tile_pos) || Global.selected_item == "wall" && !check_no_nav_tiles_wall(mouse_tile_pos):
			tile_highlight.color = Color(1, 0, 0, 0.2)
			valid_place = false
		else:
			tile_highlight.color = Color(1, 1, 0, 0.2)
			valid_place = true
	else:
		tile_highlight.visible = false


func _on_make_bullet(pos: Vector2, dir: Vector2):
	var inst = BULLET.instance()
	bullet_manager.add_child(inst)
	inst.position = pos
	inst.direction = dir


# Check number of stone tiles at location
func get_stone_tile_count(pos: Vector2):
	var count = 0
	for i in range(2):
		for j in range(2):
			var p = tilemap.world_to_map(pos) + Vector2(i, j)
			if tilemap.get_cellv(p) == tilemap.stoneTileID:
				count += 1
	return count

#Checks for dragon bones near the position. Pos is a tile location
func checkForDragonBones(pos: Vector2):
	var dragon_bones_range = Global.oilRigTileRadius#2 #Radius around bones where oil things can be placed
	for dragonBonesPos in tilemap.dragonBonesLocations:
		for block in [Vector2(0,0), Vector2(-1,0), Vector2(-1,-1), Vector2(0,-1)]:
			#Check around each block
			if((pos[0] <= dragonBonesPos[0] + block[0] + dragon_bones_range && pos[0] >= dragonBonesPos[0] + block[0] - dragon_bones_range)
				&& (pos[1] <= dragonBonesPos[1] + block[1] + dragon_bones_range && pos[1] >= dragonBonesPos[1] + block[1] - dragon_bones_range)):
				return true
	return false

# Check number of stone tiles at location
func get_near_dragon_bones_count(pos: Vector2):
	var count = 0
	for i in range(2):
		for j in range(2):
			var p = tilemap.world_to_map(pos) + Vector2(i, j)
			if(checkForDragonBones(p)):
				count += 1
	return count

# Check to ensure all tiles have navigation
func check_no_nav_tiles(pos: Vector2):
	for i in range(2):
		for j in range(2):
			var p = tilemap.world_to_map(pos) + Vector2(i, j)
			if tilemap.get_cellv(p) != tilemap.stoneTileID && tilemap.get_cellv(p) != tilemap.grassTileID && tilemap.get_cellv(p) != tilemap.pathTileID:
				return false
	return true


func check_no_nav_tiles_wall(pos: Vector2):
	if Global.horizontal_wall:
		for i in range(4):
			var p = tilemap.world_to_map(pos) + Vector2(i - 1, 0)
			if tilemap.get_cellv(p) != tilemap.stoneTileID && tilemap.get_cellv(p) != tilemap.grassTileID && tilemap.get_cellv(p) != tilemap.pathTileID:
				return false
		return true
	else:
		for j in range(4):
			var p = tilemap.world_to_map(pos) + Vector2(0, j - 1)
			if tilemap.get_cellv(p) != tilemap.stoneTileID && tilemap.get_cellv(p) != tilemap.grassTileID && tilemap.get_cellv(p) != tilemap.pathTileID:
				return false
		return true


# Create a drill at the location
func create_drill(pos: Vector2):
	update_tile_navigation(pos, true)
		
	var inst = DRILL.instance()
	structure_manager.add_child(inst)
	inst.position = pos
	structures.append(inst)


func create_turret(pos: Vector2):
	update_tile_navigation(pos, true)
	
	var inst = TURRET.instance()
	structure_manager.add_child(inst)
	inst.position = pos
	structures.append(inst)
	inst.connect("make_bullet", self, "_on_make_bullet")

# Create an oil rig at the location
func create_oilrig(pos: Vector2):
	update_tile_navigation(pos, true)
		
	var inst = OILRIG.instance()
	structure_manager.add_child(inst)
	inst.position = pos
	structures.append(inst)


func create_firetower(pos: Vector2):
	update_tile_navigation(pos, true)
		
	var inst = FIRETOWER.instance()
	structure_manager.add_child(inst)
	inst.position = pos
	structures.append(inst)


func create_healtower(pos: Vector2):
	update_tile_navigation(pos, true)
		
	var inst = HEALTOWER.instance()
	structure_manager.add_child(inst)
	inst.position = pos
	structures.append(inst)


func create_wall(pos: Vector2):
	update_tile_navigation(pos, true)
		
	var inst = WALL.instance()
	structure_manager.add_child(inst)
	if !Global.horizontal_wall:
		inst.set_vertical()
		inst.position = pos - Vector2(32, 0)
	else:
		inst.position = pos - Vector2(0, 32)
	
	structures.append(inst)


func update_wall_tile_navigation(pos: Vector2):
	if Global.horizontal_wall:
		var tile_pos = tilemap.world_to_map(pos) - Vector2(2, 1)
		for i in range(4):
			var p = tile_pos + Vector2(i, 0)
			if tilemap.get_cellv(p) == tilemap.stoneTileID:
				tilemap.set_cellv(p, tilemap.stoneNoNavID)
			elif tilemap.get_cellv(p) == tilemap.grassTileID:
				tilemap.set_cellv(p, tilemap.grassNoNavID)
			elif tilemap.get_cellv(p) == tilemap.pathTileID:
				tilemap.set_cellv(p, tilemap.pathNoNavID)
		tilemap.update_bitmask_region(tile_pos, tile_pos + Vector2(3, 0))
	else:
		var tile_pos = tilemap.world_to_map(pos) - Vector2(1, 2)
		for j in range(4):
			var p = tile_pos + Vector2(0, j)
			if tilemap.get_cellv(p) == tilemap.stoneTileID:
				tilemap.set_cellv(p, tilemap.stoneNoNavID)
			elif tilemap.get_cellv(p) == tilemap.grassTileID:
				tilemap.set_cellv(p, tilemap.grassNoNavID)
			elif tilemap.get_cellv(p) == tilemap.pathTileID:
				tilemap.set_cellv(p, tilemap.pathNoNavID)
		tilemap.update_bitmask_region(tile_pos, tile_pos + Vector2(0, 3))


func remove_wall_tile_navigation(pos: Vector2, horizontal: bool):
	if horizontal:
		var tile_pos = tilemap.world_to_map(pos) - Vector2(2, 0)
		for i in range(4):
			var p = tile_pos + Vector2(i, 0)
			if tilemap.get_cellv(p) == tilemap.stoneNoNavID:
				tilemap.set_cellv(p, tilemap.stoneTileID)
			elif tilemap.get_cellv(p) == tilemap.grassNoNavID:
				tilemap.set_cellv(p, tilemap.grassTileID)
			elif tilemap.get_cellv(p) == tilemap.pathNoNavID:
				tilemap.set_cellv(p, tilemap.pathTileID)
		tilemap.update_bitmask_region(tile_pos, tile_pos + Vector2(3, 0))
	else:
		var tile_pos = tilemap.world_to_map(pos) - Vector2(0, 2)
		for j in range(4):
			var p = tile_pos + Vector2(0, j)
			if tilemap.get_cellv(p) == tilemap.stoneNoNavID:
				tilemap.set_cellv(p, tilemap.stoneTileID)
			elif tilemap.get_cellv(p) == tilemap.grassNoNavID:
				tilemap.set_cellv(p, tilemap.grassTileID)
			elif tilemap.get_cellv(p) == tilemap.pathNoNavID:
				tilemap.set_cellv(p, tilemap.pathTileID)
		tilemap.update_bitmask_region(tile_pos, tile_pos + Vector2(0, 3))


func update_tile_navigation(pos: Vector2, disable_nav: bool):
	if Global.selected_item == "wall":
		update_wall_tile_navigation(pos)
		return
	
	var tile_pos = tilemap.world_to_map(pos) - Vector2(1, 1)
	
	# Disable navigation in a 2x2 grid around the structure
	if disable_nav:
		for i in range(2):
			for j in range(2):
				var p = tile_pos + Vector2(i, j)
				if tilemap.get_cellv(p) == tilemap.stoneTileID:
					tilemap.set_cellv(p, tilemap.stoneNoNavID)
				elif tilemap.get_cellv(p) == tilemap.grassTileID:
					tilemap.set_cellv(p, tilemap.grassNoNavID)
				elif tilemap.get_cellv(p) == tilemap.pathTileID:
					tilemap.set_cellv(p, tilemap.pathNoNavID)
	# Enable navigation in a 2x2 grid around the structure
	else:
		for i in range(2):
			for j in range(2):
				var p = tile_pos + Vector2(i, j)
				if tilemap.get_cellv(p) == tilemap.stoneNoNavID:
					tilemap.set_cellv(p, tilemap.stoneTileID)
				elif tilemap.get_cellv(p) == tilemap.grassNoNavID:
					tilemap.set_cellv(p, tilemap.grassTileID)
				elif tilemap.get_cellv(p) == tilemap.pathNoNavID:
					tilemap.set_cellv(p, tilemap.pathTileID)
	tilemap.update_bitmask_region(tile_pos, tile_pos + Vector2(1, 1))


func remove_structure(struct):
	var pos = tilemap.map_to_world(tilemap.world_to_map(struct.global_position)) + Vector2(32, 32)
	if struct is Wall:
		remove_wall_tile_navigation(pos, !struct.vertical)
	else:
		update_tile_navigation(pos, false)
	structures.remove(structures.find(struct))
	
	struct.queue_free()


func _on_Player_place_structure(pos: Vector2):
	# This signal also being received in the HUD for resource manipulation
	# Positions the structure in the center of the tile
	if valid_place:
		pos = tilemap.map_to_world(tilemap.world_to_map(pos)) + Vector2(64, 64)
		
		match Global.selected_item:
			"drill":
				create_drill(pos)
			"turret":
				create_turret(pos)
			"oilrig":
				create_oilrig(pos)
			"firetower":
				create_firetower(pos)
			"healtower":
				create_healtower(pos)
			"wall":
				create_wall(pos)
			_:
				print("Invalid structure being placed: " + str(Global.selected_item))


func _on_EnemyPathingTimer_timeout():
	get_tree().call_group("enemy", "get_target_path")


func _on_Burrow_spawn_bunny(pos: Vector2):
	var inst = BUNNY.instance()
	enemy_manager.add_child(inst)
	inst.position = pos


func update_log_navigation(pos: Vector2):
	var tile_pos = tilemap.world_to_map(pos - Vector2(96, 48))
	for i in range(4):
		for j in range(2):
			var p = tile_pos + Vector2(i, j)
			if tilemap.get_cellv(p) == tilemap.stoneTileID:
				tilemap.set_cellv(p, tilemap.stoneNoNavID)
			elif tilemap.get_cellv(p) == tilemap.grassTileID:
				tilemap.set_cellv(p, tilemap.grassNoNavID)
			elif tilemap.get_cellv(p) == tilemap.pathTileID:
				tilemap.set_cellv(p, tilemap.pathNoNavID)
