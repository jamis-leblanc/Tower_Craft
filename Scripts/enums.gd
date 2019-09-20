extends Node

enum task {	idle,
			seek_target,
			go_target,
			harvest,
			seek_home,
			go_home,
			unload,
			get_in,
			get_out,
			cultivate,
			research,
			operate,
			}


enum enemy_task {	idle,
					seek_step,
					move_to_step,
					seek_tree,
					hit_tree,
					seek_final_target,
					move_to_final_target,
					hit_final_target,
					death
				}


enum jobs { 	jobless,
				woodcutter,
				builder,
				scientist,
				peasant,
				defender
			}

enum building_states {	prebuild,
						spawn,
						build,
						operate,
						exploding
					}

enum task_type {	build,
					repair
				}

enum techno {	worker_speed,
				harvest_speed,
				harvest_speed_2,
				harvest_amount,
				worker_max_load
			}
				