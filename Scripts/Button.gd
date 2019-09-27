extends CanvasLayer

var repair_cursor = load("res://GFX/repair_cursor.png")
var demolish_cursor = load("res://GFX/demolish_cursor.png")
var mouse_state = enums.mouse_state.build


func _process(delta):
	if Input.is_action_just_pressed("mouse_right_clic") :
		$repair_button.set_pressed(false)
		$demolish_button.set_pressed(false)
		Input.set_custom_mouse_cursor(null)
		mouse_state = enums.mouse_state.build

var notif_dict = 	{
					"missing_ress" : 				"Not enought wood, harvest more.",
					"missing_food" : 				"Not enought food, build more farm.",
					"missing_research" : 			"Not enought research point, hire more scientist",
					"building_attack" : 			"One of your building is under attack!",
					"building_destroyed" : 			"One of your building has been destroyed!",
					"castle_attack" : 				"Your Castle is under attack!",
					"worker_spawning_cooldown" : 	"A new worker is already being build",
					"low_mana" :					"Your Mana pool is low, gather more mana."
					}


onready var world = get_tree().get_root().get_node("World")


func _ready():
	add_to_group("UI")


func _update():
	
	$MarginContainer/HBoxContainer2/HBoxContainer/Wood_Label.text =  str(world.wood)
	$MarginContainer/HBoxContainer2/HBoxContainer2/Food_Label.text = str(worker_manager.workers_list.size()) + "/" + str(world.food) 
	$MarginContainer/HBoxContainer2/HBoxContainer3/Research_Label.text = str(world.research)
	$MarginContainer/HBoxContainer2/HBoxContainer4/mana_Label.text = str(world.mana)

func _on_Button_pressed():
	spawn("res://Scenes/forester.tscn")


func _on_Button2_pressed():
	spawn("res://Scenes/core.tscn")


func _on_Button3_pressed():
	spawn("res://Scenes/woodcutter.tscn")


func _on_Button4_pressed():
	spawn("res://Scenes/farm.tscn")


func _on_Button5_pressed():
	spawn("res://Scenes/laboratory.tscn")
	

func _on_Button6_pressed():
	spawn("res://Scenes/tower_base.tscn")

func _on_Button7_pressed():
	spawn("res://Scenes/altar.tscn")
	
	
func spawn(type) :
	var instance = load(type).instance()
	if world.wood >= instance.cost :
		instance.state = enums.building_states.spawn
		world.add_child(instance)
		world.wood -= instance.cost
		_update()
	else :
		show_notif("missing_ress")


func show_notif(type):
	$CenterContainer/pop_up_notif.text = notif_dict[type]
	$CenterContainer/pop_up_timer.start()
	$CenterContainer/pop_up_notif.visible = true


func _on_pop_up_timer_timeout():
	$CenterContainer/pop_up_notif.visible = false

func _on_repair_button_toggled(button_pressed):
	Input.set_custom_mouse_cursor(repair_cursor)
	$demolish_button.set_pressed(false)
	mouse_state = enums.mouse_state.repair


func _on_demolish_button_toggled(button_pressed):
	Input.set_custom_mouse_cursor(demolish_cursor)
	$repair_button.set_pressed(false)
	mouse_state = enums.mouse_state.demolish


func _on_Button8_pressed():
	spawn("res://Scenes/wall.tscn")
