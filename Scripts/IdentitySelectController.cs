using Godot;

public partial class IdentitySelectController : Control
{
    public override void _Ready()
    {
        // 连接各个身份选择按钮
        GetNode<Button>("Identities/ExplorerCard/ExplorerContent/ExplorerButton").Pressed += () => OnIdentitySelected("explorer");
        GetNode<Button>("Identities/ArchaeologistCard/ArchaeologistContent/ArchaeologistButton").Pressed += () => OnIdentitySelected("archaeologist");
        GetNode<Button>("Identities/ScientistCard/ScientistContent/ScientistButton").Pressed += () => OnIdentitySelected("scientist");
        GetNode<Button>("Identities/SoldierCard/SoldierContent/SoldierButton").Pressed += () => OnIdentitySelected("soldier");
        
        // 返回按钮
        GetNode<Button>("BackButton").Pressed += OnBackPressed;
    }
    
    private void OnIdentitySelected(string identityId)
    {
        GameManager.Instance.StartNewGame(identityId);
        SceneManager.Instance.ShowGame();
    }
    
    private void OnBackPressed()
    {
        SceneManager.Instance.ShowMainMenu();
    }
}
