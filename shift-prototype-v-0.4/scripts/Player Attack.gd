extends Area2D

var angle:=0.0
var speed:=1000.0
var type:="2"
var damage=0.2
@onready var damageWave:=preload("res://scenes/Damage Wave.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	match type:
		
		"1":
			modulate=Color(1,0,0)
		"2":
			modulate=Color(0,1,0)
		"3":
			modulate=Color(0,0,1)
	await get_tree().create_timer(3).timeout
	call_deferred("queue_free")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Sprite2D.rotation=angle
	if angle>PI:
		angle-=PI*2
	if angle<-PI:
		angle+=PI*2
	
	var targetAngle=0

	targetAngle=self.get_angle_to(get_global_mouse_position())-angle
	
	if targetAngle>PI:
		targetAngle-=PI*2
	if targetAngle<-PI:
		targetAngle+=PI*2
	
	position+=Vector2(speed,0).rotated(angle)*delta
	
	angle=move_toward(angle,angle+targetAngle,2.5*PI*delta)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		if area.type==type:
			area.take_damage(damage)

func explode():
	await get_tree().create_timer(randf_range(0,0.8)).timeout
	var newWave:=damageWave.instantiate()
	get_tree().current_scene.add_child(newWave)
	newWave.position=position
	call_deferred("queue_free")
