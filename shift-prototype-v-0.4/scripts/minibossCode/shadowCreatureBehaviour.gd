extends Node2D

var player: Object = null

@export var attackDamage: float

var inAttack: bool = false
@export var baseAttackPrepare: float
var attackPrepare: float
var attackReady: bool = false

@export var baseShiftCooldown: float
var shiftCooldown: float

var targetPosition: Vector2
var camera: Object

var rng: RandomNumberGenerator
var attackRNG: int

@onready var meleeAttack := preload("res://scenes/minibosses/MinibossMeleeAttack.tscn")
@onready var spiritAttack := preload("res://scenes/enemies/EnemySpellcasterAttack.tscn")

@onready var UNHOLYsprite := preload("res://assets/shadowUNHOLY.png")
@onready var SPIRITsprite := preload("res://assets/shadowSPIRIT.png")

func _ready() -> void:
	await get_tree().process_frame
	# Gets the player pointer from the parent Area2D
	player = get_parent().player
	camera = get_tree().current_scene.camera
	
	get_parent().type = EnemyTypeWrapper.Type.UNHOLY
	get_parent().sprite.texture = UNHOLYsprite
	
	attackPrepare = baseAttackPrepare
	shiftCooldown = baseShiftCooldown
	
	rng = RandomNumberGenerator.new()

# Shadow Creature stays in the centre of the screen and launches attacks from there
func _process(delta: float) -> void:
	targetPosition = camera.get_screen_center_position()
	
	get_parent().moveVelocity = Vector2(1800,0).rotated(self.get_angle_to(targetPosition))
	if get_parent().position.distance_to(targetPosition) < 10:
		get_parent().moveVelocity = Vector2.ZERO
		get_parent().position = targetPosition
		
	shiftCooldown -= delta
	if shiftCooldown <= 0:
		shift()
		shiftCooldown = baseShiftCooldown
		
	if !inAttack:
		get_parent().modulate = Color(0, 0, 0)
		attackRNG = rng.randi_range(0, 3)
		inAttack = true
		match attackRNG:
			0: halfMoonSlash()
			1: deadlyThrust()
			2: eruptingSpirit()
			3: checkerboardCast()

func shift() -> void:
	var type: EnemyTypeWrapper.Type = get_parent().type
	if type == EnemyTypeWrapper.Type.UNHOLY:
		get_parent().type = EnemyTypeWrapper.Type.SPIRIT
		get_parent().sprite.texture = SPIRITsprite
	elif type == EnemyTypeWrapper.Type.SPIRIT:
		get_parent().type = EnemyTypeWrapper.Type.UNHOLY
		get_parent().sprite.texture = UNHOLYsprite

func halfMoonSlash() -> void:
	get_parent().text.set_text("0")
	await get_tree().create_timer(2.5).timeout
	var left: bool = player.position.x <= get_parent().position.x
	get_parent().modulate = Color(0, 0, 0)
	
	var newAttack := meleeAttack.instantiate()
	
	if left: newAttack.rotation = PI
	newAttack.damage = attackDamage
	newAttack.scale *= 0.9
	
	newAttack.travel = true
	
	get_tree().current_scene.add_child(newAttack)
	newAttack.position = get_parent().position
	
	inAttack = false
	get_parent().text.set_text("")

func deadlyThrust() -> void:
	get_parent().text.set_text("1")
	await get_tree().create_timer(2.5).timeout
	get_parent().modulate = Color(0, 0, 0)
	
	var newAttack := meleeAttack.instantiate()
	newAttack.damage = attackDamage
	newAttack.travel = true
	newAttack.travelSpeed *= 0.8
	newAttack.rotation = self.get_angle_to(player.position)
	newAttack.scale = Vector2(0.6, 0.2)
	
	get_tree().current_scene.add_child(newAttack)
	newAttack.position = get_parent().position
	
	inAttack = false
	get_parent().text.set_text("")
	
func eruptingSpirit() -> void:
	get_parent().text.set_text("2")
	await get_tree().create_timer(2.5).timeout
	get_parent().modulate = Color(0, 0, 0)
	
	var newAttack := spiritAttack.instantiate()
	newAttack.timeToAttack = 0.5
	newAttack.doScale = true
	newAttack.damage = attackDamage
	get_tree().current_scene.add_child(newAttack)
	newAttack.position = get_parent().position
		
	inAttack = false
	get_parent().text.set_text("")
	
func checkerboardCast() -> void:
	get_parent().text.set_text("3")
	await get_tree().create_timer(2.5).timeout
	get_parent().modulate = Color(0, 0, 0)
	
	var newAttacks = []
	var moveVectors = [
		Vector2(-800, -400), Vector2(0, -400), Vector2(800, -400), 
		Vector2(-400, 0), Vector2(400, 0), 
		Vector2(-800, 400), Vector2(0, 400), Vector2(800, 400), 
	]
	
	for i in range(8):
		newAttacks.append(spiritAttack.instantiate())
		newAttacks[i].timeToAttack = 0.5
		newAttacks[i].damage = attackDamage
		get_tree().current_scene.add_child(newAttacks[i])
		newAttacks[i].scale *= 0.85
		newAttacks[i].position = get_parent().position + moveVectors[i]
		
	inAttack = false
	get_parent().text.set_text("")
