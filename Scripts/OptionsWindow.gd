tool
extends WindowDialog

onready var autosaveOnExit = get_node("Options/CheckBox")

func load_options(dict):
	autosaveOnExit.set_pressed(dict.autosaveOnExit)
	
func visibilityChanged():
	pass
