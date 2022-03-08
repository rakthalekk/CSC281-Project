extends Node2D

const BULLET = preload("res://src/Bullet.tscn")
const DRILL = preload("res://src/Drill.tscn")

onready var player = $Player
onready var bullet_manager = $BulletManager
onready var drill_manager = $DrillManager
onready var tilemap = $TileMap

onready var tileNone = "None"
onready var tileGrass = "Grass"
onready var tileUnobtainium = "Unobtainium"

func _process(delta):
	var cell = $TileMap.world_to_map($Player.global_position)
	var tile_id = $TileMap.get_cellv(cell)
	# -1 if out of bounds, 0 if on the grass, 1 if on the stone
	# Cell is the block the coords of the tile the player is on: (X, Y)
	# print("TileID: " + str(tile_id) + "    Cell: " + str(cell))
	match tile_id:
		-1: #Out of bounds
			player.onTile = tileNone
		0: #On Grass
			player.onTile = tileGrass
		1: #On Stone
			player.onTile = tileUnobtainium

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("make_bullet", self, "_on_make_bullet")
	player.connect("create_drill", self, "_on_create_drill")


func _on_make_bullet(pos: Vector2, dir: Vector2):
	var inst = BULLET.instance()
	bullet_manager.add_child(inst)
	inst.position = pos
	inst.direction = dir


func _on_create_drill(pos: Vector2):
	var inst = DRILL.instance()
	drill_manager.add_child(inst)
	inst.position = pos


func _on_Player_player_stats_changed():
	pass # Replace with function body.
