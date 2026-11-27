extends Node2D

var player: Object = null

@export var attackDamage: float

@export var baseAttackCooldown: float
var attackCooldown: float
var attackOffCooldown: bool = false

var inAttack: bool = false
@export var baseAttackPrepare: float
var attackPrepare: float

@export var baseShiftCooldown: float
var shiftCooldown: float

var targetPosition: Vector2
var camera: Object

var rng: RandomNumberGenerator
var attackRNG: int

var t: float = 0

@export var attackSpeed: float

@onready var moth := preload("res://scenes/minibosses/moth.tscn")

func _ready() -> void:
	await get_tree().process_frame
	# Gets the player pointer from the parent Area2D
	player = get_parent().player
	camera = get_tree().current_scene.camera
	
	get_parent().type = EnemyTypeWrapper.Type.MONSTER
	get_parent().sprite.modulate = Color(1,0,0)
	
	attackCooldown = baseAttackCooldown
	attackPrepare = baseAttackPrepare
	shiftCooldown = baseShiftCooldown
	
	rng = RandomNumberGenerator.new()
	
func checkInBounds(point: Vector2) -> bool:
	var halfSize = (camera.get_viewport_rect().size / camera.zoom) * 0.5
	var cornerPos = camera.get_screen_center_position() - halfSize
	
	var localPos = point - cornerPos

	if localPos.x >= 100 and localPos.x <= 2150 and localPos.y >= 100 and localPos.y <= 1150:
		return true
	return false
	
func infinity() -> Vector2:
	var x: float = (cos(t)) / (1 + (sin(t)) ** 2)
	var y: float = (sin(t) * cos(t)) / (1 + (sin(t)) ** 2)
	
	return 800 * Vector2(x, y) + camera.get_screen_center_position()

# Mothman moves in a figure-8
func _process(delta: float) -> void:
	get_parent().moveVelocity = Vector2.ZERO
	
	if !inAttack: t += delta
	if !get_parent().invincibilityFlag: targetPosition = infinity()
	
	if get_parent().position.distance_to(targetPosition) >= 20 and checkInBounds(targetPosition):
		get_parent().moveVelocity = Vector2(1000,0).rotated(self.get_angle_to(targetPosition))
		
	shiftCooldown -= delta
	if shiftCooldown <= 0:
		shift()
		shiftCooldown = baseShiftCooldown
		
	if !attackOffCooldown:
		attackCooldown -= delta
		if attackCooldown <= 0:
			attackOffCooldown = true
			
	if attackOffCooldown and !inAttack:
		get_parent().modulate = Color(0, 0, 0)
		attackRNG = rng.randi_range(0, 3)
		#attackRNG = 1
		inAttack = true
		get_parent().text.set_text(str(attackRNG))
	
	if inAttack:
		get_parent().moveVelocity = Vector2.ZERO
		attackPrepare -= delta
		if attackPrepare <= 0:
			match attackRNG:
				0: mothSwarm()
				1: bouncingMoth()
				2: mothSummon()
				3: mothSpawner()

func shift() -> void:
	var type: EnemyTypeWrapper.Type = get_parent().type
	if type == EnemyTypeWrapper.Type.MONSTER:
		get_parent().type = EnemyTypeWrapper.Type.UNHOLY
		get_parent().sprite.modulate = Color(0,1,0)
	elif type == EnemyTypeWrapper.Type.UNHOLY:
		get_parent().type = EnemyTypeWrapper.Type.MONSTER
		get_parent().sprite.modulate = Color(1,0,0)

# Throws moths
func mothSwarm() -> void:
	get_parent().modulate = Color(0, 0, 0)	
	
	var newAttacks: Array = []
	for i in range(7):
		newAttacks.append(moth.instantiate())
		newAttacks[i].speed = attackSpeed
		newAttacks[i].damage = attackDamage
		get_tree().current_scene.add_child(newAttacks[i])
		newAttacks[i].player = player
		newAttacks[i].position = get_parent().position
		newAttacks[i].angle = self.get_angle_to(player.position) - ((3 * PI) / 10) + ((i * PI) / 12)
		newAttacks[i].rotation = newAttacks[i].angle
		newAttacks[i].move = true
		newAttacks[i].scale *= 0.8
		
	reset()
	
	await get_tree().create_timer(0.4).timeout
	
	for i in range(7):
		if newAttacks[i]:
			newAttacks[i].move = false
			newAttacks[i].toPlayer()
			
	await get_tree().create_timer(0.2).timeout
	
	for i in range(7):
		if newAttacks[i]:
			newAttacks[i].move = true
			
	reset()

# Throws moth that bounces off walls
func bouncingMoth() -> void:
	get_parent().modulate = Color(0, 0, 0)	
	
	var newAttack = moth.instantiate()
	newAttack.speed = attackSpeed
	newAttack.damage = attackDamage
	get_tree().current_scene.add_child(newAttack)
	newAttack.player = player
	newAttack.position = get_parent().position
	newAttack.angle = self.get_angle_to(player.position)
	newAttack.rotation = newAttack.angle
	newAttack.move = true
	newAttack.scale *= 1.3
	newAttack.bounceCount = 3
	
	reset()
	
# Summons moths at corners of map
func mothSummon() -> void:
	get_parent().modulate = Color(0, 0, 0)	
	
	reset()

# Summons moth spawner
func mothSpawner() -> void:
	get_parent().modulate = Color(0, 0, 0)	

	reset()

func reset() -> void:
	inAttack = false
	attackPrepare = baseAttackPrepare
	attackCooldown = baseAttackCooldown
	attackOffCooldown = false
	get_parent().text.set_text("")
