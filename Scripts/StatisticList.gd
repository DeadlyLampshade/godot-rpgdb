tool
extends VBoxContainer

signal value_changed

var statisticItem = preload("../Scenes/StatisticBox.tscn")

var values = []
var spinboxes = []

func getData():
	return Globals.get("RPGDB_database")

func _ready():
	pass

func checkIfEmptyEntry(entry):
	return typeof(entry) != TYPE_DICTIONARY

func adjustValue(value, i, control):
	var val = control.get_text().to_int()
	control.set_text(str(val))
	values[i] = val
	emit_signal("value_changed")

func createSpinbox():
	var box = statisticItem.instance()
	var spinbox = box.get_node("SpinBox")
	spinbox.set_text(str(0))
	return box

func refreshSpinboxes():
	# Ensures that all your statistics are displayed.
	# Called on tab refresh.
	for i in get_node("ParameterContainer").get_children():
		i.queue_free()
	for i in get_node("StatisticContainer").get_children():
		i.queue_free()
	
	# Discard all the previous values
	values = []
	spinboxes = []
	values.resize(getData().system.statistic.size())
	spinboxes.resize(getData().system.statistic.size())
	
	for i in range(getData().system.statistic.size()):
		
		var currentStatistic = getData().system.statistic[i]
		if !checkIfEmptyEntry(currentStatistic):
			var container = get_node("StatisticContainer")
			
			if currentStatistic.hasParameter:
				container = get_node("ParameterContainer")
			
			var box = createSpinbox()
			box.get_node("Label").set_text(currentStatistic.name + ":")
			box.get_node("SpinBox").connect("text_entered", self, "adjustValue", [i, box.get_node("SpinBox")], CONNECT_DEFERRED)
			spinboxes[i] = box.get_node("SpinBox")
			container.add_child(box)
		pass

func clean():
	return values


func unclean(parameters):
	# parameters is expected to be an array of values.
	values = []
	values.resize(getData().system.statistic.size())
	
	var params = parameters
	for i in range(parameters.size()):
		if params[i] == null: params[i] = 0
		if spinboxes[i] != null:
			spinboxes[i].set_text(str(params[i]))
		values[i] = params[i]