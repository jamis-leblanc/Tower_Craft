extends Node2D

var mouse_cell = Vector2()
var scan_dist = 15
var current_cell = []
var stack = []
var visited = []
var adjacent = []
var closest = null
var min_distance = 10000
var selected = null
var checked_cell = Vector2()
var direction = [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1),Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]


onready var cell_size = Vector2(32,32)
onready var offset = 0.5
onready var map = get_parent().get_node("nav/map_structure")
onready var map_char = get_parent().get_node("map_char")
onready var map_bucket = get_parent().get_node("map_bucket")


func _process(delta):
	follow_cursor()
	floodfill()
	
func floodfill():
	current_cell = Vector2((self.position.x-16)/32,(self.position.y-16)/32)
	closest = null
	min_distance = 10000
	stack = []
	visited = []
	adjacent = []
	checked_cell = current_cell	
	stack.append(checked_cell)
	while stack.size() > 0 :
		checked_cell = stack.back()
		if not visited.has(checked_cell) :
			visited.append(checked_cell)
			stack.pop_back()
			check_adjacent(checked_cell)
		else : stack.pop_back()


func check_adjacent(cell):
	var distance = current_cell.distance_to(cell)
	for i in direction:
		var cell_type = map.get_cellv(cell + i)
#		if cell_type == 0 :
#			if  distance < min_distance:
#				min_distance = distance
#				selected = cell
#		if abs(i.x) + abs(i.y) == 1 :
		var dist = current_cell.distance_to(cell + i)
		if  (cell_type == 5 or cell_type == 3) and dist < scan_dist:
			stack.append(cell+i)


func follow_cursor():
	mouse_cell = get_global_mouse_position()/(cell_size)
	self.position.x = (floor(mouse_cell.x)+offset)*cell_size.x
	self.position.y = (floor(mouse_cell.y)+offset)*cell_size.y