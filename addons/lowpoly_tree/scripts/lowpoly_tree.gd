tool

extends Spatial

export(int) var _seed_value = null setget set_seed_value

var LowPolyBranch := load("res://addons/lowpoly_tree/scripts/lowpoly_branch.gd")
var LowPolyLeaves := load("res://addons/lowpoly_tree/scripts/lowpoly_leaves.gd")


func _ready() -> void:
	if _seed_value == null:
		set_seed_value(randi())
	else:
		generate()


func generate() -> void:
	if _seed_value != null:
		seed(_seed_value)

	# Remove existing children
	for child in get_children():
		if "LeavesMeshInstance" in child.name or "BranchMeshInstance" in child.name:
			child.queue_free()

	# Determines height of the tree
	var height := rand_range(2, 4)

	# Generate leaves mesh
	var leaves_node := LowPolyLeaves.new(height) as MeshInstance
	leaves_node.name = "LeavesMeshInstance"
	add_child(leaves_node)

	# Generate branch mesh
	var branch_node := LowPolyBranch.new(height) as MeshInstance
	branch_node.name = "BranchMeshInstance"
	add_child(branch_node)


func set_seed_value(seed_value: int) -> void:
	_seed_value = seed_value

	# Re-generate
	generate()
