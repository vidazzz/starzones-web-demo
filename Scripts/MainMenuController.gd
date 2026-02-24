# MainMenuController.gd
# 主菜单控制器

extends Control

func _ready():
	var start_button = get_node("StartButton")
	start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	var scene_manager = get_tree().get_first_node_in_group("scene_manager")
	if scene_manager:
		scene_manager.show_identity_select()
