extends Area2D

# This variable is read by the level.gd script to check if this spot is occupied.
var in_spot: bool = false

# Connect these two signals from the Godot Editor for this script to work!
# Node -> Signals -> body_entered(body)
# Node -> Signals -> body_exited(body)

# Called when a body (like the box) enters this spot
func _on_body_entered(body: Node2D) -> void:
	# Assuming your boxes are in the "box" group
	if body.is_in_group("box"):
		in_spot = true
		# The Level script will check the win condition on the next _process call
	pass

# Called when a body (like the box) leaves this spot
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("box"):
		in_spot = false
		# No need to check for win here
	pass
