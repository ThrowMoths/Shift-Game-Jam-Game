extends Node2D

var player: Object = null

@export var attackDamage: float
@export var timeToAttack: float

@export var baseAttackCooldown: float
var attackCooldown: float
var attackOffCooldown: bool = false

@onready var spellcasterAttack := preload("res://scenes/enemies/EnemySpellcasterAttack.tscn")

func _ready() -> void:
	await get_tree().process_frame
	# Gets the player pointer from the parent Area2D
	player = get_parent().player
	attackCooldown = baseAttackCooldown

# Spellcasters stay in place and attack in large areas
func _process(delta: float) -> void:
	
	if !attackOffCooldown:
		attackCooldown -= delta
		if attackCooldown <= 0:
			attackOffCooldown = true
			
	if attackOffCooldown:
		get_parent().modulate = Color(0, 0, 0)
		var newAttack := spellcasterAttack.instantiate()
		newAttack.timeToAttack = timeToAttack
		newAttack.damage = attackDamage
		get_tree().current_scene.add_child(newAttack)
		newAttack.position = player.position
		
		attackCooldown = baseAttackCooldown
		attackOffCooldown = false
