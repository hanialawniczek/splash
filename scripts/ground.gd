extends StaticBody2D

@onready var collision_poly = $CollisionPolygon2D
@onready var visual_poly = $Polygon2D

func _ready():
	visual_poly.polygon = collision_poly.polygon
