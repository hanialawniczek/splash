extends CharacterBody2D
class_name Rock


@export var gravity: float = 14000.0
@export var speed: float = 1000.0
@export var rotation_speed: float = 10.0
@onready var left_collision_ray: RayCast2D = $LeftCollisionRay
@onready var right_collision_ray: RayCast2D = $RightCollisionRay
var grabbed : bool = false
var player : Player = null
var near_player = false


func _input(event: InputEvent) ->  void:
	if event.is_action_pressed("use") and near_player:
		grabbed = true
		
	if event.is_action_released("use"):
		grabbed = false

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	if not near_player:
		grabbed = false
	_push_movement()
	_pull_movement()

	move_and_slide()
	align_with_slope(delta)
	
func align_with_slope(delta: float) -> void:
	if is_on_floor():
		# Get the normal vector of the collision surface (perpendicular to the slope)
		var floor_normal := get_floor_normal()
		
		# Calculate the target angle. 
		# In Godot, Vector2.UP is (0, -1). 
		# We find the angle between the default "up" and our current floor normal.
		var target_angle := Vector2.UP.angle_to(floor_normal)
		
		# Interpolate (lerp) to make the rotation smooth
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	else:
		# If in the air, gradually return to an upright position (optional)
		rotation = lerp_angle(rotation, 0.0, rotation_speed * delta)
	
	
func _push_movement() -> void:
	var direction = Input.get_axis("left", "right")
	if near_player and direction == _get_collision_normal() and direction != 0:
		velocity.x = speed * direction
		player.pushing = true
	else:
		velocity.x = 0.0
		if player:
			player.pushing = false
		
func _pull_movement() -> void:
	var direction = Input.get_axis("left", "right")
	if grabbed:
		velocity.x = speed * direction
		player.pushing = true



func _get_collision_normal() -> float:
	if player.left_collision_ray.is_colliding(): return -1.0
	elif player.right_collision_ray.is_colliding(): return 1.0
	else: return 0.0

	


func _on_detection_area_body_entered(body: Player) -> void:
	player = body
	near_player = true


func _on_detection_area_body_exited(body: Player) -> void:
	player.pushing = false
	player = null
	near_player = false
