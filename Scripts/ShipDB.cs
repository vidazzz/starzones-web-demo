using Godot;
using System.Collections.Generic;

/// <summary>
/// 舰船类型
/// </summary>
public enum ShipType
{
    Scout,      // 侦察舰 - 探索+
    Frigate,    // 护卫舰 - 防御
    Destroyer,  // 驱逐舰 - 攻击
    Cruiser,    // 巡洋舰 - 平衡
    Battleship  // 战列舰 - 主力
}

/// <summary>
/// 舰船数据
/// </summary>
public partial class ShipData
{
    public string Id { get; set; }
    public string Name { get; set; }
    public ShipType Type { get; set; }
    
    // 属性
    public int Attack { get; set; }
    public int Defense { get; set; }
    public int Speed { get; set; }        // 航行速度
    public int Cargo { get; set; }         // 货运量
    public int Cost { get; set; }          // 造价
    
    // 克制关系：克制的类型
    public List<ShipType> HardCounters { get; set; } = new();
    // 被克制的类型
    public List<ShipType> WeakTo { get; set; } = new();
}

public static class ShipDB
{
    public static readonly Dictionary<ShipType, ShipData> All = new()
    {
        [ShipType.Scout] = new ShipData
        {
            Id = "scout",
            Name = "侦察舰",
            Type = ShipType.Scout,
            Attack = 1,
            Defense = 1,
            Speed = 10,
            Cargo = 5,
            Cost = 50,
            HardCounters = new List<ShipType> { ShipType.Frigate },
            WeakTo = new List<ShipType> { ShipType.Destroyer, ShipType.Battleship }
        },
        [ShipType.Frigate] = new ShipData
        {
            Id = "frigate",
            Name = "护卫舰",
            Type = ShipType.Frigate,
            Attack = 2,
            Defense = 3,
            Speed = 6,
            Cargo = 10,
            Cost = 100,
            HardCounters = new List<ShipType> { ShipType.Destroyer },
            WeakTo = new List<ShipType> { ShipType.Cruiser, ShipType.Battleship }
        },
        [ShipType.Destroyer] = new ShipData
        {
            Id = "destroyer",
            Name = "驱逐舰",
            Type = ShipType.Destroyer,
            Attack = 4,
            Defense = 2,
            Speed = 5,
            Cargo = 8,
            Cost = 150,
            HardCounters = new List<ShipType> { ShipType.Cruiser },
            WeakTo = new List<ShipType> { ShipType.Scout, ShipType.Battleship }
        },
        [ShipType.Cruiser] = new ShipData
        {
            Id = "cruiser",
            Name = "巡洋舰",
            Type = ShipType.Cruiser,
            Attack = 5,
            Defense = 5,
            Speed = 4,
            Cargo = 15,
            Cost = 300,
            HardCounters = new List<ShipType> { ShipType.Battleship },
            WeakTo = new List<ShipType> { ShipType.Frigate, ShipType.Destroyer }
        },
        [ShipType.Battleship] = new ShipData
        {
            Id = "battleship",
            Name = "战列舰",
            Type = ShipType.Battleship,
            Attack = 8,
            Defense = 8,
            Speed = 2,
            Cargo = 25,
            Cost = 500,
            HardCounters = new List<ShipType> { ShipType.Scout },
            WeakTo = new List<ShipType> { ShipType.Cruiser }
        }
    };
    
    // 计算战斗力的公式
    public static int CalculatePower(List<ShipData> ships)
    {
        int totalPower = 0;
        
        foreach (var ship in ships)
        {
            int shipPower = ship.Attack + ship.Defense;
            
            // 检查克制
            foreach (var otherShip in ships)
            {
                if (ship.HardCounters.Contains(otherShip.Type))
                {
                    shipPower += 2; // 克制加成
                }
                if (ship.WeakTo.Contains(otherShip.Type))
                {
                    shipPower -= 1; // 被克制减成
                }
            }
            
            totalPower += shipPower;
        }
        
        return totalPower;
    }
}
