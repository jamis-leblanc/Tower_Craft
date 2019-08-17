extends PanelContainer

var techno_list = [	"res://Scenes/Technologies/techno_test_1.tscn",
					"res://Scenes/Technologies/techno_test_2.tscn",
					"res://Scenes/Technologies/techno_test_3.tscn"
					]

var _name = "Technology tree name"
var tooltip = "Technology tooltip"


func _ready():
	$VBoxContainer/name.text = _name
	$Line2D.points = [
		$VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/techno_test_2/MarginContainer/p_in.global_position-$Line2D.global_position,
		$VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/techno_test_3/MarginContainer/p_in.global_position-$Line2D.global_position
		]
	print(str($Line2D.points))