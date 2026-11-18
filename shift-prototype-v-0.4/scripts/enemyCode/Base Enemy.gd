extends Area2D

var health:=10.0
var maxHealth:=10.0
#Self Explanatory, used for health bars and damage and such

@export var type:="2"
# Changes the type of damage they respond to "1" is the knight, "2" is the nun and "3" is the witch, feel free to change this
@export var contactDamage:=20.0
#The damage the player takes if they walk into an enemy, could be set to lower values for ranged enemies

@onready var softCollider:=$SoftCollider
#Don't worry much about the softcollider I used a tutorial for it, all it does is make sure enemies don't overlap

var invincibility:=1.0
#Enemies are invincible for a second when they spawn but dont move to give the player a chance to react

var Player:Object=null
#Internal reference to the player making it easier to read and more memory efficient

var velocity:Vector2=Vector2.ZERO
#sum total of all velocities

var knockbackVelocity:Vector2=Vector2.ZERO
#velocity from knockback taken

var moveVelocity:Vector2=Vector2.ZERO
#velocity from behaviours e.g chasing

var softCollVelocity:Vector2=Vector2.ZERO
#pushes enemies away when they get too close to each other

@export var knockbackMulti:=1.0
#multiplies knockback taken

var deathEmitted=false
#makes sure death calls arent done twice for an enemy

# Called when the node enters the scene tree for the first time.

func _physics_process(delta: float) -> void:
	invincibility-=delta
	
	if invincibility>=0:
		modulate.a=0.6+0.4*int(floori(invincibility*10)%3>1)
	else:
		modulate.a=1
	#this causes the blinking effect


	$"Health Outline/Health Lerp".set_point_position(1,Vector2(lerp($"Health Outline/Health Lerp".get_point_position(1).x, -100+health/maxHealth*200,3*delta),0))
	#updates the position of the light pink transition healthbar
	
	modulate=lerp(modulate,Color(1,1,1),delta*2)
	#Colour is always moving towards the base
	
	if softCollider.is_colliding():
		softCollider.get_push_vector()
		#print(softCollider.get_push_vector())
		softCollVelocity+=softCollider.get_push_vector()*delta*500
	else:
		softCollVelocity=Vector2.ZERO
	#Like i said don't worry about this, just don't touch it probably
	
	Player = get_tree().current_scene.Player
	
	
	velocity=knockbackVelocity+moveVelocity+softCollVelocity
	knockbackVelocity= knockbackVelocity.move_toward(Vector2(0,0),3500*delta)
	#knockback velocity is always trying to go back to zero
	
	if invincibility<=0:
		position+=velocity*delta
	#only moves if the enemy isnt invincible
	
	
	

func take_damage(Damage):
	if invincibility<=0:
		health -= Damage
		emit_signal("hit")
		#this signal isnt used by anything by default but could be connected to the behaviour to do some things
	
	if health <= 0 and !deathEmitted:
		get_tree().current_scene.enemy_died()
		#tells the scene and by extension the room that its dead so it can check if it should open the room again
		
		call_deferred("queue_free")
		#deletes itself
		deathEmitted=true
		

		
	modulate=Color(1,0,0)
	#adds a red highlight to the enemy, this is why the colour is always moving towards (1,1,1) to counteract this
	
	$"Health Outline/Health".set_point_position(1,Vector2(-100+health/maxHealth*200,0))
	#updates the position of the main health bar
func take_knockback(vector):
	knockbackVelocity=vector*knockbackMulti
#adds knockback

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and invincibility<=0:
		if body.dashing==false:
			Player.take_damage(contactDamage)
		else:
			if type=="1":
				take_damage(body.dashDamage)
#deals contact damage to the player if not invincible 
