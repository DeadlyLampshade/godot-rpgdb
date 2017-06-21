tool
extends ConfirmationDialog

onready var name = get_node("PanelContainer/VBoxContainer/LineEdit")

func blank():
	name.set_text("")

func clean():
	return { "name" : name.get_text() }

func unclean(dict):
	name.set_text(dict.name)