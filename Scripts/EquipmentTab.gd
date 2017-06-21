tool
extends Container

onready var list = get_node("HBoxContainer/VBoxContainer/ItemList")
onready var name = get_node("HBoxContainer/PanelContainer/A/GridContainer/LineEdit")
onready var equipType = get_node("HBoxContainer/PanelContainer/A/GridContainer/OptionButton")
onready var desc = get_node("HBoxContainer/PanelContainer/PanelContainer/HBoxContainer/LineEdit")

var statisticbox_obj = preload("../Scenes/StatisticBox.tscn")

onready var paramcontainer = get_node("HBoxContainer/PanelContainer/X/B/PanelContainer/GridContainer")
var spinboxes = []

var currentlyEditing = 0

func createParams():
	for i in paramcontainer.get_children():
		i.free()
	var tab = get_parent()
	spinboxes = []
	for i in tab.data.system.statistic:
		var spinbox = statisticbox_obj.instance()
		paramcontainer.add_child(spinbox)
		spinbox.get_child(0).set_text(i.name.to_upper() + ":")
		spinboxes.append(spinbox.get_child(1))
		var current_size = spinboxes.size()-1
		spinbox.get_child(1).connect("value_changed", self, "paramChanged", [current_size])

func refreshTab():
	createParams()
	reloadList()
	refreshEquipmentTypeList()
	pass

func paramChanged( value, parameter ):
	#print(get_parent().data.equipment[currentlyEditing])
	get_parent().data.equipment[currentlyEditing].statistic[parameter] = value

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_unhandled_input(true)
	pass

func _unhandled_input(event):
	if !is_visible(): return
	if event.type == InputEvent.KEY:
		if event.scancode == KEY_DELETE and event.pressed and !event.echo: 
			deleteItem()

func reloadList():
	list.clear()
	var v = 0
	var tab = get_parent()
	for i in tab.data.equipment:
		if i != null:
			var index = "[%04d] " % v
			list.add_item(index+i.name)
			v+=1

func aboutToShow():
	createParams()
	reloadList()
	pass # replace with function body

func changeToItem( index ):
	var item = initItem(get_parent().data.equipment[index])
	name.set_text(item.name)
	equipType.select(item.equipType)
	desc.set_text(item.desc)
	for i in range(spinboxes.size()):
		#print (i)
		if (item.statistic[i] == null): 
			item.statistic[i] = 0
		spinboxes[i].set_value(item.statistic[i])

func selectItem( index ):
	if (not list.is_item_selectable(index) or list.is_item_disabled(index)): return
	currentlyEditing = index
	changeToItem(currentlyEditing)

func nameChanged( text ):
	var item = get_parent().data.equipment[currentlyEditing]
	item.name = text
	var index = list.get_selected_items()[0]
	reloadList()
	list.select(index)
	pass # replace with function body

func refreshEquipmentTypeList():
	equipType.clear()
	for i in get_parent().data.system.equipmentType:
		equipType.add_item(i.name)

func equipmentTypeChanged(ID):
	var item = get_parent().data.equipment[currentlyEditing]
	item.equipType = ID

func initItem(item):
	var array = []
	var dict = {"name": "", "desc": "", "equipType": 0, "statistic": array}
	for i in item:
		if typeof(dict[i]) == 21:
			item[i].resize(get_parent().data.system.statistic.size())
		dict[i] = item[i]
	
	return dict

func _addnewitem():
	var newdata = initItem({"name": "New Item"})
	#print(get_parent().data.equipment)
	get_parent().data.equipment.append(newdata)
	reloadList()
	list.select(list.get_item_count()-1)
	changeToItem(list.get_item_count()-1)

func deleteItem():
	get_parent().data.equipment.remove(currentlyEditing)
	reloadList()
	currentlyEditing = min(currentlyEditing, list.get_item_count()-1)
	list.select(currentlyEditing)


func descriptionChanged( text ):
	var item = get_parent().data.equipment[currentlyEditing]
	item.desc = text
	pass # replace with function body

func createHelp():
	var string = "Help\nWhen editing entries, be sure to press enter before moving on.\nFailure to do so may result in data loss.\n\nKeys\nDelete: Delete an entry from a list."
	return string