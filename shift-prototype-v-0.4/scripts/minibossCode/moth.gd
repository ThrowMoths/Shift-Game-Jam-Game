extends Area2D

var damage: float
var speed: float
var active: bool = true
var angle: float = true
var deleted: bool = false
 
var move: bool = false
var player: Object

var bounceCount: int = 0
var bounceCooldown: float = 0

func _ready() -> void:
	bounceCooldown = 0.2
	
func _process(delta: float) -> void:
	if move: position += Vector2(speed,0).rotated(angle) * delta
	
	bounceCooldown -= delta
	
	for body: Node2D in get_overlapping_bodies():
		if body.is_in_group("Player"):
			contact(body)
		if body.is_in_group("Wall") and !deleted:
			if bounceCooldown <= 0 and bounceCount == 0:
				call_deferred("queue_free")
			else:
				if bounceCooldown <= 0 and !body.name.contains("Trigger"):
					bounceCount -= 1
					bounceCooldown = 0.2
					bounce(body)

func toPlayer() -> void:
	angle = 0
	rotation = 0
	
	angle = self.get_angle_to(player.position)
	rotation = angle
	
func bounce(body: Node2D)-> void:
	var incoming: Vector2 = Vector2.from_angle(angle)
	var outgoing: Vector2 = incoming.bounce(normalVector(body))
	angle = outgoing.angle()
	rotation = angle
	
func normalVector(body: Node2D) -> Vector2:
	var bodyName = body.name
	if !bodyName.contains("Full"): bodyName = body.get_parent().name
	
	if bodyName.contains("Up"): return Vector2(0, 1)
	elif bodyName.contains("Down"): return Vector2(0, -1)
	elif bodyName.contains("Right"): return Vector2(-1, 0)
	else: return Vector2(1, 0)

func contact(body: Node2D) -> void:
	if active:
		if !body.dashing:
			body.take_damage(damage)
			body.take_knockback(Vector2(1500,0).rotated(angle))
		
		active = false
