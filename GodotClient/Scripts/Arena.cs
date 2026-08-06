using Godot;

namespace AstralRift;

public partial class Arena : Node2D
{
    private const float ArenaWidth = 1280f;
    private const float ArenaHeight = 720f;
    private readonly RandomNumberGenerator _random = new();
    private int _wave;
    private int _enemiesToSpawn;
    private float _spawnTimer;
    private float _nextWaveTimer = 1.5f;
    private float _powerUpTimer = 7f;
    private Label _status = null!;

    public override void _Ready()
    {
        QueueRedraw();
        AddChild(new Pilot("Pilot One", new Vector2(360, 360), Color.FromHtml("55D6FF"), "p1_move_left", "p1_move_right", "p1_move_up", "p1_move_down", "p1_fire"));
        AddChild(new Pilot("Pilot Two", new Vector2(920, 360), Color.FromHtml("FF74C8"), "p2_move_left", "p2_move_right", "p2_move_up", "p2_move_down", "p2_fire"));
        var hud = new CanvasLayer();
        _status = new Label { Position = new Vector2(24, 18), Text = "ASTRAL RIFT" };
        _status.AddThemeFontSizeOverride("font_size", 24);
        hud.AddChild(_status);
        AddChild(hud);
    }

    public override void _Process(double delta)
    {
        _powerUpTimer -= (float)delta;
        if (_powerUpTimer <= 0 && GetTree().GetNodesInGroup("powerups").Count == 0)
        {
            SpawnPowerUp();
            _powerUpTimer = _random.RandfRange(10f, 15f);
        }
        if (_enemiesToSpawn > 0)
        {
            _spawnTimer -= (float)delta;
            if (_spawnTimer <= 0) { SpawnEnemy(); _enemiesToSpawn--; _spawnTimer = 0.55f; }
        }
        else if (GetTree().GetNodesInGroup("enemies").Count == 0)
        {
            _nextWaveTimer -= (float)delta;
            if (_nextWaveTimer <= 0) BeginWave();
        }
        _status.Text = $"ASTRAL RIFT  |  WAVE {_wave}  |  ENEMIES {GetTree().GetNodesInGroup("enemies").Count + _enemiesToSpawn}";
    }

    public override void _Draw()
    {
        DrawRect(new Rect2(Vector2.Zero, new Vector2(ArenaWidth, ArenaHeight)), Color.FromHtml("07101F"));
        for (var x = 0; x < ArenaWidth; x += 64) DrawLine(new Vector2(x, 0), new Vector2(x, ArenaHeight), Color.FromHtml("10213D"));
        for (var y = 0; y < ArenaHeight; y += 64) DrawLine(new Vector2(0, y), new Vector2(ArenaWidth, y), Color.FromHtml("10213D"));
        DrawRect(new Rect2(8, 8, ArenaWidth - 16, ArenaHeight - 16), Color.FromHtml("2B568C"), false, 2);
    }

    private void BeginWave() { _wave++; _enemiesToSpawn = 4 + _wave * 2; _spawnTimer = 0; _nextWaveTimer = 2f; }
    private void SpawnEnemy()
    {
        var position = _random.RandiRange(0, 3) switch
        {
            0 => new Vector2(_random.RandfRange(30, ArenaWidth - 30), 30),
            1 => new Vector2(ArenaWidth - 30, _random.RandfRange(30, ArenaHeight - 30)),
            2 => new Vector2(_random.RandfRange(30, ArenaWidth - 30), ArenaHeight - 30),
            _ => new Vector2(30, _random.RandfRange(30, ArenaHeight - 30))
        };
        AddChild(new Drone(position));
    }

    private void SpawnPowerUp()
    {
        var type = (PowerUpType)_random.RandiRange(0, 3);
        var position = new Vector2(_random.RandfRange(100, ArenaWidth - 100), _random.RandfRange(120, ArenaHeight - 80));
        AddChild(new PowerUpPickup(position, type));
    }
}
