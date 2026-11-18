extends Area2D

var damage:=1
var damageTimer:=0.1
var type: TypeWrapper.Type = TypeWrapper.Type.WITCH

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#scale=Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	modulate.a-=delta*2
	scale=Vector2(scale.x+delta*4,scale.y+delta*4)
	if modulate.a<=0:
		call_deferred("queue_free")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		if area.type == TypeWrapper.Type.NUN:
			area.take_damage(damage)
