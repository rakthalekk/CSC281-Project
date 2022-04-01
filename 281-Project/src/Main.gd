extends Node2D

const BULLET = preload("res://src/Bullet.tscn")
const DRILL = preload("res://src/Drill.tscn")
const TURRET = preload("res://src/Turret.tscn")
const BUNNY = preload("res://src/Enemy.tscn")

signal update_resource_counts

var structures = []

onready var player = $Entities/Player
onready var bullet_manager = $BulletManager
onready var enemy_manager = $Entities/EnemyManager
onready var structure_manager = $Entities/StructureManager
onready var tilemap = $Navigation2D/TileMap
onready var nav = $Navigation2D

onready var tileNone = "None"
onready var tileGrass = "Grass"
onready var tileUnobtainium = "Unobtainium"

func _process(delta):
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
	#print("MAIN ON TILE: " + str(tile_id))

func _on_make_bullet(pos: Vector2, dir: Vector2):
	var inst = BULLET.instance()
	bullet_manager.add_child(inst)
	inst.position = pos
	inst.direction = dir


func create_drill(pos: Vector2):
	if tilemap.get_cellv(tilemap.world_to_map(pos)) == tilemap.stoneTileID:
		# Can't place another structure within 100 pixels of any existing ones
		for s in structures:
			if pos.distance_to(s.position) <= 100:
				return;
		
		update_tile_navigation(pos, true)
		
		var inst = DRILL.instance()
		structure_manager.add_child(inst)
		inst.position = pos
		structures.append(inst)
		emit_signal("update_resource_counts")


func create_turret(pos: Vector2):
	
	for s in structures:
		if pos.distance_to(s.position) <= 100:
			return;
	
	update_tile_navigation(pos, true)
	
	var inst = TURRET.instance()
	structure_manager.add_child(inst)
	inst.position = pos
	structures.append(inst)
	inst.connect("make_bullet", self, "_on_make_bullet")
	emit_signal("update_resource_counts")


func update_tile_navigation(pos: Vector2, disable_nav: bool):
	var tile_pos = tilemap.world_to_map(pos) - Vector2(1, 1)
	
	# Disable navigation in a 3x3 grid around the structure
	if disable_nav:
		for i in range(3):
			for j in range(3):
				var p = tile_pos + Vector2(i, j)
				if tilemap.get_cellv(p) == tilemap.stoneTileID:
					tilemap.set_cellv(p, tilemap.stoneNoNavID)
				elif tilemap.get_cellv(p) == tilemap.grassTileID:
					tilemap.set_cellv(p, tilemap.grassNoNavID)
	# Enable navigation in a 3x3 grid around the structure
	else:
		for i in range(3):
			for j in range(3):
				var p = tile_pos + Vector2(i, j)
				if tilemap.get_cellv(p) == tilemap.stoneNoNavID:
					tilemap.set_cellv(p, tilemap.stoneTileID)
				elif tilemap.get_cellv(p) == tilemap.grassNoNavID:
					tilemap.set_cellv(p, tilemap.grassTileID)
	tilemap.update_bitmask_region()


func remove_structure(struct):
	structures.remove(structures.find(struct))
	var pos = tilemap.map_to_world(tilemap.world_to_map(struct.global_position)) + Vector2(32, 32)
	update_tile_navigation(pos, false)
	struct.queue_free()


func _on_Player_place_structure(pos: Vector2):
	# This signal also being received in the HUD for resource manipulation
	# Positions the structure in the center of the tile
	pos = tilemap.map_to_world(tilemap.world_to_map(pos)) + Vector2(32, 32)
	if Global.selected_item == "drill":
		create_drill(pos)
	elif Global.selected_item == "turret":
		create_turret(pos)


func _on_EnemyPathingTimer_timeout():
	get_tree().call_group("enemy", "get_target_path")


func _on_Burrow_spawn_bunny(pos: Vector2):
	var inst = BUNNY.instance()
	enemy_manager.add_child(inst)
	inst.position = pos
