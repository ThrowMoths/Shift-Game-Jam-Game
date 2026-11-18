extends Node2D

var Player:Object=null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	Player=get_parent().Player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Player:
		get_parent().moveVelocity=Vector2(500,0).rotated(self.get_angle_to(Player.position))
