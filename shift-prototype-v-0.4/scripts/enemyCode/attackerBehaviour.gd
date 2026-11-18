extends Node2D

var player: Object = null

@export var attackDamage: float

@export var baseAttackCooldown: float
var attackCooldown: float
var attackOffCooldown: bool = false

var inAttack: bool = false
@export var baseAttackPrepare: float
var attackPrepare: float
var attackReady: bool = false

@onready var meleeAttack := preload("res://scenes/enemies/EnemyMeleeAttack.tscn")

func _ready() -> void:
	await get_tree().process_frame
	# Gets the player pointer from the parent Area2D
	player = get_parent().player
	attackCooldown = baseAttackCooldown
	attackPrepare = baseAttackPrepare

# Attackers are simple, they rush towards you, and attack if you are in range
func _process(delta: float) -> void:
	
	get_parent().moveVelocity = Vector2.ZERO
	
	if !attackOffCooldown:
		attackCooldown -= delta
		if attackCooldown <= 0:
			attackOffCooldown = true
	
	if inAttack:
		get_parent().moveVelocity = Vector2.ZERO
		attackPrepare -= delta
		if attackPrepare <= 0:
			attackReady = true
			
	if get_parent().position.distance_to(player.position) < 200 and attackOffCooldown and !inAttack:
		inAttack = true
		get_parent().modulate = Color(0, 0, 0)
	
	if player and !inAttack:
		get_parent().moveVelocity = Vector2(500,0).rotated(self.get_angle_to(player.position))
	
	if attackReady:
		get_parent().modulate = Color(0, 0, 0)
		var newAttack := meleeAttack.instantiate()
		newAttack.rotation = get_angle_to(player.position)
		newAttack.damage = attackDamage
		get_tree().current_scene.add_child(newAttack)
		newAttack.position = get_parent().position
		
		attackCooldown = baseAttackCooldown
		attackOffCooldown = false
		inAttack = false
		attackPrepare = baseAttackPrepare
		attackReady = false
