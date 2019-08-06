extends Node2D

var is_spawning = true
var is_working = true
var size = 2
var tile_index = 8
var offset = floor(size/2)
var tile_offset = Vector2(-1,-1)
var UI_offset = Vector2(64,-32)
var tile = null
var is_valid = true
var UI_on = false
var UI_instance = null
var _name = "Building"
var popup_UI = "res://Scenes/Popup_regular_building.tscn"

var reference = "res://Scenes/forester.tscn"

onready var map = get_parent().get_node("nav/map_structure")
#onready var structure_manager = get_parent().get_node("structure_manager")

signal add_structure_to_tilemap(x,y,reference)
#signal signal_send()

func _ready():
	self.connect("add_structure_to_tilemap",structure_manager,"add_structure_to_tilemap")
	#self.connect("signal_send",structure_manager,"signal_received")


func _process(delta):
	if is_spawning == true :
		follow_cursor()


func follow_cursor():
	var mouse_cell = get_global_mouse_position()/(get_parent().cell_size)
	self.position.x = (floor(mouse_cell.x)+offset)*get_parent().cell_size.x
	self.position.y = (floor(mouse_cell.y)+offset)*get_parent().cell_size.y
	tile = map.world_to_map(Vector2(self.position.x,self.position.y))
	check_position_validity()
	if Input.is_action_just_pressed("mouse_left_clic") and is_valid == true:
		self.emit_signal("add_structure_to_tilemap",tile.x-offset-1,tile.y-offset-1,self)
		#self.emit_signal("signal_send")
		is_spawning = false
		
		

func check_position_validity():
	is_valid = true
	for j in size :
			for i in size :
				var cell_type = map.get_cell(tile.x-(size/2+offset)+i,tile.y-(size/2+offset)+j)
				if cell_type != 5 :
					is_valid = false
	if is_valid == false :	$Sprite.set_self_modulate(Color(1,0.25,0.25,1))
	else  : 				$Sprite.set_self_modulate(Color(1,1,1,1))



func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed() :
		if UI_on == false :
			UI_on = true
			UI_instance = load(popup_UI).instance()
			UI_instance.set_z_index(10)
			print(UI_instance.z_index)
			get_node("UI_anchor").add_child(UI_instance)
			UI_instance.find_node("_name").text = _name
		else :
			UI_on = false
			UI_instance.queue_free()












