extends Node2D


var waypoints := PoolVector2Array()


func _process(_delta: float) -> void:
	update()


func _draw() -> void:
	var points := PoolVector2Array()
	for waypoint in waypoints:
		points.push_back(to_local(waypoint))
	draw_polyline(points, Color(0.0, 0.5, 1.0, 1.0))
