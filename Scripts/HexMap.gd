# HexMap.gd
# 六边形地图控制器

extends Node2D
class_name HexMap

signal move_requested(zone_data, fuel_cost)

@export var hex_size: float = 50.0
@export var map_radius: int = 2  # 地图半径

var hex_tiles: Dictionary = {}  # hex_coords hash -> HexTile

# 6个方向的偏移量 (q, r)
const DIRECTIONS = [
	[1, 0], [1, -1], [0, -1],
	[-1, 0], [-1, 1], [0, 1]
]

func _ready():
	add_to_group("hex_map")
	# 创建舰队标记
	_create_fleet_marker()

var fleet_marker: Label = null

func _create_fleet_marker():
	fleet_marker = Label.new()
	fleet_marker.text = "🚀"
	fleet_marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fleet_marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fleet_marker.add_theme_font_size_override("font_size", 24)
	add_child(fleet_marker)

func _update_fleet_marker():
	if not fleet_marker:
		return
	var gm = get_tree().get_first_node_in_group("game_manager")
	if not gm or not gm.current_zone:
		return

	# 找到当前区域的坐标
	for key in hex_tiles:
		var tile = hex_tiles[key]
		if tile.zone_data == gm.current_zone:
			# 舰队标记放在地块中心向上一点的位置
			fleet_marker.position = tile.position + Vector2(0, -30)
			fleet_marker.visible = true
			break

# 简单的坐标类
class HexCoord:
	var q: int
	var r: int
	func _init(q_val: int = 0, r_val: int = 0):
		q = q_val
		r = r_val
	func hash() -> String:
		return str(q) + "," + str(r)
	func _to_string() -> String:
		return "HexCoord(%d, %d)" % [q, r]

# 轴坐标转换为屏幕像素坐标
static func axial_to_pixel(hex, size: float) -> Vector2:
	var x = size * (sqrt(3) * hex.q + sqrt(3) / 2.0 * hex.r)
	var y = size * (3.0 / 2.0 * hex.r)
	return Vector2(x, y)

func generate_map(zones: Array):
	# 1. 生成六边形网格坐标
	var hex_coords_list = _generate_spiral_hexagons(map_radius)

	# 2. 确保有足够的格子
	if hex_coords_list.size() < zones.size():
		var new_radius = map_radius + 1
		while hex_coords_list.size() < zones.size():
			hex_coords_list = _generate_spiral_hexagons(new_radius)
			new_radius += 1

	# 3. 将 ZoneData 分配到各个坐标
	var zone_index = 0
	for coords in hex_coords_list:
		if zone_index >= zones.size():
			break
		var zone = zones[zone_index]
		_create_hex_tile(coords, zone)
		zone_index += 1

	# 4. 更新初始状态
	_update_tile_states()

# 生成螺旋六边形网格（从中心向外）
func _generate_spiral_hexagons(radius: int) -> Array:
	var result = []
	result.append(HexCoord.new(0, 0))  # 中心

	for r in range(1, radius + 1):
		var coords = HexCoord.new(-r, r)  # 起始位置
		for i in range(6):
			for _j in range(r):
				result.append(HexCoord.new(coords.q, coords.r))
				coords = _next_hex(coords, i)

	return result

# 获取下一个六边形坐标
func _next_hex(hex, direction: int) -> HexCoord:
	var d = DIRECTIONS[direction]
	return HexCoord.new(hex.q + d[0], hex.r + d[1])

# 创建六边形瓦片
func _create_hex_tile(coords, zone):
	var hex_scene = preload("res://Scenes/HexTile.tscn")
	var tile = hex_scene.instantiate()
	tile.hex_size = hex_size
	tile.setup(coords, zone)
	tile.hex_clicked.connect(_on_hex_clicked)
	add_child(tile)

	var key = coords.hash()
	hex_tiles[key] = tile

# 检查目标地块是否为当前所在地块的邻居
func _is_adjacent(target_coords) -> bool:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if not gm or not gm.current_zone:
		return false

	# 找到当前所在地块的坐标
	var current_coords = null
	for key in hex_tiles:
		var tile = hex_tiles[key]
		if tile.zone_data == gm.current_zone:
			current_coords = tile.hex_coords
			break

	if not current_coords:
		return false

	# 检查距离是否为1（相邻）
	# s = -q - r
	var target_s = -target_coords.q - target_coords.r
	var current_s = -current_coords.q - current_coords.r

	var distance = (abs(target_coords.q - current_coords.q) +
					abs(target_coords.r - current_coords.r) +
					abs(target_s - current_s)) / 2
	return distance <= 1

# 处理六边形点击 - 发出移动请求信号
func _on_hex_clicked(coords):
	var key = coords.hash()
	var tile = hex_tiles.get(key)
	if not tile or not tile.zone_data:
		return

	# 检查是否为邻近地块
	if not _is_adjacent(coords):
		return

	var gm = get_tree().get_first_node_in_group("game_manager")
	if not gm:
		return

	var target_zone = tile.zone_data
	var fuel_cost = 10 if target_zone.type == 0 else 20

	# 检查燃料是否足够（探索+移动需要相同的燃料）
	if gm.fuel < fuel_cost:
		print("燃料不足，无法前往！")
		return

	# 发出移动请求信号，显示确认面板
	move_requested.emit(target_zone, fuel_cost)
	if gm.travel_to_zone(target_zone):
		# 更新地图状态（显示新位置等）
		_update_tile_states()

# 更新所有瓦片状态
func _update_tile_states():
	var gm = get_tree().get_first_node_in_group("game_manager")
	if not gm:
		return

	for key in hex_tiles:
		var tile = hex_tiles[key]
		var zone = tile.zone_data
		if zone:
			tile.set_revealed(zone.discovered)
			tile.set_current(zone == gm.current_zone)

	# 更新舰队标记位置
	_update_fleet_marker()

# 公开方法：刷新地图
func refresh_map():
	_update_tile_states()
