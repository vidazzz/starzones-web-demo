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
        
        // 星图按钮
        GetNode<Button>("StarMap/ZoneInfo/InfoContent/TravelButton").Pressed += OnTravelPressed;
    }
    
    private void OnExplorePressed()
    {
        // 随机发现一个新界区
        var gm = GameManager.Instance;
        
        // 找到未发现的界区
        var undiscovered = gm.Zones.FindAll(z => !z.Discovered);
        
        if (undiscovered.Count > 0)
        {
            var random = new Random();
            var target = undiscovered[random.Next(undiscovered.Count)];
            
            // 消耗燃料探索
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
        // 显示可选的界区列表（简化版：随机探索）
        var gm = GameManager.Instance;
        
        // 随机前往一个未探索的界区
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
