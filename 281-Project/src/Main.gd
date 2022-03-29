extends Node2D

const BULLET = preload("res://src/Bullet.tscn")
const DRILL = preload("res://src/Drill.tscn")
const TURRET = preload("res://src/Turret.tscn")
const BUNNY = preload("res://src/Enemy.tscn")

var structures = []

onready var player = $Entities/Player
onready var bullet_manager = $BulletManager
onready var enemy_manager = $Entities/EnemyManager
onready var structure_manager = $Entities/StructureManager
onready var tilemap = $TileMap

onready var tileNone = "None"
onready var tileGrass = "Grass"
onready var tileUnobtainium = "Unobtainium"

func _process(delta):
	var cell = $TileMap.world_to_map(player.global_position)
	var tile_id = $TileMap.get_cellv(cell)
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
	#print("MAIN ON TILE: " + str(tile_id))

func _on_make_bullet(pos: Vector2, dir: Vector2):
	var inst = BULLET.instance()
	bullet_manager.add_child(inst)
	inst.position = pos
	inst.direction = dir

func create_drill(pos: Vector2):
	if $TileMap.get_cellv($TileMap.world_to_map(pos)) == $TileMap.stoneTileID:
		# Can't place another structure within 100 pixels of any existing ones
		for s in structures:
			if pos.distance_to(s.position) <= 100:
				return;
		
		var inst = DRILL.instance()
		structure_manager.add_child(inst)
		inst.position = pos
		structures.append(inst)


func create_turret(pos: Vector2):
	for s in structures:
		if pos.distance_to(s.position) <= 100:
			return;
		
	var inst = TURRET.instance()
	structure_manager.add_child(inst)
	inst.position = pos
	structures.append(inst)
	inst.connect("make_bullet", self, "_on_make_bullet")


func _on_Player_place_structure(pos: Vector2):
	if Global.selected_structure == "drill":
		create_drill(pos)
	elif Global.selected_structure == "turret":
		create_turret(pos)


func _on_BunnySpawner_spawn_bunny(pos: Vector2):
	var inst = BUNNY.instance()
	enemy_manager.add_child(inst)
	inst.position = pos
