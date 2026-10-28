extends RigidBody2D
class_name Box
@onready var left_collision_ray: RayCast2D = $LeftCollisionRay
@onready var right_collision_ray: RayCast2D = $RightCollisionRay


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _get_collision_normal() -> float:
	if left_collision_ray.is_colliding(): return 1.0
	elif right_collision_ray.is_colliding(): return -1.0
	else: return 0.0
