class_name Enemy
extends KinematicBody2D

const CALM = preload("res://assets/Enemies/bunnyaup.png")
const ANGRY = preload("res://assets/Enemies/bunnybup.png")

export(int) var dmg = 10
export(int) var walk_speed = 100
export(int) var run_speed = 200
export(int) var knockback_speed = 400
export(int) var max_health = 30

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var target = null
var knockback = false
var hp = max_health
var targets = []
var path = []
var threshold = 16
var nav = null

var walk_counter = 0

onready var parent = get_tree().get_root().get_node("Main")
onready var anim_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(parent, "ready")
	nav = parent.nav


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hp <= 0:
		queue_free()
	if knockback:
		velocity = direction * knockback_speed
	elif targets.size() > 0:
		$Sprite.texture = ANGRY
		if path.size() > 0 && targets[0] is Player:
			pursue_player()
		else:
			pursue_structure()
	else:
		$Sprite.texture = CALM
		wander(walk_speed)
	
	velocity = move_and_slide(velocity)


func pursue_player():
	if global_position.distance_to(path[0]) < threshold:
		path.remove(0)
	else:
		direction = global_position.direction_to(path[0])
		velocity = direction * run_speed


func pursue_structure():
	direction = global_position.direction_to(targets[0].global_position)
	velocity = direction * run_speed


func wander(speed):
	if walk_counter > 0:
		walk_counter -= 1
	else:
		if (rand_range(0, 1) > 0.5):
			direction = Vector2.ZERO
		else:
			direction = Vector2(rand_range(-1, 1), rand_range(-1, 1))
		walk_counter = rand_range(30, 50)
	velocity = direction * speed


func get_target_path():
	if nav == null:
		nav = parent.nav
	if targets.size() > 0:
		path = nav.get_simple_path(global_position, targets[0].global_position, false)


func damage(dmg, dir):
	knockback = true
	anim_player.play("damaged")
	direction = dir
	hp -= dmg


func disable_knockback():
	knockback = false


func _on_VisionRadius_body_entered(body):
	if body is Player:
		target = body
		targets.insert(0, body)
	elif body is Structure:
		targets.append(body)


func _on_VisionRadius_body_exited(body):
	var idx = targets.find(body)
	if idx != -1:
		targets.remove(idx)

	if body is Player:
		target = null


func _on_Hitbox_body_entered(body):
	if body is Player:
		var dir = (body.position - position).normalized()
		body.damage(dmg, dir)
	elif body is Structure:
		body.damage(dmg)
