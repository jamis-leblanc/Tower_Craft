extends Node

var builder_list = []
var task_list = []


func _process(delta):
	match_task_builder()


func add_builder(builder):
	builder_list.append([builder,null])


func remove_builder():
	var builder_removed = null
	for i in builder_list :
		if i[1] == null :
			builder_removed = i[0]
			builder_list.erase(i)
			break
	return builder_removed


func release_builder(task):
	for i in builder_list :
		if i[1] == task :
			print("worker " + str(i[0]) + " released")
			i[1] = null
			i[0].get_node("Jobs/Builder").build_task = []


func new_task(type,structure,duration):
	task_list.append([type,structure,duration,false])


func remove_task(task):
	print("Task " + str(task) + " removed")
	task_list.erase(task)


func match_task_builder():
	for i in task_list :
		if i[3] == false :
			for j in builder_list :
				if j[1] == null :
					print("task : " + str(i) + " affected to builder " + str(j))
					i[3] = true
					j[1] = i
					j[0].get_node("Jobs/Builder").build_task = i
					break


func task_complete(task):
	release_builder(task)
	remove_task(task)


func delete_incomplete_task(structure):
	var incomplete_task_index = find_2D(task_list,structure,1)
	if incomplete_task_index != -1 :
		var incomplete_task = task_list[incomplete_task_index]
		print("Delete incomplete task : " + str(incomplete_task))
		release_builder(incomplete_task)
		remove_task(incomplete_task)

func task_on_building(structure):
	var task_index = find_2D(task_list,structure,1)
	if task_index == -1 :
		return false
	else :
		return true

func find_2D(list,value,pos):
	for i in range(list.size()) :
		if list[i][pos] == value :
			return i
	return -1


func affect_task(task,builder) :
	pass