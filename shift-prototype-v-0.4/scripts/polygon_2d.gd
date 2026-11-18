extends Polygon2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(7):
		for ii in range(7):
			get_child(i).get_child(ii).visible=false

func _process(delta: float) -> void:
	if global_position.distance_to(get_tree().current_scene.Player.position)<500:
		modulate.a=0.4
	else:
		modulate.a=1.0

func room_revealed(coords,type):
	get_child(coords.y).get_child(coords.x).visible=true
	$Sprite2D.global_position=get_child(coords.y).get_child(coords.x).global_position
	match type:
		"Start":
			get_child(coords.y).get_child(coords.x).modulate=Color(0,1,0)
		"Exit!":
			get_child(coords.y).get_child(coords.x).modulate=Color(1,0,0)
		"Gifts":
			get_child(coords.y).get_child(coords.x).modulate=Color(1,1,0)
