extends Area2D

var damage: float
var active: bool = true
var travel: bool = false
var travelSpeed: Vector2 = Vector2(15, 0)

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	call_deferred("queue_free")

func _process(delta: float) -> void:
	modulate.a -= delta * 2
	
	for body: Node2D in get_overlapping_bodies():
		if body.is_in_group("Player"):
			contact(body)
	
	if travel:
		position += travelSpeed.rotated(rotation)

func contact(body: Node2D) -> void:
	if active:
		if !body.dashing:
			body.take_damage(damage)
			body.take_knockback(Vector2(1500,0).rotated(rotation))
		
		active = false
