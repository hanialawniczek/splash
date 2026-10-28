extends Path2D

@export var loop  = true
@export var update_rotation = false
@export var speed = 2.0
@export var speed_scale = 1.0
@onready var path: PathFollow2D = $PathFollow2D
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var remote_transform: RemoteTransform2D = $PathFollow2D/RemoteTransform2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	remote_transform.update_rotation = update_rotation
	if not loop:
		animation.play("move")
		animation.speed_scale = speed_scale
		set_process(false)

func _process(delta: float) -> void:
	path.progress += speed
