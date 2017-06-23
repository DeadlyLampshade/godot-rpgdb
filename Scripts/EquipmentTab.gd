tool
extends Container

onready var list = get_node("HBoxContainer/PanelContainer 2/VBoxContainer/ItemList")
onready var name = get_node("HBoxContainer/Inputs/A/GridContainer/LineEdit")
onready var equipType = get_node("HBoxContainer/Inputs/A/GridContainer/OptionButton")
onready var desc = get_node("HBoxContainer/Inputs/PanelContainer/HBoxContainer/LineEdit")
onready var effectdialog = get_node("EffectWindow")
onready var effectList = get_node("HBoxContainer/Inputs/X/PanelContainer 2/EffectList&Notes/ItemList")

onready var StatisticList = get_node("HBoxContainer/Inputs/X/B/PanelContainer/StatisticList")

var spinboxes = []

var currentlyEditing = -1
var currentList

#=================
# GODOT CALLBACKS
#=================

func _ready():
	StatisticList.connect("value_changed", self, "saveParams")
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


func removeBlankEntriesAtEnd(list):
	while checkIfEmptyEntry(list.back()):
		list.pop_back()


func findFirstEmptyEntry(array):
	if typeof(array) == TYPE_DICTIONARY:
		return -1
	else:
		return array.find("empty")


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
	item.equipType = equipType.get_item_metadata(ID)


func descriptionChanged( text ):
	var item = get_parent().data.equipment[currentlyEditing]
	item.desc = text


func saveParams():
	get_parent().data.equipment[currentlyEditing].statistic = StatisticList.clean()


func selectItem( index ):
	currentList = get_focus_owner()
	if (not list.is_item_selectable(index) or list.is_item_disabled(index)): return
	currentlyEditing = index
	if checkIfEmptyEntry(get_parent().data.equipment[currentlyEditing]):
		get_parent().data.equipment[currentlyEditing] = initItem({"name": "New Item"})
	changeToItem(currentlyEditing)


#=========
# REFRESH
#=========

func refreshTab():
	createParams()
	reloadList()
	refreshEquipmentTypeList()


func createParams():
	StatisticList.refreshSpinboxes()

func reloadList():
	list.clear()
	var tab = get_parent()
	for i in range(tab.data.equipment.size()):
		if !checkIfEmptyEntry(tab.data.equipment[i]):
			var index = "[%04d] " % i
			list.add_item(index+tab.data.equipment[i].name)
		else:
			list.add_item("###BLANK###")

func getDisplayName(effect):
	var effectTypes = get_parent().data.system.effectType
	var statistics = get_parent().data.system.statistic
	var elements = get_parent().data.system.elements
	
	var display = effectTypes[effect.type].display
	var v = 0
	for i in effect.args:
		var string_to_replace = "{%s}" % v
		var todisplay = ""
		
		if i.type == 0:
			todisplay = "%s" % i.value
			if sign(i.value) == 1:
				todisplay = "+" + todisplay
		if i.type == 1:
			todisplay = "%sx" % i.value
		if i.type == 2:
			todisplay = "%s%%" % i.value
		if i.type == 3:
			if i.value >= 0: todisplay = elements[i.value].name
			else:
				if i.value == -1: todisplay = "All"
				if i.value == -2: todisplay = "Normal Attack"
		if i.type == 4:
			todisplay = statistics[i.value].parameter_name
		if i.type == 5:
			if i.value == 0:
				todisplay = "Self"
			else:
				todisplay = "Target"
		if i.type == 6:
			todisplay = statistics[i.value].name
		display = display.replace(string_to_replace, todisplay)
		v+= 1
	return display

func reloadEffectList():
	effectList.clear()
	var effectTypes = get_parent().data.system.effectType
	if currentlyEditing >= 0:
		if !get_parent().data.equipment[currentlyEditing].has("effects"):
			get_parent().data.equipment[currentlyEditing].effects = []
		for i in get_parent().data.equipment[currentlyEditing].effects:
			var display_name = getDisplayName(i)
			effectList.add_item(display_name)

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
	StatisticList.unclean(item.statistic)
	reloadEffectList()


func initItem(item):
	var dict = {"name": "", "desc": "", "equipType": 0, "statistic": [], "effects": [] }
	if !item.has("statistic"):
		item.statistic = []
	dict.statistic.resize(get_parent().data.system.statistic.size())
	item.statistic.resize(get_parent().data.system.statistic.size())
	for i in item:
		dict[i] = item[i]
	return dict

#===================
# LIST MODIFICATION
#===================

func deleteItem():
	if currentList == effectList:
		get_parent().data.equipment[currentlyEditing].effects.remove(currentList.get_selected_items()[0])
		reloadEffectList()
		var currentEffect = min(currentList.get_selected_items()[0], effectList.get_item_count()-1)
		effectList.select(currentEffect)
	elif currentList == list:
		get_parent().data.equipment[currentlyEditing] = "empty"
		removeBlankEntriesAtEnd(get_parent().data.equipment)
		reloadList()
		currentlyEditing = min(currentlyEditing, list.get_item_count()-1)
		list.select(currentlyEditing)


func createHelp():
	var string = "Help\nWhen editing entries, be sure to press enter before moving on.\nFailure to do so may result in data loss.\n\nKeys\nDelete: Delete an entry from a list."
	return string

func openEffectList():
	if currentlyEditing > -1:
		effectdialog.createEffect()

func editEffect(index):
	var item = get_parent().data.equipment[currentlyEditing]
	effectdialog.currentEffect = index
	effectdialog.editEffect(get_parent().data.equipment[currentlyEditing].effects[index])

func createEffectOnItem():
	if effectdialog.currentEffect != -1:
		get_parent().data.equipment[currentlyEditing].effects[effectdialog.currentEffect] = effectdialog.effect_dict
	else:
		get_parent().data.equipment[currentlyEditing].effects.append(effectdialog.effect_dict)
	reloadEffectList()
	pass # replace with function body

func getList( index ):
	currentList = get_focus_owner()
	pass # replace with function body


func _addNewItem():
	var newdata = initItem({"name": "New Item"})
	if !get_parent().data.has("equipment"):
		get_parent().data.equipment
	var index = findFirstEmptyEntry(get_parent().data.equipment)
	if index == -1:
		get_parent().data.equipment.append(newdata)
		reloadList()
		list.select(list.get_item_count()-1)
		changeToItem(list.get_item_count()-1)
	else:
		get_parent().data.equipment[index] = newdata
		reloadList()
		list.select(index)
		changeToItem(index)
