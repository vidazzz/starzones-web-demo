# IdentitySelectController.gd
# 身份选择控制器

extends Control

func _ready():
	# 延迟一帧后再连接信号，确保所有子节点加载完成
	await get_tree().process_frame
	_connect_signals()

func _connect_signals():
	var explorer_btn = get_node_or_null("CardsContainer/ExplorerCard/VBox/ExplorerButton")
	var archaeologist_btn = get_node_or_null("CardsContainer/ArchaeologistCard/VBox/ArchaeologistButton")
	var scientist_btn = get_node_or_null("CardsContainer/ScientistCard/VBox/ScientistButton")
	var soldier_btn = get_node_or_null("CardsContainer/SoldierCard/VBox/SoldierButton")
	var back_btn = get_node_or_null("BackButton")

	if explorer_btn:
		explorer_btn.pressed.connect(func(): _on_identity_selected("explorer"))
	if archaeologist_btn:
		archaeologist_btn.pressed.connect(func(): _on_identity_selected("archaeologist"))
	if scientist_btn:
		scientist_btn.pressed.connect(func(): _on_identity_selected("scientist"))
	if soldier_btn:
		soldier_btn.pressed.connect(func(): _on_identity_selected("soldier"))
	if back_btn:
		back_btn.pressed.connect(_on_back_pressed)

func _on_identity_selected(identity_id: String):
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.start_new_game(identity_id)

	var scene_manager = get_tree().get_first_node_in_group("scene_manager")
	if scene_manager:
		scene_manager.show_game()

func _on_back_pressed():
	var scene_manager = get_tree().get_first_node_in_group("scene_manager")
	if scene_manager:
		scene_manager.show_main_menu()
