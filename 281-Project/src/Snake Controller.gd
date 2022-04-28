extends Node2D

onready var body: PackedScene = preload("res://src/Snake Body.tscn")
onready var head: KinematicBody2D = $"Snake Head"

var bodies: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range (20):
		add_segment()

func add_segment():
	var new_segment: KinematicBody2D = body.instance()
	add_child(new_segment)
	if bodies.size() == 0:
		new_segment.parent = head
	else:
		new_segment.parent = bodies.back()
	bodies.append(new_segment)
