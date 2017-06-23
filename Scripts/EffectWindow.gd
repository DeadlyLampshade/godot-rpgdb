tool
extends ConfirmationDialog

#0 - Flat Amount (%s = "%.2f")
#1 - Multiplier (%s = "%.2fx")
#2 - Rate (%s = "%.2%%")
#3 - Element (%s: get from element list)
#4 - Parameter (%s: get short parameter name from statistic list)
#5 - Target (%s: 0 is self, 1 is enemy)
#6 - Statistic (%s: get short name from statistic list)


var effect_dict = {"type": 0, "args": []}

var effect_list

var currentlySelected = -1

var currentEffect = -1

var root
var controls = []

onready var details = get_node("VBoxContainer/VBoxContainer/PanelContainer 2/Label")
onready var input_container = get_node("VBoxContainer/VBoxContainer/PanelContainer3/GridContainer")
onready var options = get_node("VBoxContainer/PanelContainer/OptionButton")

func _ready():
	pass

func createOptionsList(dict):
	removeAllChildren()
	currentlySelected -= 1
	effect_list = dict
	options.clear()
	var v = 0
	for i in dict:
		options.add_item(i.name)
		options.set_item_metadata(options.get_item_count()-1, v)
		v += 1
	options.sort_items_by_text()

func removeAllChildren():
	controls = []
	for i in input_container.get_children():
		i.free()

func changeArgValue(value, index):
	var val = value
	if effect_dict.args[index].type == 3:
		val -= 2
	effect_dict.args[index].value = val

#===================
# CREATION COMMANDS
#===================

func createAmount(id):
	var spinbox = SpinBox.new()
	spinbox.set_max(99999)
	spinbox.set_min(-99999)
	spinbox.set_value(0)
	spinbox.set_step(0)
	spinbox.connect("value_changed", self, "changeArgValue", [id])
	effect_dict.args[id].value = 0
	return spinbox

func createRate(id):
	var spinbox = SpinBox.new()
	spinbox.set_max(100)
	spinbox.set_min(0)
	spinbox.set_value(0)
	spinbox.set_step(0)
	spinbox.connect("value_changed", self, "changeArgValue", [id])
	effect_dict.args[id].value = 0
	return spinbox

func createElementOptions(id):
	var optionbox = OptionButton.new()
	optionbox.add_item("Normal Attack")
	optionbox.add_item("All")
	for i in Globals.get("RPGDB_database").system.elements:
		optionbox.add_item(i.name)
	effect_dict.args[id].value = -2
	optionbox.connect("item_selected", self, "changeArgValue", [id])
	return optionbox

func createParameterOptions(id):
	var optionbox = OptionButton.new()
	for i in Globals.get("RPGDB_database").system.statistic:
		if (i.hasParameter): optionbox.add_item(i.parameter_fullname)
	optionbox.connect("item_selected", self, "changeArgValue", [id])
	effect_dict.args[id].value = 0
	return optionbox

func createTargetOptions(id):
	var optionbox = OptionButton.new()
	optionbox.add_item("Self")
	optionbox.add_item("Enemy")
	optionbox.connect("item_selected", self, "changeArgValue", [id])
	effect_dict.args[id].value = 0
	return optionbox

func createStatisticOptions(id):
	var optionbox = OptionButton.new()
	for i in Globals.get("RPGDB_database").system.statistic:
		optionbox.add_item(i.name)
	optionbox.connect("item_selected", self, "changeArgValue", [id])
	effect_dict.args[id].value = 0
	return optionbox

func parseDescription(desc):
	var i = 0
	var regex = RegEx.new() 
	regex.compile("({.*?})")
	
	while regex.find(desc, i) >= 0:
		
		# ADD EFFECT ARG AND CREATE REFERENCE TO THE NEW ARG
		
		effect_dict.args.append({"type": 0, "value": 0})
		var reference_id = effect_dict.args.size()-1
		
		i = regex.get_capture_start(1) + regex.get_capture(1).length()
		var string = regex.get_capture(1)
		string = string.substr(1, string.length()-2)
		
		var labl = Label.new()
		labl.set_text(string+": ")
		input_container.add_child(labl)
		
		var handled = false
		
		if string == "Multiplier":
			effect_dict.args[reference_id].type = 1
			var spinbox = createAmount(reference_id)
			input_container.add_child(spinbox)
			controls.append(spinbox)
			handled = true
		
		if string == "Amount":
			effect_dict.args[reference_id].type = 0
			var spinbox = createAmount(reference_id)
			input_container.add_child(spinbox)
			controls.append(spinbox)
			handled = true
		
		if string == "Rate" or string == "Percent":
			effect_dict.args[reference_id].type = 2
			labl.set_text(string+"(%): ")
			var spinbox = createRate(reference_id)
			input_container.add_child(spinbox)
			controls.append(spinbox)
			handled = true
		
		if string == "Element":
			effect_dict.args[reference_id].type = 3
			var optionbox = createElementOptions(reference_id)
			input_container.add_child(optionbox)
			controls.append(optionbox)
			handled = true
		
		if string == "Parameter":
			effect_dict.args[reference_id].type = 4
			var optionbox = createParameterOptions(reference_id)
			input_container.add_child(optionbox)
			controls.append(optionbox)
			handled = true
		
		if string == "Target":
			effect_dict.args[reference_id].type = 5
			var optionbox = createTargetOptions(reference_id)
			input_container.add_child(optionbox)
			controls.append(optionbox)
			handled = true
		
		if string == "Statistic" or string == "Stat":
			effect_dict.args[reference_id].type = 6
			var optionbox = createStatisticOptions(reference_id)
			input_container.add_child(optionbox)
			controls.append(optionbox)
			handled = true
		
		if !handled:
			input_container.add_child(Control.new())

func refreshControls( effect ):
	removeAllChildren()
	var actual_effect = options.get_item_metadata(effect)
	effect_dict = {"type": actual_effect, "args": []}
	parseDescription(effect_list[actual_effect].desc)


func onAccept():
	pass # replace with function body

func createEffect():
	createOptionsList(get_parent().get_parent().data.system.effectType)
	currentEffect = -1
	effect_dict = {"type": 0, "args": []}
	popup_centered()
	pass

func editEffect(effect):
	createOptionsList(get_parent().get_parent().data.system.effectType)
	effect_dict = effect
	var old_args = Array(effect_dict.args)
	effect_dict.args = []
	parseDescription(get_parent().get_parent().data.system.effectType[effect_dict.type].desc)
	effect_dict.args = old_args
	unclean()
	popup_centered()
	pass

func unclean():
	for i in range(effect_dict.args.size()):
		if controls[i] extends OptionButton:
			var offset = 0
			if effect_dict.args[i].type == 3:
				offset = -2
			controls[i].select(effect_dict.args[i].value - offset)
		if controls[i] extends SpinBox:
			controls[i].set_value(effect_dict.args[i].value)
	pass

func effectSelected( ID ):
	var string = effect_list[options.get_item_metadata(ID)].desc
	details.set_text(string)
	refreshControls(ID)
	pass # replace with function body
