extends Enemy


var queue_attack = false
var tounge_target = null
var tounge_hit = false


func _ready():
	._ready()
	Global.frog_num += 1
	unobtainium_drop_rate = 15
	fairy_dust_drop_rate = 50
	dragon_oil_drop_rate = 5


func perish():
	.perish()
	Global.frog_num -= 1


func play_jump():
	anim_player.play("hop")


func manage_animation():
	if !knockback && queue_attack && anim_player.current_animation == "stance":
		anim_player.play("attack")
		queue_attack = false
	
	if !knockback && anim_player.current_animation == "attack":
		velocity = Vector2.ZERO
	elif !knockback && anim_player.current_animation != "hop":
		velocity = Vector2.ZERO
		anim_player.play("stance")


func _on_EntityDetect_body_entered(body):
	queue_attack = true
	tounge_target = body


func get_tounge_direction():
	if is_instance_valid(tounge_target):
		tounge_hit = false
		$Tounge.look_at(tounge_target.global_position - Vector2(0, 20))


func _on_Tounge_body_entered(body):
	if !tounge_hit:
		tounge_hit = true
		if body is Player:
			var dir = (body.position - position).normalized()
			body.damage(dmg, dir)
		else:
			body.damage(dmg)
