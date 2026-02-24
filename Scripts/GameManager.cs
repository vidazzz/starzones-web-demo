using Godot;

public partial class GameManager : Node
{
    // 玩家数据
    public string PlayerName { get; set; } = "Commander";
    public string PlayerIdentity { get; set; } = "explorer"; // explorer, archaeologist, scientist, soldier
    
    // 游戏状态
    public int TurnNumber { get; set; } = 1;
    public int Credits { get; set; } = 1000;
    public int ResearchPoints { get; set; } = 0;
    
    // 已发现的界区
    public Godot.Collections.Array<string> DiscoveredZones { get; set; } = new();
    
    public override void _Ready()
    {
        GD.Print("Star Zones - Game Manager Initialized");
    }
    
    public void StartNewGame(string identity)
    {
        PlayerIdentity = identity;
        TurnNumber = 1;
        Credits = 1000;
        ResearchPoints = 0;
        DiscoveredZones.Clear();
        
        // 初始界区
        DiscoveredZones.Add("home_zone");
        
        GD.Print($"New game started as {identity}");
    }
    
    public void NextTurn()
    {
        TurnNumber++;
        GD.Print($"Turn {TurnNumber}");
    }
}
