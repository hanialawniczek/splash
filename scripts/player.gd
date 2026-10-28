extends CharacterBody2D
class_name Player
@onready var camera: Camera2D = $Camera2D
@onready var player_sprite: Sprite2D = $Sprite
@onready var dash_timer: Timer = $DashTimer
@onready var dash_again_timer: Timer = $DashAgainTimer
@onready var climb_again_timer: Timer = $ClimbAgainTimer
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var coyote_wall_jump_timer: Timer = $CoyoteWallJumpTimer
@onready var wall_jump_again_timer: Timer = $WallJumpAgainTimer
@onready var left_collision_ray: RayCast2D = $LeftCollisionRay
@onready var right_collision_ray: RayCast2D = $RightCollisionRay


#movement
const SPEED = 4000.0
const ROTATION_SPEED: float = 10.0
const DASH_SPEED = 8000.0
const ACCELERATION = 200
const ACCELERATION2 = 0.07 #second version
var dash_count = 0
var dashing = false
var can_dash = true
enum States { NORMAL, CLIMBING }
var current_state: States = States.NORMAL

#climbing
const CLIMB_SPEED = 5
const SWING_HORIZONTAL_FORCE = 400.0
const LEAVING_ROPE_SWING_X = 6000
const LEAVING_ROPE_SWING_Y = 6000
const PASSIVE_SWING = 0.3
var can_climb = false
var attached_rope_part_id : int = -INF
var attached_rope : Object = null
var rope_section_progress := 0.0

#jumping and fallling
const JUMP_VELOCITY = -7500.0
const MAX_VELOCITY = 12000.0
const FALL_MULTIPLIER = 1.5
const FAST_FALL_SPEED = 500
const MAX_HEIGHT_MULTIPLIER = 0.7
const MAX_HEIGHT_SPEED_UP = 400
const MAX_HEIGHT_SPEED_DOWN = 200
var jump_count = 0

#wall jump
const WALL_SLIDE_MAX_VELOCITY = 2000
const WALL_SLIDE_MULTIPLIER = 0.5
const WALL_JUMP_PUSHBACK = 3000
const WALL_JUMP_VELOCITY = -5000.0
var can_wall_jump = true
var wall_normal

#collisions
const PUSH_FORCE = 2000
var is_on_platform = false
var platform
var is_on_lever = false
var lever: Lever
var push_speed: float
var pushing = false


#camera
var zoom_min = Vector2(.14, .14)
var zoom_max = Vector2(.16, .16)
var zoom_speed = Vector2(.0005, .0005)



func _physics_process(delta: float) -> void:
	match current_state:
		States.NORMAL:
			_handle_normal_state(delta)
			var was_on_floor = is_on_floor()
			var was_on_wall = is_on_wall()
			var current_wall_normal
			if is_on_wall():
				current_wall_normal = get_wall_normal().x
				
			
			move_and_slide()
			_handle_collision()	

			var just_left_floor = was_on_floor and not is_on_floor() and velocity.y >= 0
			var just_left_wall = was_on_wall and not is_on_wall()
			if just_left_floor:
				coyote_jump_timer.start()
			if just_left_wall:
				coyote_wall_jump_timer.start()
				wall_normal = current_wall_normal
			#_align_with_slope(delta)
			
		States.CLIMBING:
			_handle_climbing_state(delta)
			
	_camera()


#NORMAL STATE

func _handle_normal_state(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	var wall_normal = get_wall_normal().x
	var is_pushing_into_wall = (direction * wall_normal) < 0
	if is_on_wall_only() and is_pushing_into_wall:
		velocity += get_gravity() * WALL_SLIDE_MULTIPLIER * delta
		velocity.y = min(velocity.y, WALL_SLIDE_MAX_VELOCITY)
		jump_count = 0
	elif not is_on_floor():
		if velocity.y >= FAST_FALL_SPEED:
			velocity += get_gravity() * FALL_MULTIPLIER * delta
		elif abs(velocity.y) < MAX_HEIGHT_SPEED_UP or abs(velocity.y) < MAX_HEIGHT_SPEED_DOWN:
			velocity += get_gravity() * MAX_HEIGHT_MULTIPLIER * delta
		else:
			velocity += get_gravity() * delta
		
		velocity.y = min(velocity.y, MAX_VELOCITY)
	else:
		jump_count = 0
		dash_count = 0
	_jump()
	_dash()
	
	if direction:
		if dashing:
			velocity.x = direction * DASH_SPEED
			velocity.y = 0
		
		elif pushing:
			velocity.x = direction * push_speed
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * ACCELERATION2)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * ACCELERATION2)
		
	if Input.is_action_just_pressed("down") and is_on_floor():
		position.y += 2
		
	if (Input.is_action_pressed("use")) and can_climb:
		start_climbing()	

func _align_with_slope(delta: float) -> void:
	if is_on_floor():
		var floor_normal := get_floor_normal()
		var target_angle := Vector2.UP.angle_to(floor_normal)
		player_sprite.rotation = lerp_angle(player_sprite.rotation, target_angle, ROTATION_SPEED * delta)
	else:
		player_sprite.rotation = lerp_angle(player_sprite.rotation, 0.0, ROTATION_SPEED * delta)

func _handle_collision()-> void:
	
	if is_on_platform:
		_platform_collision()
	if is_on_lever:
		_lever_collision()
	print(is_on_lever)
	
func _platform_collision()-> void:
	if platform is HorizontalPlatform:
		var impuls_position = platform.to_local(global_position).x
		var width = platform.width
		var impulse_strength = abs(impuls_position / width)
		var impulse = Vector2(0, PUSH_FORCE * impulse_strength * 3)
			
		var horizontal_tilt_force = 0.5 # Adjust this multiplier to change rotation intensity
		if impuls_position > 0 and platform.rotation_degrees < 40:
			impulse.x = -impulse.y * horizontal_tilt_force
			platform.apply_impulse(impulse.rotated(platform.rotation), Vector2(impuls_position, 0.0))
		elif impuls_position < 0 and platform.rotation_degrees > -40:
			impulse.x = impulse.y * horizontal_tilt_force
			platform.apply_impulse(impulse.rotated(platform.rotation), Vector2(impuls_position, 0.0))
		
		if platform.rotation_degrees >= 45 :
			platform.rotation_degrees -= 0.1
		elif platform.rotation_degrees <= -45 :
			platform.rotation_degrees += 0.1
		
		
	elif platform is VerticalPlatform:
		var impuls_position = platform.to_local(global_position).x
		var width = platform.width
		var impulse_strength = abs(impuls_position / width)
		var impulse = Vector2(0, PUSH_FORCE * impulse_strength * 0.5)
			
		var horizontal_tilt_force = 1 # Adjust this multiplier to change rotation intensity
		if impuls_position > 0 and platform.rotation_degrees < 15:
			impulse.x = -impulse.y * horizontal_tilt_force
			platform.apply_impulse(impulse.rotated(platform.rotation), Vector2(impuls_position, 0.0))
		elif impuls_position < 0 and platform.rotation_degrees > -15:
			impulse.x = impulse.y * horizontal_tilt_force
			platform.apply_impulse(impulse.rotated(platform.rotation), Vector2(impuls_position, 0.0))
		
		if platform.rotation_degrees >= 20 :
			platform.rotation_degrees -= 0.1
		elif platform.rotation_degrees <= -20 :
			platform.rotation_degrees += 0.1
	
func _lever_collision()-> void:
	var impuls_position = lever.to_local(global_position).x
	
	#var width = lever.width
	#var impulse_strength = abs(impuls_position / width)
	#var impulse = Vector2(0, PUSH_FORCE * impulse_strength * 0.05)
	#var horizontal_tilt_force = 0.5
	
	if impuls_position > 120 and lever.rotation_degrees < lever.right_max_rotation:
		lever.rotation+= lever.tilt_force
		#impulse.x = -impulse.y * horizontal_tilt_force
		#lever.apply_impulse(impulse.rotated(lever.rotation), Vector2(impuls_position, 0.0))
	elif impuls_position < -120 and lever.rotation_degrees > lever.left_max_rotation:
		lever.rotation-= lever.tilt_force
		#impulse.x = impulse.y * horizontal_tilt_force
		#lever.apply_impulse(impulse.rotated(lever.rotation), Vector2(impuls_position, 0.0))
		
	if lever.rotation_degrees >= lever.right_max_rotation + 5 :
		lever.rotation_degrees -= 0.1
	elif lever.rotation_degrees <= lever.left_max_rotation - 5 :
		lever.rotation_degrees += 0.1

	
func _dash()-> void:
	if Input.is_action_just_pressed("dash") and can_dash:
		if (not is_on_floor() and dash_count == 0) or is_on_floor():
			dashing = true
			dash_count += 1
			can_dash = false
			dash_timer.start()
			dash_again_timer.start()

func _jump()-> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_wall() or coyote_wall_jump_timer.time_left > 0.0:
			var direction := Input.get_axis("left", "right")
			if is_on_wall():
				wall_normal = get_wall_normal().x
			if wall_normal * direction > 0:
				velocity.y = WALL_JUMP_VELOCITY
				velocity.x = wall_normal * WALL_JUMP_PUSHBACK
				can_wall_jump = false
				wall_jump_again_timer.start()
			elif can_wall_jump:
				velocity.y = WALL_JUMP_VELOCITY
				velocity.x = wall_normal * WALL_JUMP_PUSHBACK
				can_wall_jump = false
				wall_jump_again_timer.start()
		elif is_on_floor() or coyote_jump_timer.time_left > 0.0:
			velocity.y = JUMP_VELOCITY
		elif jump_count < 1:
			jump_count += 1
			velocity.y = JUMP_VELOCITY
			
	if Input.is_action_just_released("jump") and velocity.y < 0:
		# Reduce the upward momentum by half
		velocity.y *= 0.5

func _on_dash_timer_timeout() -> void:
	dashing = false

func _on_dash_angain_timer_timeout() -> void:
	can_dash = true

func _on_wall_jump_again_timer_timeout() -> void:
	can_wall_jump = true
	
func _on_detection_area_body_entered(body) -> void:
	if body is HorizontalPlatform or body is VerticalPlatform:
		is_on_platform = true
		platform = body
	if body is Rock:
		push_speed = body.speed

func _on_detection_area_body_exited(body) -> void:
	if body is HorizontalPlatform or body is VerticalPlatform:
		platform = body
		is_on_platform = false

func _on_detection_area_area_entered(area: Area2D) -> void:
	if area is LeverDetectionArea:
		lever = area.get_parent()
		is_on_lever = true
		lever.with_player = true

func _on_detection_area_area_exited(area: Area2D) -> void:
	if area is LeverDetectionArea:
		is_on_lever = false
		lever.with_player = false
		lever = null



#CLIMB STATE
func start_climbing() -> void:
	current_state = States.CLIMBING
	velocity = Vector2.ZERO
	can_climb = false
	

func _handle_climbing_state(delta: float) -> void:
	if Input.is_action_pressed("up"):
		rope_section_progress -= CLIMB_SPEED * delta
		if rope_section_progress < 0:
			if attached_rope_part_id > 0:
				rope_section_progress = 1.0
				attached_rope_part_id = clamp( attached_rope_part_id-1, 0, attached_rope.rope_parts.size()-1 )
			else:
				rope_section_progress = 0.0
	elif Input.is_action_pressed("down"):
		rope_section_progress += CLIMB_SPEED * delta
		if rope_section_progress > 1:
			if attached_rope_part_id < attached_rope.rope_parts.size()-2:
				rope_section_progress = 0.0
				attached_rope_part_id = clamp( attached_rope_part_id+1, 0, attached_rope.rope_parts.size()-1 )
			else:
				rope_section_progress = 1.0
	
	global_position = get_player_pos_on_rope()
	
	#Pump momentum into the rope when pressing Left/Right
	var swing_direction := Input.get_axis("left", "right")
	var segment = attached_rope.rope_parts[attached_rope_part_id] as RigidBody2D
	if swing_direction != 0:
		segment.apply_central_impulse(Vector2(swing_direction * SWING_HORIZONTAL_FORCE, 0.0))

		
	#Jump off the rope
	if Input.is_action_just_pressed("jump"):
		var jump_dir := Input.get_axis("left", "right")
		segment.apply_central_impulse(Vector2(-jump_dir * LEAVING_ROPE_SWING_X, LEAVING_ROPE_SWING_Y))
		stop_climbing()
		velocity.y = JUMP_VELOCITY
		velocity.x = jump_dir * SPEED

func stop_climbing() -> void:
	current_state = States.NORMAL
	attached_rope_part_id = -INF
	attached_rope = null
	jump_count = 0

func _on_rope_detection_area_body_entered(body: RopePiece) -> void:
	if current_state == States.NORMAL:
		can_climb = true
		rope_section_progress = 0.0
		attached_rope_part_id = body.id
		attached_rope = body.parent
		var impact_force = velocity.x * PASSIVE_SWING 
		body.apply_central_impulse(Vector2(impact_force, 0))

func _on_rope_detection_area_body_exited(body: RopePiece) -> void:
	can_climb = false
	var impact_force = velocity.x * 0.15
	
func get_player_pos_on_rope():
	var current_piece_pos = attached_rope.rope_parts[attached_rope_part_id].global_position
	var next_piece_id = clamp( attached_rope_part_id+1, 0, attached_rope.rope_parts.size()-1 )
	var next_piece_pos = attached_rope.rope_parts[next_piece_id].global_position
	#var rope_part_rotation := (attached_rope.rope_parts[attached_rope_part_id] as RigidBody2D).global_transform.get_rotation()
	var new_pos = lerp(current_piece_pos, next_piece_pos, rope_section_progress)
	return new_pos


#CAMERA
func _camera()-> void:
	if velocity != Vector2(0,0) and camera.zoom > zoom_min:
		camera.zoom -= zoom_speed
	elif velocity == Vector2(0,0) and camera.zoom < zoom_max:
		camera.zoom += zoom_speed * 0.7
