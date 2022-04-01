extends StaticBody2D

var spawnedTexture = load("res://assets/Resources/Fairy Tree Dust.png")
var cooldownTexture = load("res://assets/Resources/Fairy Tree.png")

onready var sprite = $Sprite

func _on_Respawn_Timer_timeout():
	#print("SWITCHING TREE:")
	if(sprite.texture == spawnedTexture):
		#print("to cooldown tree")
		sprite.texture = cooldownTexture
	else:
		#print("to spawned tree")
		sprite.texture = spawnedTexture


func _on_HarvestArea_body_entered(body):
	if body is Player:
		body.harvest_fairy_dust = true


func _on_HarvestArea_body_exited(body):
	if body is Player:
		body.harvest_fairy_dust = false
