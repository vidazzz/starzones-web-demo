# GameManager.gd
# 游戏管理器

extends Node

var player_name: String = "Commander"
var player_identity: Dictionary

var turn_number: int = 1
var credits: int = 1000
var research_points: int = 0

var fuel: int = 50
var minerals: int = 30

var fleet: Array = []
var zones: Array = []
var current_zone: Object

var discovered_zone_count: int = 1
var total_zones: int = 350  # 300+ 地块
var story_fragments: Array = []

enum GamePhase { MENU, IDENTITY_SELECT, PLAYING, PAUSED, GAME_OVER }
var current_phase: int = GamePhase.MENU

func _ready():
	add_to_group("game_manager")
	print("Star Zones - Game Manager Initialized")
	
	# 初始舰队
	var ship_db = load("res://Scripts/ShipDB.gd").new()
	fleet.append(ship_db.get_ship(0))  # Scout

func start_new_game(identity_id: String):
	var identity_db = load("res://Scripts/IdentityDB.gd").new()
	player_identity = identity_db.get_identity(identity_id)
	
	turn_number = 1
	credits = player_identity.get("start_credits", 1000)
	research_points = player_identity.get("start_research", 0)
	fuel = 50
	minerals = 30
	
	# 初始舰队
	var ship_db = load("res://Scripts/ShipDB.gd").new()
	fleet = [ship_db.get_ship(0)]
	
	# 生成星系
	var zone_db = load("res://Scripts/ZoneDB.gd").new()
	zones = zone_db.generate_galaxy(total_zones)
	current_zone = zones[0]
	discovered_zone_count = 1
	story_fragments.clear()
	
	current_phase = GamePhase.PLAYING
	
	print("New game started as ", player_identity.get("name", "Unknown"))

func next_turn():
	turn_number += 1
	
	# 资源产出
	fuel += current_zone.fuel_production
	minerals += current_zone.mineral_production
	research_points += current_zone.research_production
	
	print("Turn ", turn_number, " - Zone: ", current_zone.name)

func explore_zone(zone):
	if zone.discovered:
		return
	
	zone.discovered = true
	discovered_zone_count += 1
	
	if zone.story_fragment != "":
		story_fragments.append(zone.story_fragment)
	
	print("Discovered new zone: ", zone.name)

func travel_to_zone(target_zone):
	# 根据离开界区的类型决定燃料消耗
	# 爬行界：20, 飞跃界：10, 超限界：5
	var current_tier = current_zone.tier if "tier" in current_zone else 0
	var fuel_cost = 20
	match current_tier:
		0: fuel_cost = 20  # 爬行界
		1: fuel_cost = 10  # 飞跃界
		2: fuel_cost = 5   # 超限界

	if fuel < fuel_cost:
		print("Not enough fuel!")
		return false

	# 检查燃料后再探索
	if not target_zone.discovered:
		explore_zone(target_zone)

	fuel -= fuel_cost
	current_zone = target_zone

	print("Traveled to ", target_zone.name, " (cost: ", fuel_cost, " fuel)")
	return true

func purchase_ship(ship_type: int):
	var ship_db = load("res://Scripts/ShipDB.gd").new()
	var ship = ship_db.get_ship(ship_type)
	
	if credits < ship.cost:
		print("Not enough credits!")
		return false
	
	credits -= ship.cost
	fleet.append(ship)
	
	print("Purchased ", ship.name)
	return true
