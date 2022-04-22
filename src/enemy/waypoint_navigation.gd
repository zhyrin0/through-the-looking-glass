tool
extends Node2D


export(float) var connection_radius: float
export(Color) var waypoint_color: Color = Color(0.0, 0.5, 1.0, 0.1)
var astar := AStar2D.new()


func _ready() -> void:
	if not Engine.editor_hint:
		Algorithm.for_each(get_children(), funcref(self, "register_waypoint"))
		Algorithm.for_each(get_children(), funcref(self, "connect_neighbours"))


func _process(_delta: float) -> void:
	if Engine.editor_hint:
		update()


func _draw() -> void:
	for waypoint in get_children():
		draw_waypoint(waypoint)


func register_waypoint(waypoint: Node2D, _args: Array) -> void:
	astar.add_point(waypoint.get_index(), waypoint.global_position)


func connect_neighbours(waypoint: Node2D, _args: Array) -> void:
	var neighbours := []
	Algorithm.copy_if(get_children(), neighbours, funcref(self, "is_unconnected_neighbour"),
			[waypoint.get_index(), waypoint.position, connection_radius*connection_radius])
	Algorithm.for_each(neighbours, funcref(self, "do_connect_neighbours"), [waypoint.get_index()])


func is_unconnected_neighbour(other: Node2D, args: Array) -> bool:
	var this_id := args[0] as int
	var this_pos := args[1] as Vector2
	var connection_radius_sq := args[2] as float
	return other.get_index() != this_id and \
			not astar.are_points_connected(this_id, other.get_index()) and \
			this_pos.distance_squared_to(other.position) <= connection_radius_sq


func do_connect_neighbours(other: Node2D, args: Array) -> void:
	var this_id := args[0] as int
	astar.connect_points(this_id, other.get_index())


func draw_waypoint(waypoint: Node2D) -> void:
	if waypoint.visible:
		draw_circle(waypoint.position, connection_radius, waypoint_color)


func on_Enemy_request_path(enemy: Node2D) -> void:
	var from_id := astar.get_closest_point(enemy.global_position)
	var to_id := from_id
	while to_id == from_id:
		to_id = randi() % astar.get_point_count()
	enemy.set_path(astar.get_point_path(from_id, to_id))
