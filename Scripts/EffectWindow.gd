tool
extends ConfirmationDialog

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const EffectDetail = \
	[{'name': "Absorb/Recoil (Additional)", 'desc': "When attacking, adjust {Parameter} by {Amount}."},
	{'name': "Absorb/Recoil (Damage Mult.)", 'desc': "When attacking, adjust {Parameter} by {Multiplier} of damage taken."},
	{'name': "Absorb/Recoil (Max Percent.)", 'desc': "When attacking, adjust {Parameter} by a {Percent} of its maximum."},
	{'name': "Plunder (Additional)", 'desc': "When attacking, gain {Amount} in bonus gold."},
	{'name': "Plunder (Damage Mult.)", 'desc': "When attacking, gain bonus gold equal to a {Multiplier} of your damage."},
	{'name': "Inflict State", 'desc': "When attacking, have a {Rate} chance of inflicting {State} on {Target}."}]

onready var regex = RegEx.new()

var effect = {"type": 0}

var root

var details
var input_container
var options

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	details = get_node("VBoxContainer/VBoxContainer/PanelContainer 2/Label")
	input_container = get_node("VBoxContainer/VBoxContainer/PanelContainer3/GridContainer")
	options = get_node("VBoxContainer/PanelContainer/OptionButton")
	regex.compile("({.*?})", 1)
	options.clear()
	var v = 0
	for i in EffectDetail:
		var index = "[%03d] " % v
		options.add_item(index + i.name)
		v += 1
	effectSelected(0)

func removeAllChildren():
	for i in input_container.get_children():
		i.free()

func refreshControls( effect ):
	removeAllChildren()
	var i = 0
	while regex.find(EffectDetail[effect].desc, i) >= 0:
		i = regex.get_capture_start(1) + regex.get_capture(1).length()
		var string = regex.get_capture(1)
		string = string.substr(1, string.length()-2)
		print (string)
		var labl = Label.new()
		labl.set_text(string+": ")
		input_container.add_child(labl)
		
		if string == "Multiplier" or string == "Amount":
			var spinbox = SpinBox.new()
			spinbox.set_max(9999)
			spinbox.set_min(-9999)
			spinbox.set_value(0)
			spinbox.set_step(0)
			input_container.add_child(spinbox)
		
		if string == "Rate" or string == "Percent":
			labl.set_text(string+"(%): ")
			var spinbox = SpinBox.new()
			spinbox.set_max(100)
			spinbox.set_min(0)
			spinbox.set_value(0)
			spinbox.set_step(0)
			input_container.add_child(spinbox)
		
		if string == "Parameter":
			var optionbox = OptionButton.new()
			optionbox.add_item("HP")
			optionbox.add_item("MP")
			input_container.add_child(optionbox)
		
		if string == "State" or string == "Target":
			var optionbox = OptionButton.new()
			input_container.add_child(optionbox)


func onAccept():
	pass # replace with function body


func effectSelected( ID ):
	var string = EffectDetail[ID].desc
	details.set_text(string)
	refreshControls(ID)
	pass # replace with function body
