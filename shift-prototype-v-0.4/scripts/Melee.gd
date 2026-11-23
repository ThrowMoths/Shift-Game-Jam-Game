extends Area2D

var damage:=4.0
var type: TypeWrapper.Type = TypeWrapper.Type.KNIGHT
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.25).timeout
	call_deferred("queue_free")
	

func _process(delta: float) -> void:
	modulate.a-=delta*4

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		if area.type == EnemyTypeWrapper.Type.MONSTER:
			get_tree().current_scene.hit_stop(0.15,0.1)

			area.take_damage(damage)
			area.take_knockback(Vector2(1500,0).rotated(rotation))
			
