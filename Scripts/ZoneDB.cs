using Godot;
using System.Collections.Generic;

/// <summary>
/// 界区类型：决定物理法则
/// </summary>
public enum ZoneType
{
    /// <summary>可超光速界区 - 先进文明领地</summary>
    FTL,          
    /// <summary>光速受限界区 - 原始文明领地</summary>
    SubLight,     
    /// <summary>特殊界区 - 独特物理法则</summary>
    Special       
}

public partial class ZoneData
{
    public string Id { get; set; }
    public string Name { get; set; }
    public ZoneType Type { get; set; }
    public string Description { get; set; }
    
    // 物理法则属性
    public bool CanWarp { get; set; }        // 可进行空间跳跃
    public bool CanFTL { get; set; }          // 可超光速航行
    public float SpeedLimit { get; set; } = 1.0f;  // 速度上限倍率
    public int TechLevel { get; set; }        // 科技等级 1-10
    
    // 资源产出
    public int FuelProduction { get; set; }    // 燃料
    public int MineralProduction { get; set; } // 矿物
    public int ResearchProduction { get; set; } // 研究点
    
    // 探索属性
    public bool Discovered { get; set; }
    public bool HasArtifact { get; set; }      // 是否有古物
    public string StoryFragment { get; set; }  // 故事碎片
    
    // 难度/威胁
    public int ThreatLevel { get; set; }       // 威胁等级 0-5
}

public static class ZoneDB
{
    private static readonly Random _rng = new();
    
    public static List<ZoneData> GenerateGalaxy(int zoneCount = 20)
    {
        var zones = new List<ZoneData>();
        
        // 家乡界区（固定）
        zones.Add(new ZoneData
        {
            Id = "home_zone",
            Name = "地球圈",
            Type = ZoneType.FTL,
            Description = "人类的母星所在的繁荣界区",
            CanWarp = true,
            CanFTL = true,
            SpeedLimit = 10.0f,
            TechLevel = 8,
            FuelProduction = 10,
            MineralProduction = 5,
            ResearchProduction = 3,
            Discovered = true,
            ThreatLevel = 0
        });
        
        // 生成其他界区
        for (int i = 1; i < zoneCount; i++)
        {
            bool isFTL = _rng.NextDouble() > 0.4; // 60% FTL, 40% SubLight
            
            var zone = new ZoneData
            {
                Id = $"zone_{i}",
                Name = isFTL ? GenerateFTLName() : GenerateSubLightName(),
                Type = isFTL ? ZoneType.FTL : ZoneType.SubLight,
                CanWarp = isFTL,
                CanFTL = isFTL,
                SpeedLimit = isFTL ? (float)(5.0 + _rng.NextDouble() * 5.0) : (float)(0.5 + _rng.NextDouble() * 0.5),
                TechLevel = isFTL ? _rng.Next(5, 10) : _rng.Next(1, 5),
                FuelProduction = _rng.Next(3, 15),
                MineralProduction = _rng.Next(2, 10),
                ResearchProduction = _rng.Next(1, 5),
                Discovered = false,
                HasArtifact = _rng.NextDouble() > 0.7,
                ThreatLevel = _rng.Next(0, 5)
            };
            
            zone.Description = GenerateDescription(zone);
            zones.Add(zone);
        }
        
        return zones;
    }
    
    private static string GenerateFTLName()
    {
        string[] prefixes = { "新", "远", "天", "银", "星", "海", "光", "曲" };
        string[] cores = { "阳", "月", "辰", "界", "域", "港", "星", "云" };
        return prefixes[_rng.Next(prefixes.Length)] + cores[_rng.Next(cores.Length)] + "星域";
    }
    
    private static string GenerateSubLightName()
    {
        string[] prefixes = { "暗", "幽", "深", "古", "荒", "寂", "静", "边" };
        string[] cores = { "渊", "雾", "域", "区", "荒", "星", "际", "空" };
        return prefixes[_rng.Next(prefixes.Length)] + cores[_rng.Next(cores.Length)] + "区";
    }
    
    private static string GenerateDescription(ZoneData zone)
    {
        if (zone.Type == ZoneType.FTL)
        {
            return $"一个繁荣的{zone.TechLevel}级科技界区，可进行{'超光速航行' + (zone.CanWarp ? "和空间跳跃" : "")}。";
        }
        else
        {
            return $"一个原始的{zone.TechLevel}级科技界区，光速限制严格，航行困难。";
        }
    }
}
