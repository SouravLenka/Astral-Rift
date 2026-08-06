using Godot;

public partial class Pilot : Node2D
{
    private readonly Color _color;
    private readonly string _left, _right, _up, _down, _fire;
    private float _cooldown;
    private float _speedMultiplier = 1f;
    private float _fireRateMultiplier = 1f;
    private float _damageMultiplier = 1f;
    private float _tripleShotRemaining;
    private float _speedBoostRemaining;
    private float _rapidFireRemaining;
    private float _doubleDamageRemaining;
    private Vector2 _lookDirection = Vector2.Up;
    private const float Speed = 340f;

    public Pilot(string pilotName, Vector2 position, Color color, string left, string right, string up, string down, string fire)
    {
        Position = position; _color = color; _left = left; _right = right; _up = up; _down = down; _fire = fire;
        Name = pilotName.Replace(" ", "");
        AddToGroup("pilots");
    }

    public override void _Ready() => QueueRedraw();
    public override void _Process(double delta)
    {
        var direction = Input.GetVector(_left, _right, _up, _down);
        Position += direction * Speed * _speedMultiplier * (float)delta;
        Position = new Vector2(Mathf.Clamp(Position.X, 30, 1250), Mathf.Clamp(Position.Y, 55, 690));
        if (direction != Vector2.Zero) _lookDirection = direction.Normalized();
        _cooldown -= (float)delta;
        UpdatePowerUpTimers((float)delta);
        if (Input.IsActionPressed(_fire) && _cooldown <= 0)
        {
            Fire();
            _cooldown = 0.18f / _fireRateMultiplier;
        }
    }

    public void ApplyPowerUp(PowerUpType type, float duration)
    {
        switch (type)
        {
            case PowerUpType.TripleShot: _tripleShotRemaining = duration; break;
            case PowerUpType.RapidFire: _rapidFireRemaining = duration; _fireRateMultiplier = 1.75f; break;
            case PowerUpType.SpeedBoost: _speedBoostRemaining = duration; _speedMultiplier = 1.4f; break;
            case PowerUpType.DoubleDamage: _doubleDamageRemaining = duration; _damageMultiplier = 2f; break;
        }
    }

    private void Fire()
    {
        SpawnProjectile(_lookDirection);
        if (_tripleShotRemaining <= 0) return;
        SpawnProjectile(_lookDirection.Rotated(Mathf.DegToRad(-15)));
        SpawnProjectile(_lookDirection.Rotated(Mathf.DegToRad(15)));
    }

    private void SpawnProjectile(Vector2 direction) => GetParent().AddChild(new Projectile(Position + direction * 24, direction, _color, _damageMultiplier));

    private void UpdatePowerUpTimers(float delta)
    {
        _tripleShotRemaining = Mathf.Max(0, _tripleShotRemaining - delta);
        _speedBoostRemaining = Mathf.Max(0, _speedBoostRemaining - delta);
        _rapidFireRemaining = Mathf.Max(0, _rapidFireRemaining - delta);
        _doubleDamageRemaining = Mathf.Max(0, _doubleDamageRemaining - delta);
        if (_speedBoostRemaining <= 0) _speedMultiplier = 1f;
        if (_rapidFireRemaining <= 0) _fireRateMultiplier = 1f;
        if (_doubleDamageRemaining <= 0) _damageMultiplier = 1f;
    }
    public override void _Draw()
    {
        DrawCircle(Vector2.Zero, 18, new Color(_color.R, _color.G, _color.B, 0.15f));
        DrawCircle(Vector2.Zero, 11, _color);
        DrawLine(Vector2.Zero, _lookDirection * 24, Colors.White, 3);
    }
}
