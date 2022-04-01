extends StaticBody2D

var spawnedTexture = load("res://assets/Map Elements/fairylogColored.png")
var cooldownTexture = load("res://assets/Map Elements/fairylog.png")


onready var sprite = $Sprite
onready var parent = $"../.."
onready var respawnTimer = $"Respawn Timer"

# Random Number Generator
var rng = RandomNumberGenerator.new()

# The entity (player) in the radius that's being interacted with
var entity = null

# Keeps track of if the dust can be harvested
var canHarvest = true

func _ready():
	yield(parent, "ready")
	parent.update_log_navigation(global_position)

func harvested(body):
	canHarvest = false
	body.harvest_fairy_dust = false
	sprite.texture = cooldownTexture
	var waitTime = rng.randi_range(Global.logCooldown[0],Global.logCooldown[1])
	respawnTimer.wait_time = waitTime
	respawnTimer.start()

func _on_Respawn_Timer_timeout():
	if(entity != null):
		entity.harvest_fairy_dust = true
	canHarvest = true
	sprite.texture = spawnedTexture


func _on_HarvestArea_body_entered(body):
	if (body is Player && canHarvest):
		entity = body
		body.harvest_fairy_dust = true
		body.nearLog = self


func _on_HarvestArea_body_exited(body):
	if body is Player:
		body.harvest_fairy_dust = false
		body.nearLog = null
		body.stop_interacting()
		entity = null
