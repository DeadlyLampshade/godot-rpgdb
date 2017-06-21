tool
extends ConfirmationDialog

onready var name = get_node("HRootContainer/VRootContainer/EffectNameContainer/EffectNameEdit")
onready var desc = get_node("HRootContainer/VRootContainer/VBoxContainer/LineEdit")
onready var display = get_node("HRootContainer/VRootContainer/VBoxContainer 2/LineEdit")

func blank():
	name.set_text("")
	desc.set_text("")
	display.set_text("")


func unclean(dict):
	name.set_text(dict.name)
	desc.set_text(dict.desc)
	display.set_text(dict.display)


func clean():
	var dict = {}
	dict.name = name.get_text()
	dict.desc = desc.get_text()
	dict.display = display.get_text()
	return dict
