extends Node2D

var state = enums.building_states.prebuild
var is_working = true
var cost = 0
var food = 0
var size = 2
var tile_index = 8
var building_tile_index = 14
var offset = floor(size/2)
var tile_offset = Vector2(-1,-1)
var UI_offset = Vector2(64,-32)
var tile = null
var is_valid = true
var UI_on = false
var UI_instance = null
var building_time = 1
var _name = "Building"
var popup_UI = "res://Scenes/Popup_regular_building.tscn"
var health = 0
var health_max = 100

var reference = "res://Scenes/forester.tscn"

onready var map = get_parent().get_node("nav/map_structure")
onready var world = get_tree().get_root().get_node("World")

signal add_structure_to_tilemap(x,y,reference)

func _ready():
	self.connect("add_structure_to_tilemap",structure_manager,"add_structure_to_tilemap")


func _process(delta):
	$Label.text = str(state)
	if state == enums.building_states.spawn :
		follow_cursor()
	if state == enums.building_states.operate and $Sprite.visible == false :
		$Sprite.set_visible(true)


func follow_cursor():
	var mouse_cell = get_global_mouse_position()/(get_parent().cell_size)
	self.position.x = (floor(mouse_cell.x)+offset)*get_parent().cell_size.x
	self.position.y = (floor(mouse_cell.y)+offset)*get_parent().cell_size.y
	tile = map.world_to_map(Vector2(self.position.x,self.position.y))
	check_position_validity()
	if Input.is_action_just_pressed("mouse_left_clic") and is_valid == true:
		self.emit_signal("add_structure_to_tilemap",tile.x-offset-1,tile.y-offset-1,self)
		state = enums.building_states.build
		$Sprite.set_visible(false)


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
	and event.is_pressed() \
	and state == enums.building_states.operate :
		if UI_on == false :
			UI_on = true
			UI_instance = load(popup_UI).instance()
			UI_instance.set_z_index(10)
			get_node("UI_anchor").add_child(UI_instance)
			UI_instance.find_node("_name").text = _name
		else :
			UI_on = false
			UI_instance.queue_free()


func repair(amount):
	var repair = min(health_max-health,amount)
	health += repair
	update_pbar()
	return repair


func build_complete() :
	state = enums.building_states.operate
	structure_manager.change_tile(tile.x-offset-1,tile.y-offset-1,tile_index)
	world.add_food(food)
	get_tree().call_group("UI", "_update")


func update_pbar():
	$ProgressBar.value = health
	