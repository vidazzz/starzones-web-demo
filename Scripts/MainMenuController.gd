# MainMenuController.gd
# 主菜单控制器

extends Control

func _ready():
	# 延迟一帧后再连接信号
	await get_tree().process_frame
	var start_button = get_node_or_null("StartButton")
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	var scene_manager = get_tree().get_first_node_in_group("scene_manager")
	if scene_manager:
		scene_manager.show_identity_select()
