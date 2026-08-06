using Godot;

namespace AstralRift;

public partial class Drone : Node2D
{
    private float _health = 2;
    public Drone(Vector2 position) { Position = position; AddToGroup("enemies"); }
    public override void _Ready() => QueueRedraw();
    public override void _Process(double delta)
    {
        Node2D? target = null; var nearestDistance = float.MaxValue;
        foreach (var node in GetTree().GetNodesInGroup("pilots"))
            if (node is Node2D pilot && Position.DistanceTo(pilot.Position) < nearestDistance) { target = pilot; nearestDistance = Position.DistanceTo(pilot.Position); }
        if (target is not null) Position += Position.DirectionTo(target.Position) * 90f * (float)delta;
    }
    public void TakeDamage(float amount = 1) { _health -= amount; if (_health <= 0) QueueFree(); else QueueRedraw(); }
    public override void _Draw()
    {
        DrawCircle(Vector2.Zero, 14, _health >= 2 ? Color.FromHtml("FFB84D") : Color.FromHtml("FF625D"));
        DrawCircle(Vector2.Zero, 6, Color.FromHtml("241326"));
    }
}
