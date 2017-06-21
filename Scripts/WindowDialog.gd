tool
extends WindowDialog

onready var tabContainer = get_node("VBoxContainer/TabContainer")
onready var contextPopup = get_node("PopupPanel")
onready var helpButton = get_node("VBoxContainer/HBoxContainer 2/ToolButton 2")


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func provideContextualHelp():
	var string = tabContainer.get_current_tab_control().createHelp()
	contextPopup.get_node("Label").set_text(string)
	contextPopup.popup_centered_minsize()
	pass

func changeHelpButton( tab ):
	var string = "Help (%s)" % tabContainer.get_current_tab_control().get_name()
	helpButton.set_text(string)
	pass # replace with function body
