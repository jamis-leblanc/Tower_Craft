extends CanvasLayer

func _process(delta):
	$Label.text = "FPS : " + str(ceil(1/delta))

var notif_dict = 	{
					"missing_ress" : "Not enought wood, harvest more.",
					"missing_food" : "Not enought food, build more farm.",
					"building_attack" : "One of your building is under attack!",
					"building_destroyed" : "One of your building has been destroyed!",
					"castle_attack" : "Your Castle is under attack!"
					}


onready var world = get_tree().get_root().get_node("World")


func _ready():
	add_to_group("UI")


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


func _update():
	$TextureRect/MarginContainer/HBoxContainer2/HBoxContainer/Wood_Label.text = str(world.wood)
	$TextureRect/MarginContainer/HBoxContainer2/HBoxContainer2/Food_Label.text = str(worker_manager.workers_list.size()) + "/" + str(world.food) 
	$TextureRect/MarginContainer/HBoxContainer2/HBoxContainer3/Research_Label.text = str(world.research)

func _on_pop_up_timer_timeout():
	$CenterContainer/pop_up_notif.visible = false


