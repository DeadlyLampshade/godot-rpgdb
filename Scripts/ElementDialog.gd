tool 
extends ConfirmationDialog

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var name = get_node("PanelContainer/VBoxContainer/LineEdit")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func blank():
	name.set_text("")

func clean():
	return { "name": name.get_text() }

func unclean( dict ):
	
	if !dict.has("name"): 
		# Create a default if it doesn't exist.
		dict.name = ""
	
	name.set_text(dict.name)