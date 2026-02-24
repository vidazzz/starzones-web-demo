# GameUIController.gd
# 游戏界面控制器

extends Control

var hex_map: HexMap = null
var pending_zone = null  # 待确认移动的区域
var pending_fuel_cost = 0  # 待确认的燃料消耗

func _ready():
	# 延迟一帧后再连接信号
	await get_tree().process_frame
	_connect_signals()

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 如果区域信息面板正在显示，禁止点击地块
		var zone_info = get_node_or_null("CenterPanel/ZoneInfo")
		if zone_info and zone_info.visible:
			return

		if hex_map:
			var mouse_pos = get_global_mouse_position()
			# 检查点击了哪个地块
			for key in hex_map.hex_tiles:
				var tile = hex_map.hex_tiles[key]
				if tile.is_point_inside(mouse_pos):
					hex_map._on_hex_clicked(tile.hex_coords)
					break

func setup_hex_map_internal():
	var gm = get_tree().get_first_node_in_group("game_manager")
	if not gm:
		push_error("GameUIController: GameManager not found!")
		return
	if gm.zones.size() == 0:
		push_error("GameUIController: No zones generated!")
		return

	_create_hex_map(gm)

func _create_hex_map(gm):
	# 创建 HexMap 并添加到场景
	var HexMapScript = load("res://Scripts/HexMap.gd")
	hex_map = HexMapScript.new()

	var container = get_node_or_null("HexMapContainer")
	if container:
		container.add_child(hex_map)
		hex_map.generate_map(gm.zones)
		hex_map.move_requested.connect(_on_move_requested)
	else:
		push_error("GameUIController: HexMapContainer not found!")

func _on_move_requested(zone, fuel_cost):
	# 存储待确认的区域
	pending_zone = zone
	pending_fuel_cost = fuel_cost

	# 显示区域信息面板
	var zone_info = get_node_or_null("CenterPanel/ZoneInfo")
	if zone_info:
		zone_info.visible = true

	# 更新面板内容
	var zone_name = get_node_or_null("CenterPanel/ZoneInfo/InfoContent/ZoneName")
	if zone_name:
		zone_name.text = zone.name

	var zone_type = get_node_or_null("CenterPanel/ZoneInfo/InfoContent/ZoneType")
	if zone_type:
		zone_type.text = "超光速界区 (FTL)" if zone.type == 0 else "光速受限界区"

	var zone_desc = get_node_or_null("CenterPanel/ZoneInfo/InfoContent/ZoneDesc")
	if zone_desc:
		zone_desc.text = zone.description

	var zone_stats = get_node_or_null("CenterPanel/ZoneInfo/InfoContent/ZoneStats")
	if zone_stats:
		zone_stats.text = "科技等级: " + str(zone.tech_level) + " | 威胁: " + str(zone.threat_level)

	# 更新确认按钮文本
	var travel_btn = get_node_or_null("CenterPanel/ZoneInfo/InfoContent/TravelButton")
	if travel_btn:
		if not zone.discovered:
			travel_btn.text = "确认 (消耗 " + str(fuel_cost) + " 燃料)"
		else:
			travel_btn.text = "确认前往"

func _connect_signals():
	var build_btn = get_node_or_null("BottomBar/BuildButton")
	var fleet_btn = get_node_or_null("BottomBar/FleetButton")
	var end_turn_btn = get_node_or_null("BottomBar/EndTurnButton")
	var travel_btn = get_node_or_null("CenterPanel/ZoneInfo/InfoContent/TravelButton")

	if build_btn:
		build_btn.pressed.connect(_on_build_pressed)
	if fleet_btn:
		fleet_btn.pressed.connect(_on_fleet_pressed)
	if end_turn_btn:
		end_turn_btn.pressed.connect(_on_end_turn_pressed)
	if travel_btn:
		travel_btn.pressed.connect(_on_travel_pressed)

func _on_build_pressed():
	print("建造系统 - 开发中")

func _on_fleet_pressed():
	print("舰队管理 - 开发中")

func _on_travel_pressed():
	var gm = get_tree().get_first_node_in_group("game_manager")
	if not gm:
		return

	# 如果有待确认的区域，执行移动
	if pending_zone:
		# 未探索区域需要先消耗燃料探索
		if not pending_zone.discovered:
			gm.fuel -= pending_fuel_cost
			gm.explore_zone(pending_zone)
			# 探索后直接移动（不调用 travel_to_zone，避免重复扣燃料）
			gm.current_zone = pending_zone
			print("前往: ", pending_zone.name)
		else:
			# 已探索区域，调用 travel_to_zone（会扣除燃料）
			if gm.travel_to_zone(pending_zone):
				print("前往: ", pending_zone.name)

		# 隐藏区域信息面板
		var zone_info = get_node_or_null("CenterPanel/ZoneInfo")
		if zone_info:
			zone_info.visible = false

		# 清除待确认状态
		pending_zone = null
		pending_fuel_cost = 0

		# 更新 UI
		var scene_manager = get_tree().get_first_node_in_group("scene_manager")
		if scene_manager:
			scene_manager.update_game_ui()

func _on_end_turn_pressed():
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.next_turn()
	
	var scene_manager = get_tree().get_first_node_in_group("scene_manager")
	if scene_manager:
		scene_manager.update_game_ui()
