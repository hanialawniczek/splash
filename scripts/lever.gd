extends RigidBody2D
class_name Lever
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const ROTATION_SPEED = 0.1
var width
var with_player = false
var deafult_position
@onready var parent = get_parent()
@onready var tilt_force: float = parent.tilt_force
@onready var right_max_rotation: float = parent.right_max_rotation
@onready var left_max_rotation: float = parent.left_max_rotation

func _ready() -> void:
	width = collision_shape.shape.size.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !with_player:
		#if rotation_degrees >= right_max_rotation :
			#rotation_degrees -= ROTATION_SPEED
		#elif rotation_degrees <= left_max_rotation :
			#rotation_degrees += ROTATION_SPEED
		rotation = lerp(rotation, 0.0, ROTATION_SPEED)
	
	pass
	
