# IdentityDB.gd
# 身份数据定义

class IdentityData:
	var id: String
	var name: String
	var description: String
	var victory_condition: String
	var story_intro: String
	
	var start_credits: int = 1000
	var start_research: int = 0
	var explore_bonus: float = 1.0
	var research_bonus: float = 1.0
	var combat_bonus: float = 1.0

var _identities = {
	"explorer": {
		"id": "explorer",
		"name": "探险家",
		"description": "追寻宇宙边缘的尽头",
		"victory_condition": "发现所有界区",
		"story_intro": "你是一名探险家，驾驶着飞船穿梭于星海之间，追寻着宇宙最终的边界...",
		"start_credits": 1500,
		"explore_bonus": 1.5
	},
	"archaeologist": {
		"id": "archaeologist",
		"name": "考古学家",
		"description": "追溯消失的超级文明",
		"victory_condition": "解读上古文明谜题",
		"story_intro": "你是一名考古学家，在星海中寻找着远古文明的遗迹，探寻宇宙历史的真相...",
		"start_credits": 1200,
		"start_research": 100,
		"research_bonus": 1.3
	},
	"scientist": {
		"id": "scientist",
		"name": "科学家",
		"description": "解开宇宙终极真理",
		"victory_condition": "统一物理法则",
		"story_intro": "你是一名科学家，致力于研究不同界区的物理法则，寻求宇宙的统一理论...",
		"start_credits": 1000,
		"start_research": 200,
		"research_bonus": 1.5
	},
	"soldier": {
		"id": "soldier",
		"name": "军人",
		"description": "在混乱中建立秩序",
		"victory_condition": "征服敌对势力",
		"story_intro": "你是一名军人，奉命在危险的界区中巡逻，维护宇宙的和平与秩序...",
		"start_credits": 1000,
		"combat_bonus": 1.5
	}
}

func get_identity(id: String) -> Dictionary:
	return _identities.get(id, _identities["explorer"])

func get_all_identities() -> Array:
	return _identities.values()
