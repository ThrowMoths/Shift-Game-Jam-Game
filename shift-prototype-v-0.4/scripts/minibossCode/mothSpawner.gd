extends Node2D

var player: Object
var parentEnemy: Object
var mothCount: int
var mothCooldown: float
@onready var moth := preload("res://scenes/minibosses/moth.tscn")

func _ready() -> void:
	for i in range(mothCount):
		await get_tree().create_timer(mothCooldown).timeout
		spawnMoth()
	call_deferred("queue_free")

func spawnMoth() -> void:
	var newAttack = moth.instantiate()
	
	newAttack.speed = parentEnemy.attackSpeed
	newAttack.damage = parentEnemy.attackDamage
	get_tree().current_scene.add_child(newAttack)
	newAttack.player = player
	newAttack.position = position
	newAttack.angle = self.get_angle_to(player.position)
	newAttack.rotation = newAttack.angle
	newAttack.move = true
	newAttack.bounceCount = 1
