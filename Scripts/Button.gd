extends CanvasLayer

#func _process(delta):
#	$Label.text = "FPS : " + str(ceil(1/delta))

func _on_Button_pressed():
	var instance = load("res://Scenes/forester.tscn").instance()
	get_tree().get_root().get_node("World").add_child(instance)


func _on_Button2_pressed():
	var instance = load("res://Scenes/core.tscn").instance()
	get_tree().get_root().get_node("World").add_child(instance)


func _on_Button3_pressed():
	var instance = load("res://Scenes/woodcutter.tscn").instance()
	get_tree().get_root().get_node("World").add_child(instance)


func Update():
	$TextureRect/MarginContainer/Wood_Label.text = str(get_tree().get_root().get_node("World").wood)
