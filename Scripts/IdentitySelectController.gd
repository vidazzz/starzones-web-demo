# IdentitySelectController.gd
# 身份选择控制器

extends Control

func _ready():
	get_node("Identities/ExplorerCard/ExplorerContent/ExplorerButton").pressed.connect(func(): _on_identity_selected("explorer"))
	get_node("Identities/ArchaeologistCard/ArchaeologistContent/ArchaeologistButton").pressed.connect(func(): _on_identity_selected("archaeologist"))
	get_node("Identities/ScientistCard/ScientistContent/ScientistButton").pressed.connect(func(): _on_identity_selected("scientist"))
	get_node("Identities/SoldierCard/SoldierContent/SoldierButton").pressed.connect(func(): _on_identity_selected("soldier"))
	
	get_node("BackButton").pressed.connect(_on_back_pressed)

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
