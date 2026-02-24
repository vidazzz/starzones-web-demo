# SceneManager.gd
# 场景管理器

extends Node

var main_menu: Control
var identity_select: Control
var game_ui: Control

func _ready():
	# 添加到组以便其他脚本可以找到
	add_to_group("scene_manager")

	# 使用 call_deferred 确保场景完全加载后再查找节点
	call_deferred("_find_nodes_and_show_menu")

func _find_nodes_and_show_menu():
	# 从根节点开始查找
	var root = get_tree().root
	main_menu = root.find_child("MainMenu", true, false)
	identity_select = root.find_child("IdentitySelect", true, false)
	game_ui = root.find_child("GameUI", true, false)

	if not main_menu:
		push_error("SceneManager: MainMenu not found!")
	if not identity_select:
		push_error("SceneManager: IdentitySelect not found!")
	if not game_ui:
		push_error("SceneManager: GameUI not found!")
	else:
		print("SceneManager: All nodes found!")
		show_main_menu()

func show_main_menu():
	if main_menu:
		main_menu.visible = true
	if identity_select:
		identity_select.visible = false
	if game_ui:
		game_ui.visible = false

func show_identity_select():
	if main_menu:
		main_menu.visible = false
	if identity_select:
		identity_select.visible = true
	if game_ui:
		game_ui.visible = false

func show_game():
	if main_menu:
		main_menu.visible = false
	if identity_select:
		identity_select.visible = false
	if game_ui:
		game_ui.visible = true

	# 初始化 HexMap
	if game_ui and game_ui.has_method("setup_hex_map_internal"):
		game_ui.setup_hex_map_internal()

	update_game_ui()

func update_game_ui():
	if not game_ui:
		return
	if not game_ui.visible:
		return

	var gm = get_tree().get_first_node_in_group("game_manager")
	if not gm:
		return

	# 更新回合
	var turn_label = game_ui.get_node("TopBar/TopBarContent/TurnLabel")
	if turn_label:
		turn_label.text = "第 " + str(gm.turn_number) + " 回合"

	# 更新资源
	var credits_label = game_ui.get_node("TopBar/TopBarContent/Resources/CreditsLabel")
	if credits_label:
		credits_label.text = "💰 " + str(gm.credits)

	var fuel_label = game_ui.get_node("TopBar/TopBarContent/Resources/FuelLabel")
	if fuel_label:
		fuel_label.text = "⛽ " + str(gm.fuel)

	var minerals_label = game_ui.get_node("TopBar/TopBarContent/Resources/MineralsLabel")
	if minerals_label:
		minerals_label.text = "💎 " + str(gm.minerals)

	var research_label = game_ui.get_node("TopBar/TopBarContent/Resources/ResearchLabel")
	if research_label:
		research_label.text = "🔬 " + str(gm.research_points)

	# 更新界区信息
	var zone_name = game_ui.get_node("CenterPanel/ZoneInfo/InfoContent/ZoneName")
	if zone_name:
		zone_name.text = gm.current_zone.name

	var zone_type = game_ui.get_node("CenterPanel/ZoneInfo/InfoContent/ZoneType")
	if zone_type:
		zone_type.text = "超光速界区 (FTL)" if gm.current_zone.type == 0 else "光速受限界区"

	var zone_desc = game_ui.get_node("CenterPanel/ZoneInfo/InfoContent/ZoneDesc")
	if zone_desc:
		zone_desc.text = gm.current_zone.description

	var zone_stats = game_ui.get_node("CenterPanel/ZoneInfo/InfoContent/ZoneStats")
	if zone_stats:
		zone_stats.text = "科技等级: " + str(gm.current_zone.tech_level) + " | 威胁: " + str(gm.current_zone.threat_level)

	# 刷新六边形地图
	var hex_map_container = game_ui.get_node("HexMapContainer")
	if hex_map_container:
		for child in hex_map_container.get_children():
			if child is HexMap:
				child.refresh_map()
				break
