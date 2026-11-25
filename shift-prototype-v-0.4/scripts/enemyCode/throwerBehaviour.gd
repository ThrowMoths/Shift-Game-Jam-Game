extends Node2D

var player: Object = null

@export var throwerRange: float
@export var baseNewTargetCooldown: float
var newTargetCooldown: float
var targetPosition: Vector2
var rng: RandomNumberGenerator
var rngAngle: float

@export var attackDamage: float
@export var attackSpeed: float

@export var baseAttackCooldown: float
var attackCooldown: float
var attackOffCooldown: bool = false

var inAttack: bool = false
@export var baseAttackPrepare: float
var attackPrepare: float
var attackReady: bool = false

@onready var throwerAttack := preload("res://scenes/enemies/EnemyThrowerAttack.tscn")

func _ready() -> void:
	await get_tree().process_frame
	# Gets the player pointer from the parent Area2D
	player = get_parent().player
	attackCooldown = baseAttackCooldown
	attackPrepare = baseAttackPrepare
	newTargetCooldown = baseNewTargetCooldown
	
	rng = RandomNumberGenerator.new()
	getTargetPosition()
	
func getTargetPosition() -> void:
	rngAngle = rng.randf_range(0, 2*PI)
	targetPosition = (player.position + Vector2(throwerRange, 0).rotated(rngAngle)).round()
	if !checkInBounds(targetPosition): getTargetPosition()
	
func checkInBounds(point: Vector2) -> bool:
	var spaceState := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	
	query.position = point
	query.collide_with_bodies = true
	query.collide_with_areas = true
	
	var collisionObjects := spaceState.intersect_point(query)
	
	for obj in collisionObjects:
		if obj.collider.is_in_group("Wall"):
			return false
	
	return true

# Throwers try and stay at a set range from you and throw attacks intermittently
func _process(delta: float) -> void:
	get_parent().moveVelocity = Vector2.ZERO
	
	newTargetCooldown -= delta
	if newTargetCooldown <= 0:
		getTargetPosition()
		newTargetCooldown = baseNewTargetCooldown
	
	if !attackOffCooldown:
		attackCooldown -= delta
		if attackCooldown <= 0:
			attackOffCooldown = true
	
	if inAttack:
		get_parent().moveVelocity = Vector2.ZERO
		attackPrepare -= delta
		if attackPrepare <= 0:
			attackReady = true
		
	if attackOffCooldown and !inAttack:
		inAttack = true
		get_parent().modulate = Color(0, 0, 0)
	
	if !inAttack and get_parent().position != targetPosition:
		get_parent().moveVelocity = Vector2(1000,0).rotated(self.get_angle_to(targetPosition))
		
		if get_parent().position.distance_to(targetPosition) < 10:
			get_parent().moveVelocity = Vector2.ZERO
			get_parent().position = targetPosition
	
	if attackReady:
		get_parent().modulate = Color(0, 0, 0)
		
		var newAttack1 := throwerAttack.instantiate()
		var newAttack2 := throwerAttack.instantiate()
		var newAttack3 := throwerAttack.instantiate()
		
		newAttack1.angle = self.get_angle_to(player.position)
		newAttack2.angle = self.get_angle_to(player.position) + PI/24
		newAttack3.angle = self.get_angle_to(player.position) - PI/24
		
		newAttack1.speed = attackSpeed
		newAttack2.speed = attackSpeed
		newAttack3.speed = attackSpeed
		
		newAttack1.damage = attackDamage
		newAttack2.damage = attackDamage
		newAttack3.damage = attackDamage
		
		get_tree().current_scene.add_child(newAttack1)
		get_tree().current_scene.add_child(newAttack2)
		get_tree().current_scene.add_child(newAttack3)
		
		newAttack1.position = get_parent().position
		newAttack2.position = get_parent().position
		newAttack3.position = get_parent().position
		
		attackCooldown = baseAttackCooldown
		attackOffCooldown = false
		inAttack = false
		attackPrepare = baseAttackPrepare
		attackReady = false
