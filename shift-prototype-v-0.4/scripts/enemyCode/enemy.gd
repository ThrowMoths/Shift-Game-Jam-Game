extends Area2D

# Health variables, self explanatory
var health: float
@export var maxHealth: float

# Enemy type instance
@export var type: EnemyTypeWrapper.Type

# Contact damage variable
@export var contactDamage: float = 5.0

# Don't worry much about the softcollider I used a tutorial for it, all it does is make sure enemies don't overlap
@onready var softCollider := $SoftCollider

# Invincibility flag so enemies don't immediately chase the enemy
@export var invincibilityTimer: float = 1.5
var invincibilityFlag: bool = true

# Internal reference to the player
var player: Object = null

# Velocities, top is sum of all
var velocity: Vector2 = Vector2.ZERO
var knockbackVelocity:Vector2 = Vector2.ZERO
var moveVelocity:Vector2 = Vector2.ZERO
# Soft Coll Velocity stops enemies overlapping
var softCollVelocity:Vector2=Vector2.ZERO

# Recieved knockback multiplier
@export var knockbackMulti: float = 1.0

# Makes sure death calls arent done twice for an enemy
var deathEmitted: bool = false

func _ready() -> void:
	health = maxHealth
	
func _physics_process(delta: float) -> void:
	# Uses a boolean for the invincibility calculations
	if invincibilityFlag:
		invincibilityTimer -= delta
		if invincibilityTimer <= 0.0:
			invincibilityFlag = false
	
	# Blinking effect on invincibility
	if invincibilityFlag:
		modulate.a = 0.6+0.4*int(floori(invincibilityTimer*10)%3>1)
	else:
		modulate.a = 1
	
	# Updates the position of the light pink transition healthbar
	$"Health Outline/Health Lerp".set_point_position(1,Vector2(lerp($"Health Outline/Health Lerp".get_point_position(1).x, -100+health/maxHealth*200,3*delta),0))
	
	# Colour is always moving towards the base
	modulate = lerp(modulate,Color(1,1,1), delta * 2)
	
	# Like i said don't worry about this, just don't touch it probably
	if softCollider.is_colliding():
		softCollider.get_push_vector()
		#print(softCollider.get_push_vector())
		softCollVelocity+=softCollider.get_push_vector()*delta*500
	else:
		softCollVelocity=Vector2.ZERO
	
	# Fetches player object from the current scene
	player = get_tree().current_scene.Player
	
	# Fetches bodies in order to do damage to them and knockback
	for body: Node2D in get_overlapping_bodies():
		if body.is_in_group("Player"):
			contact(body)
	
	# Combines velocity vectors linearly
	velocity = knockbackVelocity + moveVelocity + softCollVelocity
	# Knockback slowly returns to zero
	knockbackVelocity = knockbackVelocity.move_toward(Vector2(0,0), 3500*delta)
	
	# Enemy only moves if invincibility flag is disabled
	if !invincibilityFlag:
		position += velocity * delta

func take_damage(damage: float) -> void:
	if !invincibilityFlag:
		health -= damage
		
		# Doesn't do anything at the moment, but could be used later
		# emit_signal("hit")
	
	if health <= 0 and !deathEmitted:
		# Tells scene that the enemy has died so it can check if the doors can open
		get_tree().current_scene.enemy_died()
		
		# Sets death flag
		deathEmitted = true
		
		# Deletes self
		call_deferred("queue_free")	

		
	# Adds a red highlight to the enemy, this is why the colour is always moving towards (1,1,1) to counteract this
	modulate = Color(1,0,0)
	
	# Updates the position of the main health bar
	$"Health Outline/Health".set_point_position(1,Vector2(-100+health/maxHealth*200,0))

# Sets knockback vector
func take_knockback(vector: Vector2) -> void:
	knockbackVelocity = vector * knockbackMulti

# Deals contact damage to the player if not invincible 
func contact(body: Node2D) -> void:
	# Enemies are knocked back after contacting the player
	take_knockback(Vector2(1,0).rotated(self.get_angle_to(player.position)).normalized() * -1500)
	
	if !invincibilityFlag:
		if body.dashing == false:
			player.take_damage(contactDamage)
		else:
			if type == EnemyTypeWrapper.Type.MONSTER:
				take_damage(body.dashDamage)
