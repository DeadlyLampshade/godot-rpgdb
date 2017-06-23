tool
extends Container

onready var elementDialog = get_node("ElementDialog")
onready var statisticDialog = get_node("StatisticsDialog")
onready var effectTypeDialog = get_node("EffectTypeDialog")
onready var equipmentTypeDialog = get_node("EquipmentTypeDialog")
onready var weaponTypeDialog = get_node("WeaponTypeDialog")
var weapontypeList
var elementList
var statisticList
var effectTypeList
var equipmentTypeList

var wasEditing = false
var editing = 0
var focus_list = ""

func getData():
	return get_parent().data.system

#=================
# GODOT CALLBACKS
#=================

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	setupWeaponTypeList()
	setupElementList()
	setupStatisticList()
	setupEffectTypeList()
	setupEquipmentTypeList()
	
	get_node("VBoxContainer/PanelContainer1/HBoxContainer/ElementContainer/Button").connect("pressed", self, "createNewElement")
	set_process_unhandled_input(true)
	pass


func _unhandled_input(event):
	if !is_visible() and !has_focus(): return
	if event.type == InputEvent.KEY:
		if event.scancode == KEY_DELETE and event.pressed and !event.echo: 
			deleteItemFromList()
			accept_event()


#===========================
# SMALL IMPORTANT FUNCTIONS
#===========================

func refreshTab():
	# Gets called whenever we enter the tab again!
	reloadAllLists()
	pass

func createHelp():
	# Provides information to the help button.
	var string = "Controls\nDelete Key: Delete an entry from a list.\nDouble-Click over Entry: Edit the entry."
	return string


func blankEditing():
	wasEditing = false


#==========
# BLANKING
#==========

func removeBlankEntriesAtEnd():
	while checkIfEmptyEntry(getData()[focus_list].back()):
		getData()[focus_list].pop_back()


func findFirstEmptyEntry(array):
	return array.find("empty")


#=================
# SETUP FOR LISTS
#=================

func setupWeaponTypeList():
	weapontypeList= get_node("VBoxContainer/PanelContainer1/HBoxContainer/WeaponContainer/ItemList")
	weapontypeList.connect("item_activated", self, "editWeaponType")
	weapontypeList.connect("item_selected", self, "setIndex")
	weapontypeList.connect("focus_enter", self, "setEditingList", ["weaponType"])
	pass

func setupElementList():
	elementList = get_node("VBoxContainer/PanelContainer1/HBoxContainer/ElementContainer/ItemList")
	elementList.connect("item_activated", self, "editElement")
	elementList.connect("item_selected", self, "setIndex")
	elementList.connect("focus_enter", self, "setEditingList", ["elements"])


func setupStatisticList():
	statisticList = get_node("VBoxContainer/PanelContainer1/HBoxContainer/StatisticContainer/ItemList")
	statisticList.connect("item_activated", self, "editStatistic")
	statisticList.connect("item_selected", self, "setIndex")
	statisticList.connect("focus_enter", self, "setEditingList", ["statistic"])


func setupEffectTypeList():
	effectTypeList = get_node("VBoxContainer/PanelContainer/HBoxContainer/EffectsContainer/ItemList")
	effectTypeList.connect("item_activated", self, "editEffectType")
	effectTypeList.connect("item_selected", self, "setIndex")
	effectTypeList.connect("focus_enter", self, "setEditingList", ["effectType"])


func setupEquipmentTypeList():
	equipmentTypeList = get_node("VBoxContainer/PanelContainer1/HBoxContainer/EquipmentContainer/ItemList")
	equipmentTypeList.connect("item_activated", self, "editEquipmentType")
	equipmentTypeList.connect("item_selected", self, "setIndex")
	equipmentTypeList.connect("focus_enter", self, "setEditingList", ["equipmentType"])


#==============
# LIST EDITING
#==============

func setEditingList(list):
	focus_list = list


func setIndex(index):
	editing = index


func deleteItemFromList():
	getData()[focus_list][editing] = "empty"
	removeBlankEntriesAtEnd()
	reloadSelectedList(focus_list)


#==========
# ELEMENTS
#==========

func createNewElement():
	wasEditing = false
	elementDialog.popup_centered()


func finishNewElement():
	if wasEditing:
		getData().elements[editing] = elementDialog.clean()
		wasEditing = false
	else:
		var index = findFirstEmptyEntry(getData().elements)
		if index == -1:
			getData().elements.append(elementDialog.clean())
		else:
			getData().elements[index] = elementDialog.clean()
	reloadElementList()
	pass # replace with function body


func editElement(index):
	wasEditing = true
	editing = index
	if checkIfEmptyEntry(getData().elements[editing]):
		elementDialog.blank()
		elementDialog.popup_centered()
	else:
		elementDialog.unclean(getData().elements[editing])
		elementDialog.popup_centered()


#===========
# RELOADING
#===========

func reloadAllLists():
	if !is_visible(): return
	reloadElementList()
	reloadStatisticList()
	reloadEffectTypeList()
	reloadEquipmentTypeList()
	reloadWeaponTypeList()


func reloadSelectedList(string):
	if string == "elements":
		reloadElementList()
	if string == "statistic":
		reloadStatisticList()
	if string == "effectType":
		reloadEffectTypeList()
	if string == "equipmentType":
		reloadEquipmentTypeList()
	if string == "weaponType":
		reloadWeaponTypeList()

func checkIfEmptyEntry(entry):
	return typeof(entry) != TYPE_DICTIONARY


func reloadElementList():
	elementList.clear()
	var v = 0
	for i in getData().elements:
		if checkIfEmptyEntry(i):
			elementList.add_item("###BLANK###")
		else:
			var index = "[%02d] " % v
			elementList.add_item(index + i.name)
		v += 1


func reloadEffectTypeList():
	effectTypeList.clear()
	var v = 0
	if !getData().has("effectType"): getData().effectType = []
	for i in getData().effectType:
		if checkIfEmptyEntry(i):
			effectTypeList.add_item("###BLANK###")
		else:
			var index = "[%03d] " % v
			effectTypeList.add_item(index+i.name)
		v += 1


func reloadEquipmentTypeList():
	equipmentTypeList.clear()
	var v = 0
	if !getData().has("equipmentType"): getData().equipmentType = []
	for i in getData().equipmentType:
		if checkIfEmptyEntry(i):
			equipmentTypeList.add_item("###BLANK###")
		else:
			var index = "[%02d] " % v
			equipmentTypeList.add_item(index+i.name)
		v+= 1


func reloadStatisticList():
	statisticList.clear()
	var v = 0
	for i in getData().statistic:
		if checkIfEmptyEntry(i):
			statisticList.add_item("###BLANK###")
		else:
			var index = "[%02d] " % v
			statisticList.add_item(index + i.fullname)
		v += 1


#============
# STATISTICS
#============

func addStatistic():
	wasEditing = false
	statisticDialog.blank()
	statisticDialog.popup_centered()
	pass # replace with function body


func confirmNewStatistic():
	if wasEditing:
		getData().statistic[editing] = statisticDialog.clean()
		wasEditing = false
	else:
		var index = findFirstEmptyEntry(getData().statistic)
		if index == -1:
			getData().statistic.append(statisticDialog.clean())
		else:
			getData().statistic[index] = statisticDialog.clean()
	getData().statistic.sort_custom(self, "sortStatistic")
	reloadStatisticList()
	pass # replace with function body


func editStatistic(index):
	wasEditing = true
	editing = index
	if checkIfEmptyEntry(getData().statistic[editing]):
		statisticDialog.blank()
		statisticDialog.popup_centered()
	else:
		statisticDialog.unclean(getData().statistic[editing])
		statisticDialog.popup_centered()

#==============
# EFFECT TYPES
#==============

func createEffectType():
	wasEditing = false
	effectTypeDialog.blank()
	effectTypeDialog.popup_centered()


func confirmNewEffectType():
	if wasEditing:
		getData().effectType[editing] = effectTypeDialog.clean()
		wasEditing = false
	else:
		var index = findFirstEmptyEntry(getData().effectType)
		if index == -1:
			getData().effectType.append(effectTypeDialog.clean())
		else:
			getData().effectType[index] = effectTypeDialog.clean()
	reloadEffectTypeList()


func editEffectType(index):
	wasEditing = true
	editing = index
	if checkIfEmptyEntry(getData().effectType[editing]):
		effectTypeDialog.blank()
		effectTypeDialog.popup_centered()
	else:
		effectTypeDialog.unclean(getData().effectType[editing])
		effectTypeDialog.popup_centered()

#=================
# EQUIPMENT TYPES
#=================

func newEquipmentType():
	wasEditing = false
	equipmentTypeDialog.blank()
	equipmentTypeDialog.popup_centered()


func applyEquipmentType():
	if wasEditing:
		getData().equipmentType[editing] = equipmentTypeDialog.clean()
		wasEditing=false
	else:
		var index = findFirstEmptyEntry(getData().equipmentType)
		if index == -1:
			getData().equipmentType.append(equipmentTypeDialog.clean())
		else:
			getData().equipmentType[index] = equipmentTypeDialog.clean()
	reloadEquipmentTypeList()


func editEquipmentType( index ):
	wasEditing = true
	editing = index
	if checkIfEmptyEntry(getData().equipmentType[editing]):
		equipmentTypeDialog.blank()
		equipmentTypeDialog.popup_centered()
	else:
		equipmentTypeDialog.unclean( getData().equipmentType[editing] )
		equipmentTypeDialog.popup_centered()

func editWeaponType( index ):
	wasEditing = true
	editing = index
	if checkIfEmptyEntry(getData().weaponType[editing]):
		weaponTypeDialog.blank()
		weaponTypeDialog.popup_centered()
	else:
		weaponTypeDialog.unclean( getData().weaponType[editing] )
		weaponTypeDialog.popup_centered()


#=========
# SORTING
#=========

func sortStatistic(a,b):
	return a.hasParameter == true and b.hasParameter == false

#=============
# WEAPON TYPE
#=============

func applyWeaponType():
	if !getData().has("weaponType"): getData().weaponType = []
	if wasEditing:
		getData().weaponType[editing] = weaponTypeDialog.clean()
		wasEditing=false
	else:
		var index = findFirstEmptyEntry(getData().weaponType)
		if index == -1:
			getData().weaponType.append(weaponTypeDialog.clean())
		else:
			getData().weaponType[index] = weaponTypeDialog.clean()
	reloadWeaponTypeList()

func reloadWeaponTypeList():
	weapontypeList.clear()
	for i in range(getData().weaponType.size()):
		if checkIfEmptyEntry(getData().weaponType[i]):
			print(i)
			weapontypeList.add_item("###BLANK###")
		else:
			var index = "[%02d] %s" % [i, getData().weaponType[i].name]
			weapontypeList.add_item(index)

func newWeaponType():
	wasEditing = false
	weaponTypeDialog.blank()
	weaponTypeDialog.popup_centered()
