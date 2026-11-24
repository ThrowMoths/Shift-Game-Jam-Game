extends Node2D

var grid:=[]
var roomCount:=10
var currRoomCount:=0
var rooms:=[]
var valid=true
@onready var currRoom:Object
@onready var room:=preload("res://scenes/Room.tscn")
@onready var Player=$Player
@onready var camera = $Camera2D

func _ready() -> void:
	make_floor()


func _process(delta: float) -> void:
	$"Camera2D/Node2D/Health Lerp".set_point_position(1,Vector2(lerp($"Camera2D/Node2D/Health Lerp".get_point_position(1).x, -500+Player.health/Player.maxHealth*1000,5*delta),0))
	if Input.is_action_just_pressed("ui_cut"):
		get_tree().reload_current_scene()
	if currRoom!=null:
		$Camera2D.position = $Camera2D.position.move_toward(currRoom.position,3000*delta)
func make_floor():
	valid=true
	rooms=[]
	currRoomCount=0
	grid=[]
	for i in range(7):
		grid.append([])
		for ii in range(7):
			grid[i].append("Empty")
	grid[3][3]="Start"

	create_neighbours(Vector2i(3,3))
	rooms.append({"RoomType":"Start","RoomPos":Vector2i(3,3)})
	if currRoomCount<8:
		valid=false
	var specialRooms=special_rooms()
	#print("special rooms:",specialRooms)
	var exit=specialRooms.pop_at(randi_range(0,specialRooms.size()-1))
	if exit!=null:
		grid[exit["RoomPos"].y][exit["RoomPos"].x]="Exit!"
	var gifts=specialRooms.pop_at(randi_range(0,specialRooms.size()-1))
	if gifts!=null:
		grid[gifts["RoomPos"].y][gifts["RoomPos"].x]="Gifts"
	
	
	#print(rooms)
	if valid:
		for i in range(7):
			for ii in range(7):
				if grid[i][ii]!="Empty":
					var newRoom:=room.instantiate()
					add_child(newRoom)
					newRoom.position=Vector2((ii-3)*1152*2,(i-3)*648*2)
					newRoom.coords=Vector2i(ii,i)
					newRoom.type=grid[i][ii]
					if grid[i][ii]=="Start":
						room_entered(newRoom)
	else:
		make_floor()

func special_rooms():
	var special_rooms=[]
	for i in (rooms):
		#print(i["RoomPos"])
		#print(edge_count(i["RoomPos"]))
		
		if edge_count(i["RoomPos"])==3 :
			
			if i["RoomPos"].x<2 or i["RoomPos"].x>4 or i["RoomPos"].y<2 or i["RoomPos"].y>4 :
				special_rooms.append(i)
	if special_rooms.size()<2 :
		valid=false
	return special_rooms
		
func edge_count(gridPos):
	var count=0
	
	if gridPos.y<6:
		if grid[gridPos.y+1][gridPos.x]=="Empty":
			count+=1
	else:
		count+=1
	if gridPos.y>0:
		
		if grid[gridPos.y-1][gridPos.x]=="Empty":
			count+=1
			
	else:
		count+=1
	if gridPos.x<6:
		if grid[gridPos.y][gridPos.x+1]=="Empty":
			count+=1
			
	else:
		count+=1
	if gridPos.x>0:
		if grid[gridPos.y][gridPos.x-1]=="Empty":
			count+=1
	else:
		count+=1
			
	return count
	
func farthest_room(coords:=Vector2i(3,3)):
	var furthest=rooms[0]
	var highestDistance:=0
	for i in rooms:
		if abs(i["RoomPos"].x-coords.x)+abs(i["RoomPos"].y-coords.y)>=highestDistance:
			furthest=i
			highestDistance=abs(i["RoomPos"].x-coords.x)+abs(i["RoomPos"].y-coords.y)
	return furthest

func create_neighbours(roomCoords):
	var potentialRooms:=[]
	var roomProb:=0.4
	if randf()<roomProb and roomCoords.y>0:
		if grid[roomCoords.y-1][roomCoords.x]=="Empty":
			grid[roomCoords.y-1][roomCoords.x]="Blank"
			rooms.append({"RoomType":grid[roomCoords.y-1][roomCoords.x],"RoomPos":roomCoords+Vector2i(0,-1)})
			if currRoomCount<roomCount:
				potentialRooms.append(Vector2i(roomCoords.x,roomCoords.y-1))

	if randf()<roomProb and roomCoords.y<6:
		if grid[roomCoords.y+1][roomCoords.x]=="Empty":
			grid[roomCoords.y+1][roomCoords.x]="Blank"
			rooms.append({"RoomType":grid[roomCoords.y+1][roomCoords.x],"RoomPos":roomCoords+Vector2i(0,1)})
			if currRoomCount<roomCount:
				potentialRooms.append(Vector2i(roomCoords.x,roomCoords.y+1))

	if randf()<roomProb and roomCoords.x>0:
		if grid[roomCoords.y][roomCoords.x-1]=="Empty":
			grid[roomCoords.y][roomCoords.x-1]="Blank"
			rooms.append({"RoomType":grid[roomCoords.y][roomCoords.x-1],"RoomPos":roomCoords+Vector2i(-1,0)})
			if currRoomCount<roomCount:
				potentialRooms.append(Vector2i(roomCoords.x-1,roomCoords.y))

	if randf()<roomProb and roomCoords.x<6:
		if grid[roomCoords.y][roomCoords.x+1]=="Empty":
			grid[roomCoords.y][roomCoords.x+1]="Blank"
			rooms.append({"RoomType":grid[roomCoords.y][roomCoords.x+1],"RoomPos":roomCoords+Vector2i(1,0)})
			if currRoomCount<roomCount:
				potentialRooms.append(Vector2i(roomCoords.x+1,roomCoords.y))
	for i in potentialRooms:
		currRoomCount+=1
		if currRoomCount<=roomCount:
			
			create_neighbours(i)
			
			
#func print_grid():
	#for i in range(7):
		#print(grid[i])
		
		
func room_entered(room):
	currRoom=room
	$Camera2D/Polygon2D.room_revealed(room.coords,room.type)
func enemy_died():
	currRoom.enemy_died()
func hit_stop(duration,strength):
	Engine.time_scale=strength
	await get_tree().create_timer(duration,true,false,true).timeout
	Engine.time_scale=1

func damage_taken():
	$"Camera2D/Node2D/Health".set_point_position(1,Vector2(-500+Player.health/Player.maxHealth*1000,0))
