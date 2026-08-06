using Godot;

public partial class Projectile : Node2D
{
    private readonly Vector2 _direction;
    private readonly Color _color;
    private readonly float _damage;
    private float _life = 1.4f;
    public Projectile(Vector2 position, Vector2 direction, Color color, float damage = 1f) { Position = position; _direction = direction; _color = color; _damage = damage; }
    public override void _Ready() => QueueRedraw();
    public override void _Process(double delta)
    {
        Position += _direction * 700f * (float)delta; _life -= (float)delta;
        foreach (var node in GetTree().GetNodesInGroup("enemies"))
            if (node is Drone drone && Position.DistanceTo(drone.Position) < 22) { drone.TakeDamage(_damage); QueueFree(); return; }
        if (_life <= 0) QueueFree();
    }
    public override void _Draw() => DrawCircle(Vector2.Zero, 4, _color);
}
