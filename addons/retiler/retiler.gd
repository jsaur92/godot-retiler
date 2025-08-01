@tool
extends EditorPlugin

# A class member to hold the dock during the plugin life cycle.
# Code modified from the Godot docs. https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_plugins.html
var dock

func _enter_tree():
	# Initialization of the plugin goes here.
	# Load the dock scene and instantiate it.
	dock = preload("uid://ds88x6cqnfu42").instantiate()
	
	# Add the loaded scene to the docks.
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
	# Note that LEFT_UL means the left of the editor, upper-left dock.


func _exit_tree():
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_control_from_docks(dock)
	# Erase the control from the memory.
	dock.free()
