# HexCoords.gd
# 六边形坐标工具类 - 使用轴坐标系统 (Axial Coordinates)

class HexCoords:
	var q: int  # 列坐标
	var r: int  # 行坐标

	# 立方坐标的第三个分量: s = -q - r
	var s: int get:
		return -q - r

	func _init(q_val: int = 0, r_val: int = 0):
		q = q_val
		r = r_val

	# 哈希键（用于字典）
	func hash() -> String:
		return str(q) + "," + str(r)

	# 字符串表示
	func _to_string() -> String:
		return "HexCoords(%d, %d)" % [q, r]
