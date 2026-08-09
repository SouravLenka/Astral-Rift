## PlayerHUD.gd
## Signal-driven player stats panel (health, shield, ultimate, weapon, coins, lives, score).
## Set player_id = 0 for P1 (cyan), 1 for P2 (purple).
extends PanelContainer

@export var player_id: int = 0

@onready var avatar_rect: ColorRect    = $Margin/VBox/HeaderRow/AvatarBox/AvatarRect
@onready var player_label: Label       = $Margin/VBox/HeaderRow/VBox/PlayerLabel
@onready var role_label: Label         = $Margin/VBox/HeaderRow/VBox/RoleLabel
@onready var health_bar: ProgressBar   = $Margin/VBox/Bars/HealthBar
@onready var shield_bar: ProgressBar   = $Margin/VBox/Bars/ShieldBar
@onready var ultimate_bar: ProgressBar = $Margin/VBox/Bars/UltimateRow/UltimateBar
@onready var ult_percent_lbl: Label    = $Margin/VBox/Bars/UltimateRow/UltPercentLabel
@onready var score_label: Label        = $Margin/VBox/StatsRow/ScoreLabel
@onready var coin_label: Label         = $Margin/VBox/StatsRow/CoinLabel
@onready var lives_label: Label        = $Margin/VBox/StatsRow/LivesLabel
@onready var weapon_label: Label       = $Margin/VBox/WeaponRow/WeaponLabel

const CYAN: Color   = Color("#4FDFFF")
const PURPLE: Color = Color("#C85BFF")
const DARK_BG: Color = Color("#101C30")

func _ready() -> void:
	_apply_color()
	_connect_signals()

func _apply_color() -> void:
	var accent: Color = CYAN if player_id == 0 else PURPLE
	player_label.text = "PILOT 01" if player_id == 0 else "PILOT 02"
	role_label.text   = "CYAN VANGUARD" if player_id == 0 else "PURPLE REAPER"
	
	player_label.add_theme_color_override("font_color", accent)
	avatar_rect.color = accent
	ult_percent_lbl.text = ("X" if player_id == 0 else "BACKSPACE") + " · 0%"
	
	_style_bar(health_bar, Color("#FF5252"), Color("#101C30"))
	_style_bar(shield_bar, accent, Color("#101C30"))
	_style_bar(ultimate_bar, Color("#FF8C42"), Color("#101C30"))
	_style_panel(accent)

func _style_bar(bar: ProgressBar, fill: Color, bg: Color) -> void:
	var fill_style: StyleBoxFlat = StyleBoxFlat.new()
	fill_style.bg_color = fill
	fill_style.corner_radius_top_left = 4
	fill_style.corner_radius_top_right = 4
	fill_style.corner_radius_bottom_left = 4
	fill_style.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("fill", fill_style)
	
	var bg_style: StyleBoxFlat = StyleBoxFlat.new()
	bg_style.bg_color = Color(bg, 0.6)
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_left = 4
	bg_style.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("background", bg_style)

func _style_panel(accent: Color) -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#101C30E6")
	style.border_color = Color(accent, 0.75)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_size = 8
	add_theme_stylebox_override("panel", style)

func _connect_signals() -> void:
	GameEvents.player_health_changed.connect(_on_health)
	GameEvents.player_shield_changed.connect(_on_shield)
	GameEvents.score_updated.connect(_on_score)
	GameEvents.coin_updated.connect(_on_coin)
	GameEvents.player_lives_changed.connect(_on_lives)
	GameEvents.weapon_changed.connect(_on_weapon)
	GameEvents.ultimate_charge.connect(_on_ultimate)

func _on_health(p_id: int, health: float, max_health: float) -> void:
	if p_id != player_id: return
	var pct: float = (health / max_health) * 100.0
	var tw: Tween = create_tween()
	tw.tween_property(health_bar, "value", pct, 0.25).set_ease(Tween.EASE_OUT)

func _on_shield(p_id: int, shield: float, max_shield: float) -> void:
	if p_id != player_id: return
	var pct: float = (shield / max_shield) * 100.0
	var tw: Tween = create_tween()
	tw.tween_property(shield_bar, "value", pct, 0.25).set_ease(Tween.EASE_OUT)

func _on_score(p_id: int, score: int) -> void:
	if p_id != player_id: return
	score_label.text = "⭐ %06d" % score

func _on_coin(p_id: int, coins: int) -> void:
	if p_id != player_id: return
	coin_label.text = "🪙 %d" % coins
	var tw: Tween = create_tween()
	tw.tween_property(coin_label, "scale", Vector2(1.2, 1.2), 0.1)
	tw.tween_property(coin_label, "scale", Vector2.ONE, 0.1)

func _on_lives(p_id: int, lives: int) -> void:
	if p_id != player_id: return
	lives_label.text = "♥ x%d" % lives

func _on_weapon(p_id: int, wname: String) -> void:
	if p_id != player_id: return
	weapon_label.text = "⚔ " + wname

func _on_ultimate(p_id: int, percent: float) -> void:
	if p_id != player_id: return
	var val: float = percent * 100.0
	var ultimate_key := "X" if player_id == 0 else "BACKSPACE"
	ult_percent_lbl.text = "%s · %d%%" % [ultimate_key, int(val)]
	var tw: Tween = create_tween()
	tw.tween_property(ultimate_bar, "value", val, 0.2).set_ease(Tween.EASE_OUT)
	if percent >= 1.0:
		ult_percent_lbl.text = ("X" if player_id == 0 else "BACKSPACE") + " · READY"
		ult_percent_lbl.add_theme_color_override("font_color", Color("#FF8C42"))
