extends Area2D

var damage: float
var speed: float
var active: bool = true
var angle: float = true
var deleted: bool = false

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	position += Vector2(speed,0).rotated(angle) * delta
	
	for body: Node2D in get_overlapping_bodies():
		if body.is_in_group("Player"):
			contact(body)
		if !deleted:
			call_deferred("queue_free")

func contact(body: Node2D) -> void:
	if active:
		if !body.dashing:
			body.take_damage(damage)
			body.take_knockback(Vector2(1500,0).rotated(angle))
		
		active = false
