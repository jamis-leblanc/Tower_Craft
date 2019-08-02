extends Node2D

signal UI_Update()

var cell_size = Vector2(32,32)
var wood = 0
var map_size = Vector2(40 * cell_size.x,40 * cell_size.y) 

onready var nav = get_node("nav")
onready var map = get_node("nav/map_structure")
onready var UI = get_node("UI")


func _ready():
	self.connect("UI_Update",UI,"Update")

func add_wood(amount):
	wood+=amount
	self.emit_signal("UI_Update")