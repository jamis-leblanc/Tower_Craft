extends Node2D

signal UI_Update()

var cell_size = Vector2(32,32)
var wood = 500
var food = 0
var research = 0
var map_size = Vector2(64 * cell_size.x,64 * cell_size.y) 

onready var nav = get_node("nav")
onready var map = get_node("nav/map_structure")
onready var UI = get_node("UI")


func _ready():
	self.connect("UI_Update",UI,"_update")

func add_wood(amount):
	wood+=amount
	self.emit_signal("UI_Update")


func add_food(amount):
	food+=amount
	self.emit_signal("UI_Update")


func add_research(amount):
	research += amount
	self.emit_signal("UI_Update")

func remove_research(amount):
	research -= amount
	self.emit_signal("UI_Update")