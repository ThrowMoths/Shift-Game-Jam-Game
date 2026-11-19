extends CharacterBody2D


const SPEED = 800.0
const JUMP_VELOCITY = -400.0
var shiftMode="1"
var attackDelay:=0.0
var health:=100.0
var maxHealth:=100.0
var dashing :=false
var dashDirection:=Vector2.ZERO
var dashDamage:=6.0
var dashSpeed:=2000.0
var invincibility:=0.3
var abilityCooldown:=0.0
var buffed:=false
var knockbackVelocity: Vector2 = Vector2.ZERO
@export var knockbackMulti: float = 1.0

@onready var testAttack:=preload("res://scenes/Player Attack.tscn")
@onready var waterAttack:=preload("res://scenes/Holy Water Bottle.tscn")
@onready var meleeAttack:=preload("res://scenes/Player Melee Attack.tscn")
@onready var blessedArea:=preload("res://scenes/Blessed Area.tscn")
func _ready() -> void:
	switch_mode("1")

func _physics_process(delta: float) -> void:
	attackDelay-=delta
	abilityCooldown-=delta
	invincibility-=delta
	var direction := Vector2(Input.get_axis("ui_left", "ui_right"),Input.get_axis("ui_up","ui_down")).normalized()
	if direction:
		velocity = (direction * SPEED)*(1+0.8*int(buffed))
		
	else:
		velocity *=0
	
	velocity += knockbackVelocity
	knockbackVelocity = knockbackVelocity.move_toward(Vector2(0,0), 3500*delta)
		
	if dashing:
		velocity=dashSpeed*dashDirection
	
	
	move_and_slide()

	if Input.is_action_just_pressed("Shift"):
		match shiftMode:
			"1":
				switch_mode("2")
			"2":
				switch_mode("3")
			"3":
				switch_mode("1")
	if Input.is_action_pressed("Left Click") and attackDelay<=0:
		attack()
	if Input.is_action_just_pressed("Right Click") and abilityCooldown<=0:
		ability()
	
	if Input.is_action_just_pressed("1"):
		switch_mode("1")
	if Input.is_action_just_pressed("2"):
		switch_mode("2")
	if Input.is_action_just_pressed("3"):
		switch_mode("3")
		
	
func switch_mode(newMode):
	match newMode:
		"1":
			shiftMode="1"
			$Sprite2D.texture=load("res://assets/icon.svg")
			
			modulate=Color(1,0,0)
		"2":
			shiftMode="2"
			$Sprite2D.texture=load("res://assets/icon.svg")
			
			modulate=Color(0,1,0)
		"3":
			shiftMode="3"
			$Sprite2D.texture=load("res://assets/icon.svg")
			modulate=Color(0,0,1)
func attack():
	match shiftMode:
		"1":
			attackDelay=0.5
			var newAttack:=meleeAttack.instantiate()
			newAttack.rotation=get_angle_to(get_global_mouse_position())
			newAttack.type=shiftMode
			if buffed:
				newAttack.damage*=1.5
			get_tree().current_scene.add_child(newAttack)
			newAttack.position=position
			
		"2":
			attackDelay=1.0
			var newAttack:=waterAttack.instantiate()
			newAttack.angle=get_angle_to(get_global_mouse_position())
			newAttack.type=shiftMode
			if buffed:
				newAttack.damage*=1.5
			get_tree().current_scene.add_child(newAttack)
			newAttack.position=position
			
			
		"3":
			attackDelay=0.1
			var newAttack:=testAttack.instantiate()
			newAttack.angle=get_angle_to(get_global_mouse_position())+randf_range(-1.5,1.5)
			newAttack.type=shiftMode
			if buffed:
				newAttack.damage*=1.5
			get_tree().current_scene.add_child(newAttack)
			newAttack.position=position

func take_damage(damage):
	if invincibility<=0:
		health-=damage*(1-0.5*int(buffed))
		invincibility=1.0
		
	if health<=0:
		if get_tree():
			get_tree().reload_current_scene()
	else:
		get_tree().current_scene.damage_taken()
	
func ability():
	match shiftMode:
		"1":
			abilityCooldown=1.0
			dashing=true
			dashDirection=Vector2(Input.get_axis("ui_left", "ui_right"),Input.get_axis("ui_up","ui_down")).normalized()
			await get_tree().create_timer(0.3).timeout
			dashing=false
		"2":
			abilityCooldown=3.0
			var newArea=blessedArea.instantiate()
			get_tree().current_scene.add_child(newArea)
			newArea.position=position
		"3":
			abilityCooldown=2.0
			get_tree().call_group("Wizard Attack","explode")

func take_knockback(vector: Vector2) -> void:
	knockbackVelocity = vector * knockbackMulti
