tool
extends ConfirmationDialog

onready var fullname = get_node("PanelContainer/VBoxContainer/Top/FullNameContainer/LineEdit")
onready var shortname = get_node("PanelContainer/VBoxContainer/Top/ShortVerContainer/LineEdit")
onready var parametername = get_node("PanelContainer/VBoxContainer/Bottom/ParameterNameContainer/LineEdit")
onready var parametershort = get_node("PanelContainer/VBoxContainer/Bottom/ShortTerm/LineEdit")
onready var averagevalue = get_node("PanelContainer/VBoxContainer/Middle/AverageValueContainer/SpinBox")
onready var hasParameter = get_node("PanelContainer/VBoxContainer/Middle/ParameterCheckBox")

func _ready():
	adjustParameterState(false)
	pass

func adjustParameterState(boolean):
	parametername.set_editable(boolean)
	parametershort.set_editable(boolean)
	pass

func blank():
	shortname.set_text("")
	fullname.set_text("")
	averagevalue.set_value(0)
	hasParameter.set_pressed(false)
	parametername.set_text("")
	parametershort.set_text("")

func unclean(dict):
	shortname.set_text(dict.name)
	fullname.set_text(dict.fullname)
	averagevalue.set_value(dict.average)
	hasParameter.set_pressed(dict.hasParameter)
	adjustParameterState(dict.hasParameter)
	if dict.hasParameter:
		parametername.set_text(dict.parameter_fullname)
		parametershort.set_text(dict.parameter_name)
	else:
		parametername.set_text("")
		parametershort.set_text("")

func clean():
	var dict = { "name": shortname.get_text(), \
	"fullname": fullname.get_text(), \
	"average": averagevalue.get_val(), \
	"hasParameter": hasParameter.is_pressed() }
	if hasParameter.is_pressed():
		dict["parameter_fullname"] = parametername.get_text()
		dict["parameter_name"] = parametershort.get_text()
	return dict