extends Node2D

const BULLET = preload("res://src/Bullet.tscn")
const DRILL = preload("res://src/Drill.tscn")

onready var player = $Player
onready var bullet_manager = $BulletManager
onready var drill_manager = $DrillManager


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
