class_name Enemy
extends KinematicBody2D

export(Texture) var CALM
export(Texture) var ANGRY
export(int) var dmg = 10
export(int) var walk_speed = 100
export(int) var run_speed = 200
export(int) var knockback_speed = 400
export(int) var max_health = 30

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var target = null
var knockback = false
var targets = []
var path = []
var threshold = 16
var nav = null

var walk_counter = 0

onready var hp = max_health
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
		#$Sprite.texture = ANGRY
		pursue_target()
	else:
		#$Sprite.texture = CALM
		wander(walk_speed)
	
	if !knockback:
		anim_player.play("jump")
	
	velocity = move_and_slide(velocity)


func pursue_target():
	# Finds closest target
	var closest_target = targets[0]
	var shortest_dist = 999
	for t in targets:
		var d = global_position.distance_to(t.global_position)
		if d < shortest_dist:
			closest_target = t
			shortest_dist = d
	
	# Find the length of the path to the player
	var dist_to_player = 999
	if path.size() > 0:
		dist_to_player = global_position.distance_to(path[0])
	for i in range(path.size() - 1):
		dist_to_player += path[i].distance_to(path[i + 1])
	
	# Prioritize pursing the player, pursue other structures if 3x closer than player
	if path.size() > 0 && targets[0] is Player && dist_to_player < 3 * shortest_dist:
		pursue_player()
	
	# Directly target structures without pathing
	else:
		move_to_target(closest_target.global_position)


# Target the player using navigation, pathing around structures and walls
func pursue_player():
	if global_position.distance_to(path[0]) < threshold:
		path.remove(0)
	else:
		move_to_target(path[0])


func move_to_target(target: Vector2):
#	if anim_player.current_animation == "jump":
		direction = global_position.direction_to(target)
		velocity = direction * run_speed
#	else:
#		velocity = Vector2.ZERO
#		anim_player.play("charge")


func play_jump():
	anim_player.play("jump")


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
