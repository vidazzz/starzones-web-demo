# ZoneDB.gd
# 界区数据定义

enum ZoneType { FTL, SUB_LIGHT, SPECIAL }

class ZoneData:
	var id: String
	var name: String
	var type: int
	var description: String
	
	var can_warp: bool
	var can_ftl: bool
	var speed_limit: float
	var tech_level: int
	
	var fuel_production: int
	var mineral_production: int
	var research_production: int
	
	var discovered: bool = false
	var has_artifact: bool = false
	var story_fragment: String = ""
	var threat_level: int

func generate_galaxy(zone_count: int = 20) -> Array:
	var zones = []
	
	# 家乡界区
	var home = ZoneData.new()
	home.id = "home_zone"
	home.name = "地球圈"
	home.type = ZoneType.FTL
	home.description = "人类的母星所在的繁荣界区"
	home.can_warp = true
	home.can_ftl = true
	home.speed_limit = 10.0
	home.tech_level = 8
	home.fuel_production = 10
	home.mineral_production = 5
	home.research_production = 3
	home.discovered = true
	home.threat_level = 0
	zones.append(home)
	
	# 生成其他界区
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(1, zone_count):
		var is_ftl = rng.randf() > 0.4
		var zone = ZoneData.new()
		zone.id = "zone_" + str(i)
		zone.name = _generate_name(is_ftl, rng)
		zone.type = ZoneType.FTL if is_ftl else ZoneType.SUB_LIGHT
		zone.can_warp = is_ftl
		zone.can_ftl = is_ftl
		zone.speed_limit = rng.randf_range(5.0, 10.0) if is_ftl else rng.randf_range(0.5, 1.0)
		zone.tech_level = rng.randi_range(5, 10) if is_ftl else rng.randi_range(1, 5)
		zone.fuel_production = rng.randi_range(3, 15)
		zone.mineral_production = rng.randi_range(2, 10)
		zone.research_production = rng.randi_range(1, 5)
		zone.discovered = false
		zone.has_artifact = rng.randf() > 0.7
		zone.threat_level = rng.randi_range(0, 5)
		
		if zone.type == ZoneType.FTL:
			zone.description = "一个繁荣的" + str(zone.tech_level) + "级科技界区，可进行超光速航行" + ("和空间跳跃" if zone.can_warp else "") + "。"
		else:
			zone.description = "一个原始的" + str(zone.tech_level) + "级科技界区，光速限制严格，航行困难。"
		
		zones.append(zone)
	
	return zones

func _generate_name(is_ftl: bool, rng: RandomNumberGenerator) -> String:
	var prefixes_ftl = ["新", "远", "天", "银", "星", "海", "光", "曲"]
	var cores_ftl = ["阳", "月", "辰", "界", "域", "港", "星", "云"]
	
	var prefixes_sub = ["暗", "幽", "深", "古", "荒", "寂", "静", "边"]
	var cores_sub = ["渊", "雾", "域", "区", "荒", "星", "际", "空"]
	
	if is_ftl:
		return prefixes_ftl[rng.randi() % prefixes_ftl.size()] + cores_ftl[rng.randi() % cores_ftl.size()] + "星域"
	else:
		return prefixes_sub[rng.randi() % prefixes_sub.size()] + cores_sub[rng.randi() % cores_sub.size()] + "区"
