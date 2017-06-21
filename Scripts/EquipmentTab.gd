tool
extends Container

onready var list = get_node("HBoxContainer/VBoxContainer/ItemList")
onready var name = get_node("HBoxContainer/PanelContainer/A/GridContainer/LineEdit")
onready var equipType = get_node("HBoxContainer/PanelContainer/A/GridContainer/OptionButton")
onready var desc = get_node("HBoxContainer/PanelContainer/PanelContainer/HBoxContainer/LineEdit")
onready var effectdialog = get_node("EffectWindow")

var statisticbox_obj = preload("../Scenes/StatisticBox.tscn")

onready var paramcontainer = get_node("HBoxContainer/PanelContainer/X/B/PanelContainer/GridContainer")
var spinboxes = []

var currentlyEditing = 0

#=================
# GODOT CALLBACKS
#=================

func _ready():
	set_process_unhandled_input(true)


func _unhandled_input(event):
	if !is_visible(): return
	if event.type == InputEvent.KEY:
		if event.scancode == KEY_DELETE and event.pressed and !event.echo: 
			deleteItem()


#====================
# SIGNAL DEFINITIONS
#====================

func aboutToShow():
	createParams()
	reloadList()


#==========
# BLANKING
#==========

func checkIfEmptyEntry(entry):
	return typeof(entry) != TYPE_DICTIONARY


#========================
# MODIFICATION FUNCTIONS
#========================

func nameChanged( text ):
	var item = get_parent().data.equipment[currentlyEditing]
	item.name = text
	var index = list.get_selected_items()[0]
	reloadList()
	list.select(index)


func equipmentTypeChanged(ID):
	var item = get_parent().data.equipment[currentlyEditing]
	print(equipType.get_item_metadata(ID))
	item.equipType = equipType.get_item_metadata(ID)


func descriptionChanged( text ):
	var item = get_parent().data.equipment[currentlyEditing]
	item.desc = text


func paramChanged( value, parameter ):
	get_parent().data.equipment[currentlyEditing].statistic[parameter] = value


func selectItem( index ):
	if (not list.is_item_selectable(index) or list.is_item_disabled(index)): return
	currentlyEditing = index
	changeToItem(currentlyEditing)


#=========
# REFRESH
#=========

func refreshTab():
	createParams()
	reloadList()
	refreshEquipmentTypeList()


func createParams():
	for i in paramcontainer.get_children():
		i.free()
	var tab = get_parent()
	spinboxes = []
	var v= 0
	for i in tab.data.system.statistic:
		if !checkIfEmptyEntry(i):
			var spinbox = statisticbox_obj.instance()
			paramcontainer.add_child(spinbox)
			spinbox.get_child(0).set_text(i.name.to_upper() + ":")
			spinboxes.append({ "obj": spinbox.get_child(1), "stat": v})
			spinbox.get_child(1).connect("value_changed", self, "paramChanged", [v])
		v += 1

func reloadList():
	list.clear()
	var v = 0
	var tab = get_parent()
	for i in tab.data.equipment:
		if i != null:
			var index = "[%04d] " % v
			list.add_item(index+i.name)
			v+=1

func refreshEquipmentTypeList():
	equipType.clear()
	var v = 0
	for i in get_parent().data.system.equipmentType:
		if !checkIfEmptyEntry(i):
			equipType.add_item(i.name)
			equipType.set_item_metadata(equipType.get_item_count()-1, v)
		v+=1


func changeToItem( index ):
	var item = initItem(get_parent().data.equipment[index])
	name.set_text(item.name)
	
	equipType.select(0)
	for i in range(equipType.get_item_count()):
		if equipType.get_item_metadata(i) == item.equipType:
			equipType.select(item.equipType)
			break
	
	desc.set_text(item.desc)
	for i in range(spinboxes.size()):
		var param = spinboxes[i].stat 
		if (item.statistic[param] == null): 
			item.statistic[param] = 0
		spinboxes[i].obj.set_value(item.statistic[param])


func initItem(item):
	var array = []
	var dict = {"name": "", "desc": "", "equipType": 0, "statistic": array}
	item.statistic.resize(get_parent().data.system.statistic.size())
	for i in item:
		dict[i] = item[i]
	
	return dict

#===================
# LIST MODIFICATION
#===================


func _addnewitem():
	var newdata = initItem({"name": "New Item"})
	get_parent().data.equipment.append(newdata)
	reloadList()
	list.select(list.get_item_count()-1)
	changeToItem(list.get_item_count()-1)


func deleteItem():
	get_parent().data.equipment.remove(currentlyEditing)
	reloadList()
	currentlyEditing = min(currentlyEditing, list.get_item_count()-1)
	list.select(currentlyEditing)


func createHelp():
	var string = "Help\nWhen editing entries, be sure to press enter before moving on.\nFailure to do so may result in data loss.\n\nKeys\nDelete: Delete an entry from a list."
	return string

func openEffectList():
	effectdialog.popup_centered()
	effectdialog.createOptionsList(get_parent().data.system.effectType)
	pass # replace with function body
