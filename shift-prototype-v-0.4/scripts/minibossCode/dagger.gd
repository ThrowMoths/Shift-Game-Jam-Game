extends Area2D

var damage: float
var speed: float
var active: bool = true
var angle: float = true
var deleted: bool = false
 
var move: bool = false
var surrounding: bool = false
var targetPos: Vector2

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if move: position += Vector2(speed,0).rotated(angle) * delta
	if surrounding:
		active = false
		surround(delta)
	
	for body: Node2D in get_overlapping_bodies():
		if body.is_in_group("Player"):
			contact(body)
		#if body.is_in_group("Wall") and !deleted:
			#call_deferred("queue_free")
			
func surround(delta: float) -> void:
	if (position.distance_to(targetPos)) >= 20:
		position += Vector2(2000, 0).rotated(self.get_angle_to(targetPos) - rotation) * delta

func contact(body: Node2D) -> void:
	if active:
		if !body.dashing:
			body.take_damage(damage)
			body.take_knockback(Vector2(1500,0).rotated(angle))
		
		active = false
