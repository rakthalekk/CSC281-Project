class_name Enemy
extends KinematicBody2D

export(int) var dmg = 10
export(int) var walk_speed = 100
export(int) var run_speed = 200
export(int) var knockback_speed = 400
export(int) var max_health = 30
export(int) var unobtainium_drop_rate = 5
export(int) var fairy_dust_drop_rate = 3
export(int) var dragon_oil_drop_rate = 1

const UNOBTAINIUM = preload("res://src/Unobtainium.tscn")
const FAIRY_DUST = preload("res://src/Fairy Dust.tscn")
const DRAGON_OIL = preload("res://src/DragonOil.tscn")

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var target = null
var knockback = false
var targets = []
var path = []
var threshold = 16
var nav = null

var walk_counter = 0

onready var rng = RandomNumberGenerator.new()
onready var hp = max_health
onready var parent = $"../../.."
onready var anim_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	if Global.difficulty == 0:
		max_health -= 10
	elif Global.difficulty == 2:
		max_health += 10

	hp = max_health
	anim_player.play("RESET")
	yield(parent, "ready")
	nav = parent.nav


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	normal_behavior()


func normal_behavior():
	if hp <= 0:
		anim_player.play("die")
		return
	
	if knockback:
		velocity = direction * knockback_speed
	elif targets.size() > 0:
		pursue_target()
	else:
		wander(walk_speed)
	
	manage_animation()
	
	velocity = move_and_slide(velocity)


func manage_animation():
	if !knockback && anim_player.current_animation != "bite":
		anim_player.play("jump")
	elif !knockback && anim_player.current_animation == "bite":
		velocity = Vector2.ZERO


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
	direction = global_position.direction_to(target)
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
		# Some nonsense to prevent the game from lagging when the player is not reachable
		# Finds the path to the player and sets it to the path variable
		if Global.the_chosen_one == null:
			path = nav.get_simple_path(global_position, targets[0].global_position, false)
			if path.size() == 0:
				Global.the_chosen_one = self
		elif Global.the_chosen_one == self:
			path = nav.get_simple_path(global_position, targets[0].global_position, false)
			if path.size() != 0:
				Global.the_chosen_one = null


func damage(dmg, dir):
	knockback = true
	anim_player.play("damaged")
	direction = dir
	hp -= dmg


func disable_knockback():
	knockback = false


func reset_animation():
	anim_player.play("RESET")


func deal_damage():
	for body in $Hitbox.get_overlapping_bodies():
		if body is Player:
			var dir = (body.position - position).normalized()
			body.damage(dmg, dir)
		elif body is Structure:
			body.damage(dmg)


func perish():
	Global.kill_count += 1
	var num = rng.randi_range(0, 100)
	if num <= dragon_oil_drop_rate:
		var inst = DRAGON_OIL.instance()
		get_parent().add_child(inst)
		inst.global_position = global_position
	elif num <= fairy_dust_drop_rate + dragon_oil_drop_rate:
		var inst = FAIRY_DUST.instance()
		get_parent().add_child(inst)
		inst.global_position = global_position
	elif num <= unobtainium_drop_rate + fairy_dust_drop_rate + dragon_oil_drop_rate:
		var inst = UNOBTAINIUM.instance()
		get_parent().add_child(inst)
		inst.global_position = global_position
	
	queue_free()


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
