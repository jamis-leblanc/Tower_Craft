extends PanelContainer

var techno_list = [	"res://Scenes/Technologies/techno_test_4.tscn",
					"res://Scenes/Technologies/techno_test_5.tscn"
					]

var _name = "Technology tree 2"
var tooltip = "Technology tooltip"


func _ready():
	$VBoxContainer/name.text = _name