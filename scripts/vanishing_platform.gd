extends StaticBody2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var disappear_timer: Timer = $DisappearTimer
@onready var reappear_timer: Timer = $ReappearTimer
@onready var sprite: Sprite2D = $Icon
@onready var area: Area2D = $Area2D

var shake = false
var time = 1

var shaking_speed = 0.4
var amplitude = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake:
		time += shaking_speed
		sprite.position += Vector2(0, sin(time) * amplitude)


func _on_area_2d_body_entered(body: Node2D) -> void:
	disappear_timer.start()
	time = 1
	shake = true
	

func _on_disappear_timer_timeout() -> void:
	shake = false
	sprite.visible = false
	collision.disabled = true
	area.monitoring = false
	reappear_timer.start()


func _on_reappear_timer_timeout() -> void:
	sprite.visible = true
	collision.disabled = false
	area.monitoring = true
