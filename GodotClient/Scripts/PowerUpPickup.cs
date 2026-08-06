using Godot;

public enum PowerUpType { TripleShot, RapidFire, SpeedBoost, DoubleDamage }

public partial class PowerUpPickup : Node2D
{
    private const float PickupRadius = 26f;
    private readonly PowerUpType _type;
    private readonly float _duration;
    private float _age;

    public PowerUpPickup(Vector2 position, PowerUpType type, float duration = 8f)
    {
        Position = position;
        _type = type;
        _duration = duration;
        Name = $"{type}Pickup";
        AddToGroup("powerups");
    }

    public override void _Ready() => QueueRedraw();

    public override void _Process(double delta)
    {
        _age += (float)delta;
        foreach (var node in GetTree().GetNodesInGroup("pilots"))
        {
            if (node is not Pilot pilot || Position.DistanceTo(pilot.Position) > PickupRadius + 15) continue;
            pilot.ApplyPowerUp(_type, _duration);
            QueueFree();
            return;
        }
        if (_age > 15f) QueueFree();
        QueueRedraw();
    }

    public override void _Draw()
    {
        var color = _type switch
        {
            PowerUpType.TripleShot => Color.FromHtml("A878FF"),
            PowerUpType.RapidFire => Color.FromHtml("FFDD57"),
            PowerUpType.SpeedBoost => Color.FromHtml("62F4B6"),
            _ => Color.FromHtml("FF6377")
        };
        var pulse = 1f + Mathf.Sin(_age * 5f) * .12f;
        DrawCircle(Vector2.Zero, 14 * pulse, new Color(color.R, color.G, color.B, .18f));
        DrawCircle(Vector2.Zero, 9, color);
        DrawString(ThemeDB.FallbackFont, new Vector2(-5, 5), "+", HorizontalAlignment.Left, -1, 16, Colors.White);
    }
}
