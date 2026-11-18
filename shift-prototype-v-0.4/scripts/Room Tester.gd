extends Node2D

var Player=null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var objectList:=[]
	for i in $Objects.get_children():
		objectList.append({"Type":i.get_meta("ObjectName"),"Position":i.position})
	#print(","+str(objectList).replace("(","Vector2("))
