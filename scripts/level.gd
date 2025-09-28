extends Node2D

# ----------------- NODE REFERENCES -----------------
# Reference to the Player (using CharacterBody2D hint as player.gd extends it)
@onready var player: CharacterBody2D = $Player
# Assuming $AcceptDialog is your WIN dialog (Win Dialog)
@onready var win_dialog: AcceptDialog = $AcceptDialog
# Assumes you added a new dialog for the lose state
@onready var lose_dialog: AcceptDialog = $LoseDialog
# NOTE: Using CanvasModulate, ensure the node name matches exactly.
@onready var world_darkness: CanvasModulate = $WorldDarkness
# Reference to the Label node for displaying the torch core score
@onready var core_label: Label = $Label

# Game state
var Game_end: bool = false


func _ready() -> void:
	# 1. Connect the Player's custom signals (Game Over and Core Update)
	player.game_over_by_darkness.connect(_on_player_game_over_by_darkness)
	player.torch_core_updated.connect(_on_player_torch_core_updated)
	
	# 2. Set the entire world to be dark by default (relying on the torch light)
	# NOTE: We are setting Color here, but you should use a ColorRect node type for robustness!
	world_darkness.color = Color(0, 0, 0, 1) # Black, opaque
	
	# 3. Ensure dialog messages are set
	lose_dialog.dialog_text = "Torch ran out of power! You lose."
	win_dialog.dialog_text = "All boxes placed! You Win!"
	
	# 4. Initialize the score display
	_on_player_torch_core_updated(player.torch_core)


func _process(_delta: float) -> void:
	# Only run the check_end logic if the game is not paused AND not already won/lost
	if not Game_end and not get_tree().paused:
		check_end()
	pass


func check_end():
	# CRITICAL CHECK: Ensure the $Spots node exists before trying to access it.
	# The original crash happened here because $Spots was null.
	if not is_instance_valid($Spots):
		# If the node is missing, print an error and stop checking the end condition.
		push_error("ERROR: The 'Spots' container node is missing from the scene. Please add a node named 'Spots'.")
		return

	# This logic works for any number of spots/boxes
	var spots_to_fill = $Spots.get_child_count()
	var spots_filled = 0
	
	# Iterate over all spot nodes
	for spot in $Spots.get_children():
		# Check the custom 'in_spot' property defined in spot.gd
		# The spot variable must be a node with the spot.gd script attached.
		if spot.in_spot:
			spots_filled += 1

	# If the number of filled spots equals the total number of spots (1 in your case)
	if spots_filled == spots_to_fill:
		win_dialog.popup()
		Game_end = true
		get_tree().paused = true # Pause on win
	pass

# ----------------- UI UPDATE HANDLER -----------------

# Receives signal from player.gd and updates the score label
func _on_player_torch_core_updated(new_value: float) -> void:
	core_label.text = "Core: " + str(round(new_value)) + "%"

# ----------------- NEW LOSE CONDITION HANDLER -----------------

# This function is called when the signal from player.gd fires (torch_core <= 0)
func _on_player_game_over_by_darkness() -> void:
	# Set Game_end to true and pause the tree
	Game_end = true
	get_tree().paused = true
	
	# Show the dedicated lose dialog
	lose_dialog.popup()


# ----------------- RESTART FUNCTIONS (Win Dialog) -----------------

func _on_accept_dialog_confirmed() -> void:
	# 1. Unpause the game tree
	get_tree().paused = false
	# 2. Reload the scene (this also resets the Game_end variable)
	get_tree().reload_current_scene()


func _on_accept_dialog_canceled() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
# ----------------- RESTART FUNCTIONS (Lose Dialog) -----------------

func _on_lose_dialog_confirmed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_lose_dialog_canceled() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
