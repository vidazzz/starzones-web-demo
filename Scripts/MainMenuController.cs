using Godot;

public partial class MainMenuController : Control
{
    public override void _Ready()
    {
        // 获取开始按钮并连接信号
        var startButton = GetNode<Button>("StartButton");
        startButton.Pressed += OnStartButtonPressed;
    }
    
    private void OnStartButtonPressed()
    {
        SceneManager.Instance.ShowIdentitySelect();
    }
}
