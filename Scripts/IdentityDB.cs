using Godot;
using System.Collections.Generic;

public partial class IdentityData
{
    public string Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public string VictoryCondition { get; set; }
    public string StoryIntro { get; set; }
    
    // 起始加成
    public int StartCredits { get; set; } = 1000;
    public int StartResearch { get; set; } = 0;
    public float ExploreBonus { get; set; } = 1.0f;
    public float ResearchBonus { get; set; } = 1.0f;
    public float CombatBonus { get; set; } = 1.0f;
}

public static class IdentityDB
{
    public static readonly Dictionary<string, IdentityData> All = new()
    {
        ["explorer"] = new IdentityData
        {
            Id = "explorer",
            Name = "探险家",
            Description = "追寻宇宙边缘的尽头",
            VictoryCondition = "发现所有界区",
            StoryIntro = "你是一名探险家，驾驶着飞船穿梭于星海之间，追寻着宇宙最终的边界...",
            StartCredits = 1500,
            ExploreBonus = 1.5f
        },
        ["archaeologist"] = new IdentityData
        {
            Id = "archaeologist",
            Name = "考古学家",
            Description = "追溯消失的超级文明",
            VictoryCondition = "解读上古文明谜题",
            StoryIntro = "你是一名考古学家，在星海中寻找着远古文明的遗迹，探寻宇宙历史的真相...",
            StartCredits = 1200,
            StartResearch = 100,
            ResearchBonus = 1.3f
        },
        ["scientist"] = new IdentityData
        {
            Id = "scientist",
            Name = "科学家",
            Description = "解开宇宙终极真理",
            VictoryCondition = "统一物理法则",
            StoryIntro = "你是一名科学家，致力于研究不同界区的物理法则，寻求宇宙的统一理论...",
            StartCredits = 1000,
            StartResearch = 200,
            ResearchBonus = 1.5f
        },
        ["soldier"] = new IdentityData
        {
            Id = "soldier",
            Name = "军人",
            Description = "在混乱中建立秩序",
            VictoryCondition = "征服敌对势力",
            StoryIntro = "你是一名军人，奉命在危险的界区中巡逻，维护宇宙的和平与秩序...",
            StartCredits = 1000,
            CombatBonus = 1.5f
        }
    };
}
