extends Node2D

var _name = "Technology name"
var tooltip = "Technology tooltip"
var cost = 0
var parent = null
var locked = true
var bought = false


func _ready():
	$MarginContainer/VBoxContainer/name.text = _name
	$MarginContainer/VBoxContainer/cost.text = str(cost)
	$MarginContainer/Line2D.points = [$MarginContainer/p_in.position,$MarginContainer/p_out.position]

func _on_TextureButton_pressed():
	pass # Replace with function body.
