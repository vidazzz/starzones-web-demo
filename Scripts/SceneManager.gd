# SceneManager.gd
# 场景管理器

extends Node

var main_menu: Control
var identity_select: Control
var game_ui: Control

func _ready():
	add_to_group("scene_manager")
	main_menu = get_node("MainMenu")
	identity_select = get_node("IdentitySelect")
	game_ui = get_node("GameUI")
	
	show_main_menu()

func show_main_menu():
	main_menu.visible = true
	identity_select.visible = false
	game_ui.visible = false

func show_identity_select():
	main_menu.visible = false
	identity_select.visible = true
	game_ui.visible = false

func show_game():
	main_menu.visible = false
	identity_select.visible = false
	game_ui.visible = true
	
	update_game_ui()

func update_game_ui():
	if not game_ui.visible:
		return
	
	var gm = get_tree().get_first_node_in_group("game_manager")
	if not gm:
		return
	
	# 更新回合
	var turn_label = game_ui.get_node("TopBar/TopBarContent/TurnLabel")
	turn_label.text = "第 " + str(gm.turn_number) + " 回合"
	
	# 更新资源
	var credits_label = game_ui.get_node("TopBar/TopBarContent/Resources/CreditsLabel")
	credits_label.text = "💰 " + str(gm.credits)
	
	var fuel_label = game_ui.get_node("TopBar/TopBarContent/Resources/FuelLabel")
	fuel_label.text = "⛽ " + str(gm.fuel)
	
	var minerals_label = game_ui.get_node("TopBar/TopBarContent/Resources/MineralsLabel")
	minerals_label.text = "💎 " + str(gm.minerals)
	
	var research_label = game_ui.get_node("TopBar/TopBarContent/Resources/ResearchLabel")
	research_label.text = "🔬 " + str(gm.research_points)
	
	# 更新界区信息
	var zone_name = game_ui.get_node("CenterPanel/ZoneInfo/InfoContent/ZoneName")
	zone_name.text = gm.current_zone.name
	
	var zone_type = game_ui.get_node("CenterPanel/ZoneInfo/InfoContent/ZoneType")
	zone_type.text = "超光速界区 (FTL)" if gm.current_zone.type == 0 else "光速受限界区"
	
	var zone_desc = game_ui.get_node("CenterPanel/ZoneInfo/InfoContent/ZoneDesc")
	zone_desc.text = gm.current_zone.description
	
	var zone_stats = game_ui.get_node("CenterPanel/ZoneInfo/InfoContent/ZoneStats")
	zone_stats.text = "科技等级: " + str(gm.current_zone.tech_level) + " | 威胁: " + str(gm.current_zone.threat_level)
