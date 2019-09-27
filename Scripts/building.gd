extends Node2D

var state = enums.building_states.prebuild
var is_working = true
var cost = 0
var food = 0
var size = 2
var tile_index = 8
var building_tile_index = 14
var destroyed_tile_index = 18
var mouse_offset = fmod(size+1,2) * Vector2(16,16)	# mouse_offset = 16,16 if size is en even number,  0,0 otherwise
var position_offset = fmod(size,2) * Vector2(16,16)	# position_offset = 16,16 if size is en odd number,  0,0 otherwise
var tile_offset = floor(size/2) * Vector2(-1,-1)	# tile_offset = (0,0) is size  = 1, (-1,-1) otherwise

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
var mana_consumption = 0
var max_user = 0
var current_user = 0

var reference = "res://Scenes/forester.tscn"

onready var map = get_parent().get_node("nav/map_structure")
onready var world = get_tree().get_root().get_node("World")
onready var UI = get_tree().get_root().get_node("World/UI")

signal add_structure_to_tilemap(x,y,reference)
signal online()
signal offline()

func _ready():
	self.connect("add_structure_to_tilemap",structure_manager,"add_structure_to_tilemap")


func _process(delta):
	$Label.text = str(health)
	if state == enums.building_states.spawn :
		follow_cursor()
	if state == enums.building_states.no_mana :
		use_mana(mana_consumption)
		

func follow_cursor():
	
	var mouse_cell = map.world_to_map(get_global_mouse_position() + mouse_offset)
	tile = mouse_cell + tile_offset
	self.global_position = map.map_to_world(mouse_cell) + position_offset
	check_position_validity()
	if Input.is_action_just_pressed("mouse_left_clic") and is_valid == true:
		self.emit_signal("add_structure_to_tilemap",tile.x,tile.y,self)
		state = enums.building_states.build
		$Sprite.set_visible(false)
	if Input.is_action_just_pressed("mouse_right_clic") :
		world.add_wood(cost)
		self.queue_free()

func check_position_validity():
	is_valid = true
	for j in size :
			for i in size :
				var cell_type = map.get_cell(tile.x+i,tile.y+j)
				if cell_type != 5 and cell_type != 3:
					is_valid = false
	if is_valid == false :	$Sprite.set_self_modulate(Color(1,0.25,0.25,0.5))
	else  : 				$Sprite.set_self_modulate(Color(1,1,1,0.5))


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed() :
		if state == enums.building_states.operate \
		and UI.mouse_state == enums.mouse_state.build :
			if UI_on == false :
				UI_on = true
				UI_instance = load(popup_UI).instance()
				UI_instance.set_z_index(10)
				get_node("UI_anchor").add_child(UI_instance)
				UI_instance.find_node("_name").text = _name
			else :
				UI_on = false
				UI_instance.queue_free()
		elif UI.mouse_state == enums.mouse_state.demolish :
			destroy()
		elif UI.mouse_state == enums.mouse_state.repair and health < health_max and task_manager.task_on_building(self) == false :
			task_manager.new_task(enums.task_type.repair,self,null)


func repair(amount):
	var repair = min(health_max-health,amount)
	health += repair
	update_pbar()
	return repair


func build_complete() :
	state = enums.building_states.operate
	structure_manager.change_tile(tile.x,tile.y,tile_index)
	map.update_bitmask_area(tile)
	world.add_food(food)
	get_tree().call_group("UI", "_update")
	emit_signal("online")

func repair_complete() :
	pass


func update_pbar():
	$ProgressBar.value = health
	get_tree().call_group("UI", "_update")
	

func damage(amount):
	if state != enums.building_states.exploding :
		health -= amount/20
		update_pbar()
		if health <= 0 :
			destroy()
			state = enums.building_states.exploding
			$Sprite.set_visible(false)


func destroy():
	worker_manager.clear_struct(self)
	structure_manager.remove_structure_from_tilemap(self)
	structure_manager.unregister_structure(self)
	structure_manager.change_tile(tile.x,tile.y,destroyed_tile_index)
	var instance = load("res://Scenes/simple_spawner.tscn").instance()
	add_child(instance)
	instance.connect("delete",self,"delete")
	task_manager.delete_incomplete_task(self)


func delete():
	if name == "core" :
		print("Game Over")
		get_tree().change_scene("res://Scenes/game_over.tscn")
	else :
		structure_manager.change_tile(tile.x,tile.y,5)
		map.update_bitmask_area(tile)
		queue_free()


func _on_use_mana_timeout():
	if state == enums.building_states.operate :
		use_mana(mana_consumption)


func use_mana(amount):
	if world.mana >= amount :
		if amount > 0:
			world.remove_mana(amount)
			if state == enums.building_states.no_mana :
				state = enums.building_states.operate
				emit_signal("online")
	elif state == enums.building_states.operate :
		state = enums.building_states.no_mana
		emit_signal("offline")
		

func add_user():
	if current_user < max_user :
		return true
	else :
		return false
		
func remove_user():
	if current_user > 0 :
		return true
	else :
		return false