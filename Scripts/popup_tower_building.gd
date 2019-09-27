extends Node2D

onready var parent = self.get_parent().get_parent()
var UI_instance = null

func _ready():
	add_to_group("UI")
	_update()


func _update():
	
	$PanelContainer/VBoxContainer/GridContainer/health_label.text = "Health : " + str(parent.health) + " / " + str(parent.health_max)
	$PanelContainer/VBoxContainer/GridContainer/damage_label.text = "Damage : " + str(parent.damage)
	$PanelContainer/VBoxContainer/GridContainer/attack_speed_label.text = "Attack speed : " + str(parent.attack_cooldown)


func _on_TextureButton_pressed():
	get_parent().get_parent().UI_on = false
	queue_free()


