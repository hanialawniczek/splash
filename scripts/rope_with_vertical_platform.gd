extends Node2D
@export var rope_length: int = 30
@export var rope_scene = load("res://scenes/anchor_rope.tscn")
@export var platform_scene = load("res://scenes/vertical_platform.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rope = rope_scene.instantiate()
	var platform = platform_scene.instantiate()
	add_child(rope)
	rope.spawn_rope(rope_length)
	var segment = rope.rope_parts[rope_length - 1] as RigidBody2D
	add_child(platform)
	var position = segment.position  + Vector2(0.0, (platform.height/2 )) #+ rope.segment_length/2
	platform.position = position
	platform.deafult_position = platform.global_position

	var joint = segment.get_node("J") as PinJoint2D
	joint.node_b = platform.get_path()
