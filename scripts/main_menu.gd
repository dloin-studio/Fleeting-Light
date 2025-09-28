extends Node2D


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_credit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credit.tscn")


func _on_exite_pressed() -> void:
	get_tree().quit()
