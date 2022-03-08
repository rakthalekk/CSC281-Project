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

var walk_counter = 0

onready var anim_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hp <= 0:
		queue_free()
	if knockback:
		velocity = direction * knockback_speed
	elif target:
		#anim_player.play("angry") no animation setup yet
		
		$Sprite.texture = ANGRY
		
		direction = (target.position - position).normalized();
		velocity = direction * run_speed
	else:
		if walk_counter > 0:
			walk_counter -= 1
		else:
			if (rand_range(0, 1) > 0.5):
				direction = Vector2.ZERO
			else:
				direction = Vector2(rand_range(-1, 1), rand_range(-1, 1))
			walk_counter = rand_range(30, 50)
		$Sprite.texture = CALM
		
		velocity = direction * walk_speed
	
	velocity = move_and_slide(velocity)
	



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


func _on_VisionRadius_body_exited(body):
	if body is Player:
		target = null


func _on_Hitbox_body_entered(body):
	if body is Player:
		var dir = (body.position - position).normalized()
		body.damage(dmg, dir)
