extends Node2D

@export var segment_scene: PackedScene = preload("res://scenes/anchor_rope_piece.tscn")# Drag your RopeSegment.tscn here
@export var segment_length: float = 400.0 # Height of your segment sprite
@onready var line_2d: Line2D = $Line2D
var rope_parts := []

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	var points: PackedVector2Array = [Vector2.ZERO] # Start at anchor
	
	# Gather positions of all spawned RigidBody2D children
	for child in get_children():
		if child is RigidBody2D:
			points.append(child.position)
	line_2d.points = points


func spawn_rope(rope_length) -> void:
	# 1. Create a static anchor point so the rope doesn't fall out of the sky
	var anchor = StaticBody2D.new()
	var anchor_collision = CollisionShape2D.new()
	# Give it a tiny shape just to satisfy physics requirements
	var circle = CircleShape2D.new()
	circle.radius = 2.0
	anchor_collision.shape = circle
	add_child(anchor)
	
	var last_body = anchor
	
	# 2. Spawn the chain links
	for i in range(rope_length):
		var segment = segment_scene.instantiate() as RigidBody2D
		segment.id = i
		segment.parent = self
		rope_parts.append(segment)
		# Position each segment directly below the last one
		segment.position = Vector2(0, (i + 1) * segment_length - (segment_length)/2)
		add_child(segment)
		
		# 3. Connect the previous body's joint to this new segment
		# The very first joint belongs to the anchor, otherwise it belongs to the previous segment
		if i == 0:
			var anchor_joint = PinJoint2D.new()
			anchor_joint.position = Vector2.ZERO
			anchor_joint.softness = 0.1
			anchor.add_child(anchor_joint)
			anchor_joint.node_a = anchor.get_path()
			anchor_joint.node_b = segment.get_path()
		else:
			# Get the joint located at the bottom of the previous segment
			var joint = last_body.get_node("J") as PinJoint2D
			joint.node_b = segment.get_path()
			
		last_body = segment
		
