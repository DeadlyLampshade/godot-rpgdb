tool
extends EditorPlugin

const DATABASE_PATH = "res://database/"
const FILE_FORMAT = ".json"

var databaseWindow
var dock
var launcher
var options

var config

var options_settings = { "autosaveOnExit": true }

var rootdata = {}

#=================
# GODOT CALLBACKS
#=================
func _enter_tree():
	
	loadConfig()
	# We start up by loading our config file if we have it!
	# Their may be user settings that change up everything here
	
	createLauncherWindow()
	# Create our launcher window
	
	createOptionsWindow()
	# Create our options window.
	
	createLauncherDock()
	# Create the dock that appears with the plugin.
	
	createDatabaseWindow()
	# Creates the database window.
	
	loadDatabase()
	
	Globals.set("RPGDB_database", rootdata)


func _exit_tree():
	# Free ALL the docks and windows before vanishing.
	options.free()
	databaseWindow.free()
	dock.free()
	launcher.free()


#====================
# USER CONFIGURATION
#====================

func loadConfig():
	config = ConfigFile.new()
	var err = config.load("res://rpgdb.cfg")
	if err == OK:
		var config_info = {}
		config_info.autosaveOnExit = config.get_value("Saving", "autosaveOnExit", true)
		options_settings = config_info


func saveConfig():
	options_settings.autosaveOnExit = options.autosaveOnExit.is_pressed()
	config.set_value("Saving", "autosaveOnExit", options_settings.autosaveOnExit)
	config.save("res://rpgdb.cfg")


#=======================
# UI CREATION FUNCTIONS
#=======================

func createLauncherDock():
	dock = preload("res://addons/database_manager/Scenes/TestDock.tscn").instance()
	dock.connect("pressed", self, "displayLauncher")
	add_control_to_container(0 , dock)


func createLauncherWindow():
	launcher = preload("res://addons/database_manager/Scenes/Launcher.tscn").instance()
	launcher.get_node("VContainer/HContainer/Edit Database").connect("pressed", self, "displayDatabase") # Connects the pressed button to onDatabaseClick()
	launcher.get_node("VContainer/HContainer/Defaults/Save").connect("pressed", self, "saveDefaults") # Connects the pressed button to onDatabaseClick()
	launcher.get_node("VContainer/HContainer/Defaults/Load").connect("pressed", self, "loadDefaults") # Connects the pressed button to onDatabaseClick()
	launcher.get_node("VContainer/Options").connect("pressed", self, "displayOptions") # Connects the pressed button to onDatabaseClick()
	get_base_control().add_child(launcher)


func createOptionsWindow():
	options = preload("res://addons/database_manager/Scenes/OptionsWindow.tscn").instance()
	options.connect("hide", self, "saveConfig")
	get_base_control().add_child(options)


func createDatabaseWindow():
	databaseWindow = preload("res://addons/database_manager/Scenes/WindowDialog.tscn").instance()
	databaseWindow.connect("popup_hide", self, "checkIfSaveDatabase")
	databaseWindow.get_node("VBoxContainer/HBoxContainer 2/Save All").connect("pressed", self, "saveDatabase")
	get_base_control().add_child(databaseWindow)


#=================
# POPUP FUNCTIONS
#=================

func displayOptions():
	options.load_options(options_settings)
	options.popup_centered()


func displayDatabase():
	databaseWindow.popup_centered()


func displayLauncher():
	launcher.popup_centered()


#=========================
# DATABASE FUNCTIONS
#=========================

# SAVING
#--------

func checkIfSaveDatabase():
	if options_settings.autosaveOnExit:
		print("We saved!")
		saveDatabase()


func saveDatabase():
	# TODO: Support modded tabs.
	save_database("equipment", databaseWindow.tabContainer.data["equipment"])
	save_database("system", databaseWindow.tabContainer.data["system"])


func saveDefaults():
	var file = File.new()
	file.open(DATABASE_PATH + "default" + FILE_FORMAT, File.WRITE)
	file.store_line(rootdata.to_json())
	file.close()


# LOADING
#---------

func loadDatabase():
	var equipment_database = load_database("equipment")
	rootdata.equipment = equipment_database
	var terms_database = load_database("system")
	rootdata.system = terms_database


func loadDefaults():
	rootdata = {}
	var file = File.new()
	var dict = {}
	var file_position = DATABASE_PATH + "default" + FILE_FORMAT
	if file.file_exists(file_position):
		file.open(file_position, File.READ)
	dict.parse_json(file.get_as_text())
	file.close()
	rootdata = dict
	Globals.set("RPGDB_database", rootdata)


#=====================
# RAW DATABASE SAVING
#=====================

func save_database(database, data):
	var file = File.new()
	file.open(DATABASE_PATH + database + FILE_FORMAT, File.WRITE)
	var savedata = { "items": data }
	file.store_line(savedata.to_json())
	file.close()


func load_database(database):
	var file = File.new()
	var dict = {}
	var database_file = DATABASE_PATH + database + FILE_FORMAT
	if file.file_exists(database_file): 
		file.open(database_file, File.READ)
	dict.parse_json(file.get_as_text())
	file.close()
	return dict.items