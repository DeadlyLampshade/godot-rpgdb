tool 
extends ConfirmationDialog

onready var name = get_node("PanelContainer/VBoxContainer/LineEdit")

func blank():
	name.set_text("")

func clean():
	return { "name": name.get_text() }

func unclean( dict ):
	
	if !dict.has("name"): 
		# Create a default if it doesn't exist.
		dict.name = ""
	
	name.set_text(dict.name)