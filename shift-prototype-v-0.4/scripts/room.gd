extends Node2D

var coords:=Vector2i(0,0)
var type:="Blank"
var closed:=false
var roomEntered=false
@onready var testObject:=preload("res://scenes/testObject.tscn")
@onready var secondTestObject:=preload("res://scenes/secondTestObject.tscn")

@onready var knightAttacker := preload("res://scenes/enemies/KnightAttackerEnemy.tscn")
@onready var nunAttacker := preload("res://scenes/enemies/NunAttackerEnemy.tscn")
@onready var witchAttacker := preload("res://scenes/enemies/WitchAttackerEnemy.tscn")


var roomEnemies:=[]
var currEnemies:=[]
var enemiesLeft:=0
var normalRooms:=[
	[{ "Type": "Knight Attacker", "Position": Vector2(-479.0, -32.0) }, { "Type": "Test2", "Position": Vector2(-134.0, -84.0) }, { "Type": "Test", "Position": Vector2(-139.0, 92.0) }, { "Type": "Test", "Position": Vector2(112.0, -78.0) }, { "Type": "Test2", "Position": Vector2(112.0, 98.0) }]
	,[{ "Type": "Knight Attacker", "Position": Vector2(-115.0, 78.0) }, { "Type": "Knight Attacker", "Position": Vector2(100.0, 90.0) }, { "Type": "Nun Attacker", "Position": Vector2(915.0, -414.0) }, { "Type": "Witch Attacker", "Position": Vector2(-886.0, -414.0) }, { "Type": "Test2", "Position": Vector2(-134.0, -84.0) }, { "Type": "Test2", "Position": Vector2(112.0, -87.0) }]
	,[{ "Type": "Test Enemy", "Position": Vector2(-154.0, -439.0) }, { "Type": "Test Enemy", "Position": Vector2(362.0, 345.0) }, { "Type": "Test Enemy", "Position": Vector2(-479.0, -32.0) }, { "Type": "Test2", "Position": Vector2(-134.0, -84.0) }, { "Type": "Test2", "Position": Vector2(112.0, 98.0) }]
	,[{ "Type": "Test Enemy", "Position": Vector2(-886.0, 420.0) }, { "Type": "Test Enemy", "Position": Vector2(915.0, 420.0) }, { "Type": "Test Enemy", "Position": Vector2(915.0, -414.0) }, { "Type": "Test Enemy", "Position": Vector2(-886.0, -414.0) }, { "Type": "Test2", "Position": Vector2(-134.0, -84.0) }, { "Type": "Test2", "Position": Vector2(112.0, 98.0) }]
]


func _ready() -> void:
	await get_tree().process_frame
	generate_doors()
	toggle_doors(true)
	if type=="Exit!":
		z_index=3
		modulate=Color(1,0,0)
	if type=="Gifts":
		z_index=3
		modulate=Color(1,1,0)
	if type=="Start":
		z_index=3
		modulate=Color(0,1,0)
		roomEntered=true
	if type=="Blank":
		generate_room(normalRooms)
func generate_room(possibleRooms:Array):
	var room = possibleRooms.pick_random()
	for object in room:
		var newObject=null
		match object["Type"]:
			"Test":
				newObject=testObject.instantiate()
			"Test2":
				newObject=secondTestObject.instantiate()
			"Test Enemy":	
				roomEnemies.append({"Enemy":knightAttacker,"Position":object["Position"]})
			"Knight Attacker":	
				roomEnemies.append({"Enemy":knightAttacker,"Position":object["Position"]})
			"Nun Attacker":	
				roomEnemies.append({"Enemy":nunAttacker,"Position":object["Position"]})
			"Witch Attacker":	
				roomEnemies.append({"Enemy":witchAttacker,"Position":object["Position"]})
		if newObject:
			add_child(newObject)
			newObject.position=object["Position"]
	

func toggle_doors(mode):
	if mode:
		if $"Part Right":
			$"Part Right/Door/CollisionShape2D".set_deferred("disabled",true)
			$"Part Right/Door".visible=false
		if $"Part Left":
			$"Part Left/Door2/CollisionShape2D".set_deferred("disabled",true)
			$"Part Left/Door2".visible=false
		if $"Part Up":
			$"Part Up/Door4/CollisionShape2D".set_deferred("disabled",true)
			$"Part Up/Door4".visible=false
		if $"Part Down":
			$"Part Down/Door3/CollisionShape2D".set_deferred("disabled",true)
			$"Part Down/Door3".visible=false
	else:
		
		if $"Part Right":

			$"Part Right/Door/CollisionShape2D".set_deferred("disabled",false)
			$"Part Right/Door".visible=true
		if $"Part Left":
			$"Part Left/Door2/CollisionShape2D".set_deferred("disabled",false)
			$"Part Left/Door2".visible=true
		if $"Part Up":
			
			$"Part Up/Door4/CollisionShape2D".set_deferred("disabled",false)
			$"Part Up/Door4".visible=true
		if $"Part Down":
			$"Part Down/Door3/CollisionShape2D".set_deferred("disabled",false)
			$"Part Down/Door3".visible=true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if roomEntered:
			closed=!closed
			toggle_doors(closed)

func generate_doors():
	var grid:Array=get_tree().current_scene.grid

	if coords.x<6:
		if grid[coords.y][coords.x+1]!="Empty":
			$"Full Right".queue_free()
		else:
			$"Part Right".queue_free()
	if coords.x>0:
		if grid[coords.y][coords.x-1]!="Empty":
			$"Full Left".queue_free()
		else:
			$"Part Left".queue_free()
	if coords.y<6:
		if grid[coords.y+1][coords.x]!="Empty":
			$"Full Down".queue_free()
		else:
			$"Part Down".queue_free()
	if coords.y>0:
		if grid[coords.y-1][coords.x]!="Empty":
			$"Full Up".queue_free()
		else:
			$"Part Up".queue_free()




func _on_right_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		entered()

func _on_left_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		entered()

func _on_down_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		entered()

func _on_up_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		entered()

func entered():
	
	get_tree().current_scene.room_entered(self)
	if !roomEntered and type=="Blank":
		roomEntered=true
		toggle_doors(false)
		#print(roomEnemies)
		for enemy in roomEnemies:
			var newEnemy = enemy["Enemy"].instantiate()
			get_tree().current_scene.add_child(newEnemy)
			newEnemy.position=global_position+enemy["Position"]
			currEnemies.append(newEnemy)
			enemiesLeft+=1

func enemy_died():
	enemiesLeft-=1
	if enemiesLeft==0:
		toggle_doors(true)
