extends Area2D

var damage: float
var active: bool = true

func _ready() -> void:
	await get_tree().create_timer(0.25).timeout
	call_deferred("queue_free")

func _process(delta: float) -> void:
	modulate.a -= delta * 4
	
	for body: Node2D in get_overlapping_bodies():
		if body.is_in_group("Player"):
			contact(body)

func contact(body: Node2D) -> void:
	if active:
		if !body.dashing:
			body.take_damage(damage)
			body.take_knockback(Vector2(1500,0).rotated(rotation))
		
		active = false
