extends Node

export var growth = 0

enum tree_state {	small,
					medium,
					large
				}

var size = 1
var health = 25
var growth_rate = 0.1
var growth_state = tree_state.small

var step_1 = 5
var step_2 = 10
var tile = Vector2()
var _name = "Tree"
#var structure_manager = null

signal change_tile(x,y,index)


func get_image_index():
	if growth < step_1 : return 2
	if growth >= step_1 and growth < step_2: return 1
	if growth >= step_2 : return 0


func grow():
	growth += growth_rate
	if growth >= step_1 and growth_state == tree_state.small: 
		growth_state = tree_state.medium
		self.emit_signal("change_tile",tile.x,tile.y,1)
	if growth >= step_2 and growth_state == tree_state.medium: 
		growth_state = tree_state.large
		add_to_group("Tree")
		self.emit_signal("change_tile",tile.x,tile.y,0)
	if growth >10 : growth = 10

func damage(amount):
	health -= amount
	#print(health)
	if health <= 0:
		structure_manager.remove_tree(tile.x,tile.y)
		queue_free()
		return(amount + health)
	else : return(amount)