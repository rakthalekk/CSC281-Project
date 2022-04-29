extends Node2D

onready var body: PackedScene = preload("res://src/Snake Body.tscn")
onready var head: KinematicBody2D = $"Snake Head"

var bodies: Array = []

# Signal when the bodies of the snake have been generated
signal bodies_ready

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range (20):
		add_segment(i)
	#get_node("Snake Head").bodies = bodies
	emit_signal("bodies_ready", bodies)

func add_segment(index = -1):
	var new_segment: KinematicBody2D = body.instance()
	add_child(new_segment)
	if bodies.size() == 0:
		new_segment.parent = head
	else:
		new_segment.parent = bodies.back()
	new_segment.index = index
	bodies.append(new_segment)
