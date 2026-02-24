# ShipDB.gd
# 舰船数据

enum ShipType { SCOUT, FRIGATE, DESTROYER, CRUISER, BATTLESHIP }

class ShipData:
	var id: String
	var name: String
	var type: int
	var attack: int
	var defense: int
	var speed: int
	var cargo: int
	var cost: int
	var hard_counters: Array = []
	var weak_to: Array = []

var _ships = {
	ShipType.SCOUT: {
		"id": "scout",
		"name": "侦察舰",
		"type": ShipType.SCOUT,
		"attack": 1,
		"defense": 1,
		"speed": 10,
		"cargo": 5,
		"cost": 50,
		"hard_counters": [ShipType.FRIGATE],
		"weak_to": [ShipType.DESTROYER, ShipType.BATTLESHIP]
	},
	ShipType.FRIGATE: {
		"id": "frigate",
		"name": "护卫舰",
		"type": ShipType.FRIGATE,
		"attack": 2,
		"defense": 3,
		"speed": 6,
		"cargo": 10,
		"cost": 100,
		"hard_counters": [ShipType.DESTROYER],
		"weak_to": [ShipType.CRUISER, ShipType.BATTLESHIP]
	},
	ShipType.DESTROYER: {
		"id": "destroyer",
		"name": "驱逐舰",
		"type": ShipType.DESTROYER,
		"attack": 4,
		"defense": 2,
		"speed": 5,
		"cargo": 8,
		"cost": 150,
		"hard_counters": [ShipType.CRUISER],
		"weak_to": [ShipType.SCOUT, ShipType.BATTLESHIP]
	},
	ShipType.CRUISER: {
		"id": "cruiser",
		"name": "巡洋舰",
		"type": ShipType.CRUISER,
		"attack": 5,
		"defense": 5,
		"speed": 4,
		"cargo": 15,
		"cost": 300,
		"hard_counters": [ShipType.BATTLESHIP],
		"weak_to": [ShipType.FRIGATE, ShipType.DESTROYER]
	},
	ShipType.BATTLESHIP: {
		"id": "battleship",
		"name": "战列舰",
		"type": ShipType.BATTLESHIP,
		"attack": 8,
		"defense": 8,
		"speed": 2,
		"cargo": 25,
		"cost": 500,
		"hard_counters": [ShipType.SCOUT],
		"weak_to": [ShipType.CRUISER]
	}
}

func get_ship(type: int) -> Dictionary:
	return _ships.get(type, _ships[ShipType.SCOUT])

func get_all_ships() -> Array:
	return _ships.values()
