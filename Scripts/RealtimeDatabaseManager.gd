tool
extends TabContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var super_parent
var data setget ,GetData

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func GetData():
	return Globals.get("RPGDB_database")

func runTabRefresh( tab ):
	get_current_tab_control().refreshTab()
	pass # replace with function body
