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
						operate
					}

enum task_type {	build,
					repair
				}
