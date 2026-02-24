using Godot;
using Godot.Collections;

public partial class SceneManager : Node
{
    public static SceneManager Instance { get; private set; }
    
    public Control MainMenu { get; private set; }
    public Control IdentitySelect { get; private set; }
    public Control GameUI { get; private set; }
    
    public override void _Ready()
    {
        Instance = this;
        
        MainMenu = GetNode<Control>("MainMenu");
        IdentitySelect = GetNode<Control>("IdentitySelect");
        GameUI = GetNode<Control>("GameUI");
        
        ShowMainMenu();
    }
    
    public void ShowMainMenu()
    {
        MainMenu.Visible = true;
        IdentitySelect.Visible = false;
        GameUI.Visible = false;
    }
    
    public void ShowIdentitySelect()
    {
        MainMenu.Visible = false;
        IdentitySelect.Visible = true;
        GameUI.Visible = false;
    }
    
    public void ShowGame()
    {
        MainMenu.Visible = false;
        IdentitySelect.Visible = false;
        GameUI.Visible = true;
        
        UpdateGameUI();
    }
    
    public void UpdateGameUI()
    {
        if (GameUI == null || !GameUI.Visible) return;
        
        var gm = GameManager.Instance;
        
        // 更新回合
        var turnLabel = GameUI.GetNode<Label>("TopBar/TopBarContent/TurnLabel");
        turnLabel.Text = $"第 {gm.TurnNumber} 回合";
        
        // 更新资源
        var creditsLabel = GameUI.GetNode<Label>("TopBar/TopBarContent/Resources/CreditsLabel");
        creditsLabel.Text = $"💰 {gm.Credits}";
        
        var fuelLabel = GameUI.GetNode<Label>("TopBar/TopBarContent/Resources/FuelLabel");
        fuelLabel.Text = $"⛽ {gm.Fuel}";
        
        var mineralsLabel = GameUI.GetNode<Label>("TopBar/TopBarContent/Resources/MineralsLabel");
        mineralsLabel.Text = $"💎 {gm.Minerals}";
        
        var researchLabel = GameUI.GetNode<Label>("TopBar/TopBarContent/Resources/ResearchLabel");
        researchLabel.Text = $"🔬 {gm.ResearchPoints}";
        
        // 更新当前界区信息
        var zoneName = GameUI.GetNode<Label>("CenterPanel/ZoneInfo/InfoContent/ZoneName");
        zoneName.Text = gm.CurrentZone.Name;
        
        var zoneType = GameUI.GetNode<Label>("CenterPanel/ZoneInfo/InfoContent/ZoneType");
        zoneType.Text = gm.CurrentZone.Type == ZoneType.FTL ? "超光速界区 (FTL)" : "光速受限界区";
        
        var zoneDesc = GameUI.GetNode<Label>("CenterPanel/ZoneInfo/InfoContent/ZoneDesc");
        zoneDesc.Text = gm.CurrentZone.Description;
        
        var zoneStats = GameUI.GetNode<Label>("CenterPanel/ZoneInfo/InfoContent/ZoneStats");
        zoneStats.Text = $"科技等级: {gm.CurrentZone.TechLevel} | 威胁: {gm.CurrentZone.ThreatLevel}";
    }
}
