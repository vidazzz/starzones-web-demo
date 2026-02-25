# HexTile.gd
# 单个六边形地块

extends Area2D
class_name HexTile

signal hex_clicked(hex_coords)

@export var hex_size: float = 50.0

var hex_coords  # 不指定类型以避免解析错误
var zone_data = null  # ZoneData 对象
var is_revealed: bool = false
var is_current: bool = false
var is_hovered: bool = false

@onready var polygon = $Polygon2D
@onready var collision_polygon = $CollisionPolygon2D

# 颜色定义
# 三级界区颜色（等高线风格）
# 爬行界（低地）: 棕绿色系
# 飞跃界（中地）: 蓝紫色系
# 超限界（高地）: 金白色系
const COLOR_CRAWLING = Color(0.35, 0.45, 0.3, 0.95)    # 爬行界 - 棕绿
const COLOR_BREAKTHROUGH = Color(0.3, 0.35, 0.6, 0.95) # 飞跃界 - 蓝紫
const COLOR_TRANSCENDENT = Color(0.7, 0.6, 0.3, 0.95)  # 超限界 - 金色

const COLOR_HIDDEN = Color(0.15, 0.15, 0.25, 0.6)     # 未探索 - 半透明暗色
const COLOR_REVEALED = Color(0.2, 0.35, 0.55, 0.95)    # 已探索 - 蓝色（后备）
const COLOR_CURRENT = Color(0.3, 0.8, 0.4, 1.0)        # 当前所在 - 绿色
const COLOR_HOVER = Color(0.5, 0.6, 0.8, 1.0)          # 悬停 - 高亮

func _ready():
	_generate_hexagon()
	_generate_collision()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hex_clicked.emit(hex_coords)

func setup(coords, zone):
	hex_coords = coords
	zone_data = zone
	# 使用简单的转换
	position = _axial_to_pixel(coords.q, coords.r, hex_size)
	# 延迟一帧后更新视觉状态，确保 _ready() 已完成
	call_deferred("_update_visual_state")

# 简化的轴坐标转像素
func _axial_to_pixel(q: int, r: int, size: float) -> Vector2:
	var x = size * (sqrt(3) * q + sqrt(3) / 2.0 * r)
	var y = size * (3.0 / 2.0 * r)
	return Vector2(x, y)

func _generate_hexagon():
	var points = PackedVector2Array()
	for i in range(6):
		var angle = deg_to_rad(60 * i - 30)
		var point = Vector2(cos(angle), sin(angle)) * hex_size
		points.append(point)
	polygon.polygon = points

func _generate_collision():
	var points = PackedVector2Array()
	for i in range(6):
		var angle = deg_to_rad(60 * i - 30)
		var point = Vector2(cos(angle), sin(angle)) * hex_size
		points.append(point)
	collision_polygon.polygon = points

# 检查点是否在六边形内（简化版：使用圆形近似）
func is_point_inside(point: Vector2) -> bool:
	var local_point = point - global_position
	return local_point.length() < hex_size * 0.9

func _update_visual_state():
	if is_current:
		polygon.color = COLOR_CURRENT
	elif is_hovered and is_revealed:
		polygon.color = COLOR_HOVER
	elif is_revealed and zone_data:
		# 根据界区层级显示不同颜色
		var tier = zone_data.tier if "tier" in zone_data else 0
		match tier:
			0: polygon.color = COLOR_CRAWLING   # 爬行界
			1: polygon.color = COLOR_BREAKTHROUGH  # 飞跃界
			2: polygon.color = COLOR_TRANSCENDENT   # 超限界
			_: polygon.color = COLOR_REVEALED
	else:
		polygon.color = COLOR_HIDDEN

func set_revealed(revealed: bool):
	is_revealed = revealed
	_update_visual_state()

func set_current(is_current_zone: bool):
	is_current = is_current_zone
	_update_visual_state()

func _on_mouse_entered():
	is_hovered = true
	_update_visual_state()

func _on_mouse_exited():
	is_hovered = false
	_update_visual_state()
