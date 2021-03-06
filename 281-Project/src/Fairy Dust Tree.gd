class_name FairyLog
extends StaticBody2D

# Fairy Log Variables
var logCooldown = [15,45] #[min time, max time] time in seconds
var fairyDustReward = [3,5] #Amount of fairy dust collected from logs

var spawnedTexture = load("res://assets/Map Elements/fairylogColored.png")
var cooldownTexture = load("res://assets/Map Elements/fairylog.png")

onready var sprite = $Sprite
onready var sound = $AudioStreamPlayer2D
onready var particles = $Particles2D
onready var parent = $"../.."
onready var respawnTimer = $"Respawn Timer"
onready var regenProgress = $Node2D/RegenProgress

# Random Number Generator
onready var rng = RandomNumberGenerator.new()

# The entity (player) in the radius that's being interacted with
var entity = null

var waitTime = 0.0

# Keeps track of if the dust can be harvested
var canHarvest = true

#Get tile area covered- relative to tile spawnpoint
static func getTileAreaCoverage():
	var tileAreaMin = [-2,-2] #Top left corner of the object ACTUAL SIZE: [-2,-1]
	var tileAreaMax = [1,0] #Bottom right corner of the object [1,0]
	return [tileAreaMin,tileAreaMax]

func _ready():
	yield(parent, "ready")
	rng.randomize()
	canHarvest = true
	parent.update_log_navigation(global_position)


func _process(delta):
	var time = respawnTimer.time_left
	if time != 0:
		regenProgress.value = int(waitTime - time)


func harvested(body):
	body.fairyDustCount += rng.randi_range(fairyDustReward[0], fairyDustReward[1])
	canHarvest = false
	body.harvest_fairy_dust = false
	sprite.texture = cooldownTexture
	particles.emitting = false
	sound.play()
	waitTime = rng.randi_range(logCooldown[0],logCooldown[1])
	respawnTimer.wait_time = waitTime
	respawnTimer.start()
	$HarvestArea/CollisionShape2D.disabled = true
	regenProgress.visible = true
	regenProgress.max_value = waitTime


func _on_Respawn_Timer_timeout():
	if(entity != null):
		entity.harvest_fairy_dust = true
	canHarvest = true
	sprite.texture = cooldownTexture
	particles.emitting = true
	$HarvestArea/CollisionShape2D.disabled = false
	regenProgress.visible = false


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
