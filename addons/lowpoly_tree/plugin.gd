tool
extends EditorPlugin

var LowPolyTree := load("res://addons/lowpoly_tree/scripts/lowpoly_tree.gd")


func _enter_tree():
	add_custom_type(
		"LowPolyTree", "Spatial", LowPolyTree, preload("res://addons/lowpoly_tree/icons/tree.svg")
	)


func _exit_tree():
	remove_custom_type("LowPolyTree")
