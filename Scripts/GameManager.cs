using Godot;
using System.Collections.Generic;

public partial class GameManager : Node
{
    // 单例
    public static GameManager Instance { get; private set; }
    
    // 玩家数据
    public string PlayerName { get; set; } = "Commander";
    public IdentityData PlayerIdentity { get; set; }
    
    // 游戏状态
    public int TurnNumber { get; set; } = 1;
    public int Credits { get; set; } = 1000;
    public int ResearchPoints { get; set; } = 0;
    
    // 资源
    public int Fuel { get; set; } = 50;
    public int Minerals { get; set; } = 30;
    
    // 舰队
    public List<ShipData> Fleet { get; set; } = new();
    
    // 界区
    public List<ZoneData> Zones { get; set; } = new();
    public ZoneData CurrentZone { get; set; }
    
    // 探索进度
    public int DiscoveredZoneCount { get; set; } = 1;
    public int TotalZones { get; set; } = 20;
    public List<string> StoryFragments { get; set; } = new();
    
    // 游戏阶段
    public enum GamePhase
    {
        Menu,
        IdentitySelect,
        Playing,
        Paused,
        GameOver
    }
    public GamePhase CurrentPhase { get; set; } = GamePhase.Menu;
    
    public override void _Ready()
    {
        Instance = this;
        GD.Print("Star Zones - Game Manager Initialized");
        
        // 初始化舰队（侦察舰x1）
        Fleet.Add(ShipDB.All[ShipType.Scout]);
    }
    
    public void StartNewGame(string identityId)
    {
        // 设置身份
        PlayerIdentity = IdentityDB.All[identityId];
        
        // 应用起始资源
        TurnNumber = 1;
        Credits = PlayerIdentity.StartCredits;
        ResearchPoints = PlayerIdentity.StartResearch;
        Fuel = 50;
        Minerals = 30;
        
        // 初始舰队
        Fleet.Clear();
        Fleet.Add(ShipDB.All[ShipType.Scout]);
        
        // 生成星系
        Zones = ZoneDB.GenerateGalaxy(TotalZones);
        CurrentZone = Zones[0]; // 家乡界区
        DiscoveredZoneCount = 1;
        StoryFragments.Clear();
        
        CurrentPhase = GamePhase.Playing;
        
        GD.Print($"New game started as {PlayerIdentity.Name}");
        GD.Print($"Home zone: {CurrentZone.Name}");
    }
    
    public void NextTurn()
    {
        TurnNumber++;
        
        // 资源产出
        Fuel += CurrentZone.FuelProduction;
        Minerals += CurrentZone.MineralProduction;
        ResearchPoints += CurrentZone.ResearchProduction;
        
        GD.Print($"Turn {TurnNumber} - Zone: {CurrentZone.Name}");
    }
    
    /// <summary>
    /// 探索新界区
    /// </summary>
    public void ExploreZone(ZoneData zone)
    {
        if (zone.Discovered) return;
        
        zone.Discovered = true;
        DiscoveredZoneCount++;
        
        if (!string.IsNullOrEmpty(zone.StoryFragment))
        {
            StoryFragments.Add(zone.StoryFragment);
        }
        
        GD.Print($"Discovered new zone: {zone.Name}");
    }
    
    /// <summary>
    /// 移动到界区
    /// </summary>
    public bool TravelToZone(ZoneData targetZone)
    {
        // 检查是否已发现
        if (!targetZone.Discovered)
        {
            // 可以探索前往
            ExploreZone(targetZone);
        }
        
        // 检查燃料是否足够（简化的消耗计算）
        int fuelCost = 10;
        if (targetZone.Type == ZoneType.SubLight)
        {
            fuelCost = 20; // 光速界区更难到达
        }
        
        if (Fuel < fuelCost)
        {
            GD.Print("Not enough fuel!");
            return false;
        }
        
        Fuel -= fuelCost;
        CurrentZone = targetZone;
        
        GD.Print($"Traveled to {targetZone.Name}");
        return true;
    }
    
    /// <summary>
    /// 购买舰船
    /// </summary>
    public bool PurchaseShip(ShipType shipType)
    {
        var ship = ShipDB.All[shipType];
        
        if (Credits < ship.Cost)
        {
            GD.Print("Not enough credits!");
            return false;
        }
        
        Credits -= ship.Cost;
        Fleet.Add(ship);
        
        GD.Print($"Purchased {ship.Name}");
        return true;
    }
    
    /// <summary>
    /// 计算舰队战斗力
    /// </summary>
    public int GetFleetPower()
    {
        return ShipDB.CalculatePower(Fleet);
    }
}
