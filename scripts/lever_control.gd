extends Node2D
@export var tilt_force: float = 0.02
@export var right_max_rotation: float = 20.0
@export var left_max_rotation: float = -20.0
@onready var rigid_body: Lever = $RigidBody2D
