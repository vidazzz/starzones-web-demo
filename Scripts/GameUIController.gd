# GameUIController.gd
# 游戏界面控制器

extends Control

func _ready():
	get_node("BottomBar/ExploreButton").pressed.connect(_on_explore_pressed)
	get_node("BottomBar/BuildButton").pressed.connect(_on_build_pressed)
	get_node("BottomBar/FleetButton").pressed.connect(_on_fleet_pressed)
	get_node("BottomBar/EndTurnButton").pressed.connect(_on_end_turn_pressed)
	
	get_node("CenterPanel/ZoneInfo/InfoContent/TravelButton").pressed.connect(_on_travel_pressed)

func _on_explore_pressed():
	var gm = get_tree().get_first_node_in_group("game_manager")
	if not gm:
		return
	
	var undiscovered = []
	for z in gm.zones:
		if not z.discovered:
			undiscovered.append(z)
	
	if undiscovered.size() > 0:
		var rng = RandomNumberGenerator.new()
		var target = undiscovered[rng.randi() % undiscovered.size()]
		
		if gm.fuel >= 10:
			gm.fuel -= 10
			gm.explore_zone(target)
			print("探索发现: ", target.name)
	
	var scene_manager = get_tree().get_first_node_in_group("scene_manager")
	if scene_manager:
		scene_manager.update_game_ui()

func _on_build_pressed():
	print("建造系统 - 开发中")

func _on_fleet_pressed():
	print("舰队管理 - 开发中")

func _on_travel_pressed():
	var gm = get_tree().get_first_node_in_group("game_manager")
	if not gm:
		return
	
	var undiscovered = []
	for z in gm.zones:
		if not z.discovered:
			undiscovered.append(z)
	
	if undiscovered.size() > 0:
		var rng = RandomNumberGenerator.new()
		var target = undiscovered[rng.randi() % undiscovered.size()]
		
		if gm.travel_to_zone(target):
			print("前往: ", target.name)
	
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
