# HexMap.gd
# 六边形地图控制器

extends Node2D
class_name HexMap

signal move_requested(zone_data, fuel_cost)

@export var hex_size: float = 35.0
@export var map_radius: int = 12  # 地图半径 (12 ≈ 469 地块，满足300+要求)

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

	# 2. 确保有足够的格子（至少300个）
	while hex_coords_list.size() < 300:
		map_radius += 1
		hex_coords_list = _generate_spiral_hexagons(map_radius)

	# 3. 生成等高线高度图（使用同心圆+噪声）
	var height_map = _generate_contour_map(hex_coords_list)

	# 4. 将 ZoneData 分配到各个坐标
	var zone_index = 0
	for coords in hex_coords_list:
		if zone_index >= zones.size():
			break
		var zone = zones[zone_index]
		# 设置高度和界区层级
		zone.height = height_map[coords.hash()]
		zone.tier = _get_tier_from_height(zone.height)
		zone.tier_name = _get_tier_name(zone.tier)
		zone.description = _generate_tier_description(zone)
		_create_hex_tile(coords, zone)
		zone_index += 1

	# 5. 更新初始状态
	_update_tile_states()

# 生成等高线地图 - 使用同心圆 + 噪声
func _generate_contour_map(hex_coords_list: Array) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var height_map = {}
	var center = HexCoord.new(0, 0)

	# 找出最大距离
	var max_dist = 0.0
	for coords in hex_coords_list:
		var dist = hex_distance(center, coords)
		if dist > max_dist:
			max_dist = dist

	# 为每个坐标生成高度
	for coords in hex_coords_list:
		var dist = hex_distance(center, coords)
		var normalized_dist = dist / max_dist if max_dist > 0 else 0.0

		# 基础高度：中心低，边缘高（同心圆）
		var base_height = normalized_dist

		# 添加一些随机噪声变化
		var noise = rng.randf_range(-0.15, 0.15)

		# 限制高度在 0.0 - 1.0 范围内
		var height = clampf(base_height + noise, 0.0, 1.0)

		height_map[coords.hash()] = height

	return height_map

# 计算两个六边形之间的距离
func hex_distance(a, b) -> float:
	var a_s = -a.q - a.r
	var b_s = -b.q - b.r
	return (abs(a.q - b.q) + abs(a.r - b.r) + abs(a_s - b_s)) / 2.0

# 根据高度确定界区层级
func _get_tier_from_height(height: float) -> int:
	if height < 0.33:
		return 0  # 爬行界
	elif height < 0.66:
		return 1  # 飞跃界
	else:
		return 2  # 超限界

func _get_tier_name(tier: int) -> String:
	match tier:
		0: return "爬行界"
		1: return "飞跃界"
		2: return "超限界"
		_: return "未知界区"

func _generate_tier_description(zone) -> String:
	var tier_desc = ""
	match zone.tier:
		0:  # 爬行界
			tier_desc = "低地爬行界区，技术落后，光速限制严格。"
			zone.speed_limit = 0.5
			zone.can_ftl = false
			zone.can_warp = false
		1:  # 飞跃界
			tier_desc = "中高地飞跃界区，可以进行有限的超光速航行。"
			zone.speed_limit = 5.0
			zone.can_ftl = true
			zone.can_warp = false
		2:  # 超限界
			tier_desc = "高地超限界区，科技发达，可进行超光速航行和空间跳跃。"
			zone.speed_limit = 10.0
			zone.can_ftl = true
			zone.can_warp = true

	return tier_desc + " 科技等级: " + str(zone.tech_level) + " | 威胁: " + str(zone.threat_level)

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

	# 根据离开界区的类型决定燃料消耗
	# 爬行界：20, 飞跃界：10, 超限界：5
	var current_tier = 0
	if gm and gm.current_zone and "tier" in gm.current_zone:
		current_tier = gm.current_zone.tier

	var fuel_cost = 20
	match current_tier:
		0: fuel_cost = 20  # 爬行界
		1: fuel_cost = 10  # 飞跃界
		2: fuel_cost = 5   # 超限界

	# 发出移动请求信号，显示确认面板
	# 燃料扣除由 GameUIController 在用户确认后处理
	move_requested.emit(target_zone, fuel_cost)

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
