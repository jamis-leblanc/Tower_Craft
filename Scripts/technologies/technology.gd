extends Control

var _name = "Technology name"
var tooltip = "Technology tooltip"
var techno_ref = enums.techno.worker_speed
var parent_techno_ref = null
var cost = 0

onready var world = get_tree().get_root().get_node("World")


func _ready():
	add_to_group("UI")
	$MarginContainer/VBoxContainer/name.text = _name
	$MarginContainer/VBoxContainer/cost.text = str(cost)
	$MarginContainer/Line2D.points = [$MarginContainer/p_in.position,$MarginContainer/p_out.position]
	$Control/tooltip_panel/tooltip.text = tooltip
	if techno_manager.techno_list[techno_ref] == true :
		$Control2/TextureRect.set_visible(true)
	_update()


func _on_TextureButton_pressed():
	if techno_manager.techno_list[techno_ref] == false :
		if world.research >= cost :
			world.remove_research(cost)
			techno_manager.techno_list[techno_ref] = true
			$Control2/TextureRect.set_visible(true)
			get_tree().call_group("UI", "_update")
			update_stat()
		else :
			get_tree().call_group("UI", "show_notif","missing_research")


func _update():
	if parent_techno_ref == null or techno_manager.techno_list[parent_techno_ref] == true :
		$MarginContainer/VBoxContainer/CenterContainer/TextureButton.set_disabled(false)
	else :
		$MarginContainer/VBoxContainer/CenterContainer/TextureButton.set_disabled(true)


func _on_TextureButton_mouse_entered():
	$tooltip_timer.start()


func _on_TextureButton_mouse_exited():
	$Control/tooltip_panel.visible = false
	$tooltip_timer.stop()


func _on_tooltip_timer_timeout():
	$Control/tooltip_panel.visible = true


func update_stat():
	pass

