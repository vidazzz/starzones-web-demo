# Star Zones - 游戏设计文档

## 1. 项目概述

**项目名称**: Star Zones (星区)
**类型**: 回合制太空策略/探索游戏
**引擎**: Godot 4.x
**平台**: Web (HTML5)

### 1.1 游戏简介
玩家扮演一名宇宙探索者，在由六边形地块组成的星际地图上进行探索。每个地块代表一个"界区"（Zone），玩家需要通过消耗燃料来探索未知的界区，逐步扩大自己的势力范围。

### 1.2 核心玩法
- **六边形地图探索**: 点击邻近地块进行探索和移动
- **回合制系统**: 每个回合产出资源（燃料、矿物、研究点）
- **资源管理**: 平衡 Credits（货币）、Fuel（燃料）、Minerals（矿物）、Research Points（研究点）
- **身份选择**: 4种不同的职业身份，各有不同的初始资源和加成

---

## 2. 界面设计

### 2.1 主菜单
- 游戏标题
- "开始游戏" 按钮

### 2.2 身份选择界面
- 4个职业身份卡片：
  - **探险家** (Explorer): 1500 Credits，1.5倍探索加成
  - **考古学家** (Archaeologist): 1200 Credits + 100 Research Points，1.3倍研究加成
  - **科学家** (Scientist): 1000 Credits + 200 Research Points，1.5倍研究加成
  - **军人** (Soldier): 1000 Credits，1.5倍战斗加成

### 2.3 游戏界面
- **顶部栏**: 回合数、Credits、燃料、矿物、研究点
- **中央地图**: 六边形网格（Hex Grid），显示20个界区
  - 未探索区域: 半透明暗色
  - 已探索区域: 蓝色
  - 当前所在区域: 绿色
  - 舰队标记: 🚀
- **底部栏**: 探索、建造、舰队、结束回合按钮

---

## 3. 游戏系统

### 3.1 资源系统

| 资源 | 用途 | 获取方式 |
|------|------|----------|
| Credits (💰) | 购买舰船、建筑 | 回合产出 |
| Fuel (⛽) | 探索和移动 | 回合产出 |
| Minerals (💎) | 建造舰船 | 回合产出 |
| Research Points (🔬) | 解锁科技 | 回合产出 |

### 3.2 界区 (Zone) 系统

#### 界区类型
1. **FTL (超光速界区)**
   - 可进行超光速航行
   - 移动消耗: 10 燃料
   - 科技等级: 5-10

2. **SUB_LIGHT (光速受限界区)**
   - 光速限制严格
   - 移动消耗: 20 燃料
   - 科技等级: 1-5

#### 界区属性
- `fuel_production`: 每回合燃料产出 (3-15)
- `mineral_production`: 每回合矿物产出 (2-10)
- `research_production`: 每回合研究产出 (1-5)
- `tech_level`: 科技等级 (1-10)
- `threat_level`: 威胁等级 (0-5)
- `has_artifact`: 是否有上古遗物

### 3.3 移动与探索

**规则**:
1. 只能移动到当前所在区域的**邻近**地块
2. 探索未揭示区域需要消耗燃料
3. 探索+移动同时进行，不分开处理
4. 燃料不足时无法执行任何操作

**流程**:
1. 点击邻近地块 → 弹出确认面板
2. 显示区域信息（名称、类型、描述、燃料消耗）
3. 点击"确认" → 执行探索和移动
4. 面板关闭，舰队标记更新到新位置

### 3.4 回合系统

每个回合执行以下操作：
1. 回合数 +1
2. 根据当前所在界区的产出计算资源
3. 玩家执行行动（探索、移动等）

---

## 4. 舰船系统

### 4.1 舰船类型

| 类型 | 名称 | 攻击 | 防御 | 速度 | 货舱 | 成本 |
|------|------|------|------|------|------|------|
| SCOUT | 侦察舰 | 1 | 1 | 10 | 5 | 50 |
| FRIGATE | 护卫舰 | 2 | 3 | 6 | 10 | 100 |
| DESTROYER | 驱逐舰 | 4 | 2 | 5 | 8 | 150 |
| CRUISER | 巡洋舰 | 5 | 5 | 4 | 15 | 300 |
| BATTLESHIP | 战列舰 | 8 | 8 | 2 | 25 | 500 |

### 4.2 战斗克制
- 侦察舰克制护卫舰
- 护卫舰克制驱逐舰
- 驱逐舰克制巡洋舰
- 巡洋舰克制战列舰
- 战列舰克制侦察舰

---

## 5. 技术实现

### 5.1 核心脚本

| 文件 | 功能 |
|------|------|
| `GameManager.gd` | 游戏状态管理、资源系统 |
| `SceneManager.gd` | 场景切换管理 |
| `GameUIController.gd` | 游戏界面交互处理 |
| `HexMap.gd` | 六边形地图生成与管理 |
| `HexTile.gd` | 单个六边形地块 |
| `ZoneDB.gd` | 界区数据生成 |
| `ShipDB.gd` | 舰船数据 |
| `IdentityDB.gd` | 身份数据 |

### 5.2 六边形地图

- **坐标系统**: 轴坐标 (Axial Coordinates, q, r)
- **地图生成**: 螺旋生成算法，从中心向外扩展
- **地图半径**: 2（可调整）
- **地块数量**: 20个

### 5.3 节点层级

```
Main (Node)
├── MainMenu (Control)
├── IdentitySelect (Control)
├── GameUI (Control)
│   ├── TopBar (PanelContainer)
│   ├── CenterPanel (Control, mouse_filter=2)
│   │   └── ZoneInfo (PanelContainer)
│   ├── HexMapContainer (Node2D) ← HexMap 在这里
│   └── BottomBar (HBoxContainer)
└── SceneManager (Node)
```

---

## 6. 开发进度

### ✅ 已完成
- [x] 主菜单界面
- [x] 身份选择系统
- [x] 游戏界面 UI
- [x] 资源显示
- [x] 六边形地图生成
- [x] 舰队标记显示
- [x] 点击探索与移动
- [x] 燃料检查逻辑
- [x] 回合系统
- [x] 区域信息面板

### ⏳ 待开发
- [ ] 舰船建造系统
- [ ] 战斗系统
- [ ] 科技树系统
- [ ] 胜利条件判定
- [ ] 存档/读档功能

---

## 7. 文件结构

```
starzones-web-demo/
├── project.godot
├── Scripts/
│   ├── GameManager.gd
│   ├── SceneManager.gd
│   ├── GameUIController.gd
│   ├── HexMap.gd
│   ├── HexTile.gd
│   ├── ZoneDB.gd
│   ├── ShipDB.gd
│   ├── IdentityDB.gd
│   ├── MainMenuController.gd
│   └── IdentitySelectController.gd
├── Scenes/
│   ├── Main.tscn
│   ├── GameUI.tscn
│   ├── HexTile.tscn
│   └── ...
└── export_presets.cfg
```

---

*文档版本: 1.0*
*最后更新: 2026-02-24*
