extends RigidBody2D
class_name Platform
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
const ROTATION_SPEED = 0.01
var width
var height
var with_player = false
var deafult_position

func _ready() -> void:
	width = collision_shape.shape.size.x
	height = collision_shape.shape.size.y
	

func _process(_delta: float) -> void:
	if !with_player:
		global_position = lerp(global_position, deafult_position, ROTATION_SPEED)
		rotation = lerp(rotation, 0.0, ROTATION_SPEED)
	pass

func _on_area_2d_body_entered(body: Player) -> void:
	with_player = true


func _on_area_2d_body_exited(body: Player) -> void:
	with_player = false
