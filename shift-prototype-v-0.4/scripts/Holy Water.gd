extends Area2D

var angle:=0.0
var speed:=1500.0
var type: TypeWrapper.Type = TypeWrapper.Type.NUN
var damage=3
@onready var holyPool:=preload("res://scenes/Holy Water Pool.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.rotation=angle
	await get_tree().create_timer(1.0).timeout
	break_flask()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position+=Vector2(speed,0).rotated(angle)*delta
	speed-=delta*1000
	
	

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		if area.type == EnemyTypeWrapper.Type.UNHOLY:
			area.take_damage(damage)
		break_flask()
func break_flask():
	var newHolyPool:=holyPool.instantiate()
	get_tree().current_scene.add_child(newHolyPool)
	newHolyPool.position=position
	call_deferred("queue_free")


func _on_body_entered(body: Node2D) -> void:
	#print("hi")
	if body.is_in_group("Wall"):
		break_flask()
