tool
extends WindowDialog

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var autosaveOnExit

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	autosaveOnExit = get_node("Options/CheckBox")
	pass

func load_options(dict):
	print(dict)
	autosaveOnExit.set_pressed(dict.autosaveOnExit)
	pass
	
func visibilityChanged():
	pass # replace with function body
