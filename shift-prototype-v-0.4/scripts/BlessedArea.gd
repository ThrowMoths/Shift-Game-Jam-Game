extends Area2D

var damage:=1
var damageTimer:=0.1
var type: TypeWrapper.Type = TypeWrapper.Type.NUN
var enteredEnemies:=[]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	damageTimer-=delta
	if damageTimer<=0:
		damageTimer=0.1
		for i in enteredEnemies:
			if i.type== TypeWrapper.Type.KNIGHT:
				i.take_damage(damage)
	modulate.a-=delta*0.5
	if modulate.a<=0:
		call_deferred("queue_free")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		enteredEnemies.append(area)


func _on_area_exited(area: Area2D) -> void:
	if area in enteredEnemies:
		
		enteredEnemies.erase(area)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.buffed=true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.buffed=false
