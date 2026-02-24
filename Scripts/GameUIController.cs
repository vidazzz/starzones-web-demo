using Godot;

public partial class GameUIController : Control
{
    public override void _Ready()
    {
        // 底部按钮
        GetNode<Button>("BottomBar/ExploreButton").Pressed += OnExplorePressed;
        GetNode<Button>("BottomBar/BuildButton").Pressed += OnBuildPressed;
        GetNode<Button>("BottomBar/FleetButton").Pressed += OnFleetPressed;
        GetNode<Button>("BottomBar/EndTurnButton").Pressed += OnEndTurnPressed;
        
        // 中间面板按钮
        GetNode<Button>("CenterPanel/ZoneInfo/InfoContent/TravelButton").Pressed += OnTravelPressed;
    }
    
    private void OnExplorePressed()
    {
        var gm = GameManager.Instance;
        
        var undiscovered = gm.Zones.FindAll(z => !z.Discovered);
        
        if (undiscovered.Count > 0)
        {
            var random = new Random();
            var target = undiscovered[random.Next(undiscovered.Count)];
            
            if (gm.Fuel >= 10)
            {
                gm.Fuel -= 10;
                gm.ExploreZone(target);
                
                GD.Print($"探索发现: {target.Name}");
            }
        }
        
        SceneManager.Instance.UpdateGameUI();
    }
    
    private void OnBuildPressed()
    {
        GD.Print("建造系统 - 开发中");
    }
    
    private void OnFleetPressed()
    {
        GD.Print("舰队管理 - 开发中");
    }
    
    private void OnTravelPressed()
    {
        var gm = GameManager.Instance;
        
        var undiscovered = gm.Zones.FindAll(z => !z.Discovered);
        
        if (undiscovered.Count > 0)
        {
            var random = new Random();
            var target = undiscovered[random.Next(undiscovered.Count)];
            
            if (gm.TravelToZone(target))
            {
                GD.Print($"前往: {target.Name}");
            }
        }
        
        SceneManager.Instance.UpdateGameUI();
    }
    
    private void OnEndTurnPressed()
    {
        GameManager.Instance.NextTurn();
        SceneManager.Instance.UpdateGameUI();
    }
}
