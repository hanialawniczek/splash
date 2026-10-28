class_name MoveComponent
extends Node

@export var gravity: float = 14000.0
@export var speed: float = 1000.0
@export var rotation_speed: float = 10.0
@onready var parent: CharacterBody2D = get_parent()

@onready var left_collision_ray: RayCast2D = $"../LeftCollisionRay"
@onready var right_collision_ray: RayCast2D = $"../RightCollisionRay"

var grabbed : bool = false
var player : Player = null

func _input(event: InputEvent) ->  void:
	if event.is_action_pressed("use") and _is_interactable():
		grabbed = true
		
	if event.is_action_released("use") and grabbed:
		grabbed = false

func _physics_process(delta: float) -> void:
	
	_apply_gravity(delta)
	_push_movement()
	_pull_movement()
	parent.move_and_slide()
	align_with_slope(delta)
	print(grabbed)
	
func align_with_slope(delta: float) -> void:
	if parent.is_on_floor():
		# Get the normal vector of the collision surface (perpendicular to the slope)
		var floor_normal := parent.get_floor_normal()
		
		# Calculate the target angle. 
		# In Godot, Vector2.UP is (0, -1). 
		# We find the angle between the default "up" and our current floor normal.
		var target_angle := Vector2.UP.angle_to(floor_normal)
		
		# Interpolate (lerp) to make the rotation smooth
		parent.rotation = lerp_angle(parent.rotation, target_angle, rotation_speed * delta)
	else:
		# If in the air, gradually return to an upright position (optional)
		parent.rotation = lerp_angle(parent.rotation, 0.0, rotation_speed * delta)
	
func _apply_gravity(delta : float) -> void:
	if not parent.is_on_floor():
		parent.velocity.y += gravity * delta
	
func _push_movement() -> void:
	var direction = Input.get_axis("left", "right")
	if direction == _get_collision_normal() and direction:
		parent.velocity.x = speed * direction
	else:
		parent.velocity.x = 0.0
		
func _pull_movement() -> void:
	var direction = Input.get_axis("left", "right")
	if grabbed:
		parent.velocity.x = speed * direction


func _get_collision_normal() -> float:
	if left_collision_ray.is_colliding(): return 1.0
	elif right_collision_ray.is_colliding(): return -1.0
	else: return 0.0
	
func _is_interactable() -> bool:
	return left_collision_ray.is_colliding() or right_collision_ray.is_colliding()
	
func _get_collider() -> Player:
	for ray in [left_collision_ray, right_collision_ray]:
		if ray.is_colliding() and ray.get_collider() is Player:
			return ray.get_collider()
	return null
