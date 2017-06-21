tool
extends TabContainer

var super_parent
var data setget ,GetData

func GetData():
	return Globals.get("RPGDB_database")

func runTabRefresh( tab ):
	get_current_tab_control().refreshTab()
	pass # replace with function body
