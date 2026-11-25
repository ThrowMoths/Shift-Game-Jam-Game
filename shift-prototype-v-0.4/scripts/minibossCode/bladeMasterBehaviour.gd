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
var centrePosition: Vector2
var camera: Object

var rng: RandomNumberGenerator
var attackRNG: int
var standardMovement: bool = true

@export var attackSpeed: float

@onready var meleeAttack := preload("res://scenes/minibosses/MinibossMeleeAttack.tscn")
@onready var daggerAttack := preload("res://scenes/minibosses/dagger.tscn")

func _ready() -> void:
	await get_tree().process_frame
	# Gets the player pointer from the parent Area2D
	player = get_parent().player
	camera = get_tree().current_scene.camera
	
	get_parent().type = EnemyTypeWrapper.Type.SPIRIT
	get_parent().sprite.modulate = Color(0,0,1)
	
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

# Blade Master tries to stay the same distance to the player
func _process(delta: float) -> void:
	if !inAttack:
		var newPos = player.position + Vector2(600,0).rotated(player.get_angle_to(get_parent().position))
		if checkInBounds(newPos): get_parent().position = newPos
		
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
		attackRNG = 3
		inAttack = true
		get_parent().text.set_text(str(attackRNG))
	
	if inAttack:
		get_parent().moveVelocity = Vector2.ZERO
		attackPrepare -= delta
		if attackPrepare <= 0:
			match attackRNG:
				0: greatStrike()
				1: dancingStrike()
				2: daggerThrow()
				3: daggerCircle()

func shift() -> void:
	var type: EnemyTypeWrapper.Type = get_parent().type
	if type == EnemyTypeWrapper.Type.MONSTER:
		get_parent().type = EnemyTypeWrapper.Type.SPIRIT
		get_parent().sprite.modulate = Color(0,0,1)
	elif type == EnemyTypeWrapper.Type.SPIRIT:
		get_parent().type = EnemyTypeWrapper.Type.MONSTER
		get_parent().sprite.modulate = Color(1,0,0)

# Big slash
func greatStrike() -> void:
	get_parent().modulate = Color(0, 0, 0)	
	var newAttack := meleeAttack.instantiate()
	
	newAttack.rotation = self.get_angle_to(player.position)
	newAttack.damage = attackDamage
	get_tree().current_scene.add_child(newAttack)
	newAttack.position = get_parent().position
	newAttack.scale = Vector2(1.5, 1.5)
	
	reset()

# Erratic movement then attacks at a random interval
func dancingStrike() -> void:
	reset()
	
# Throws daggers
func daggerThrow() -> void:
	var newAttacks: Array = []
	for i in range(7):
		newAttacks.append(daggerAttack.instantiate())
		newAttacks[i].speed = attackSpeed
		newAttacks[i].damage = attackDamage
		get_tree().current_scene.add_child(newAttacks[i])
		newAttacks[i].position = get_parent().position
		newAttacks[i].angle = self.get_angle_to(player.position) - ((3 * PI) / 10) + ((i * PI) / 12)
		newAttacks[i].rotation = newAttacks[i].angle
		newAttacks[i].move = true
	reset()

# Four daggers around the player
func daggerCircle() -> void:
	var positions: Array = [Vector2(-300, 0), Vector2(0, -300), Vector2(300, 0), Vector2(0, 300)]
	var angles: Array = [0, PI / 2, PI, (3 * PI) / 2]
	var newAttacks: Array = []
	
	reset()
	attackCooldown += 1.5
	
	for i in range(4):
		newAttacks.append(daggerAttack.instantiate())
		newAttacks[i].speed = attackSpeed
		newAttacks[i].damage = attackDamage
		get_tree().current_scene.add_child(newAttacks[i])
		newAttacks[i].position = get_parent().position
		newAttacks[i].scale *= 0.85
		#newAttacks[i].angle = angles[i]
		#newAttacks[i].rotation = angles[i]
		newAttacks[i].surrounding = true
		newAttacks[i].targetPos = player.position + positions[i]
		print(newAttacks[i].targetPos)
	
	#await get_tree().create_timer(1.5).timeout
	#
	#for i in range(4):
		#newAttacks[i].surrounding = false
		#newAttacks[i].move = true

func reset() -> void:
	inAttack = false
	attackPrepare = baseAttackPrepare
	attackCooldown = baseAttackCooldown
	attackOffCooldown = false
	get_parent().text.set_text("")
