extends Area2D

var damage: float
var timeToAttack: float
var active: bool = false
var doScale: bool = false

func _ready() -> void:
	modulate = Color(0, 0, 0)
	await get_tree().create_timer(timeToAttack).timeout
	modulate = Color(1, 1, 1)
	active = true
	await get_tree().create_timer(0.5).timeout
	call_deferred("queue_free")

func _process(delta: float) -> void:
	if active: 
		modulate.a -= delta * 2
		if doScale: scale += Vector2(0.02, 0.02)
	
		for body: Node2D in get_overlapping_bodies():
			if body.is_in_group("Player"):
				contact(body)

func contact(body: Node2D) -> void:
	if !body.dashing:
		body.take_damage(damage)
