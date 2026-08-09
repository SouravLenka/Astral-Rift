extends Control

## ─────────────────────────────────────────────────────────────────────────────
## ASTRA: RIFT — StartupController.gd
## Cinematic startup sequence controller.
##
## Phase order:
##   1. Dark Space     — black → deep space reveal
##   2. Energy Point   — tiny rift energy appears at centre
##   3. Rift Formation — energy expands into a dimensional rift
##   4. SORA Reveal    — SORA text formed from rift energy
##   5. PRESENTS       — "PRESENTS" fades in beneath SORA
##   6. SORA Hold      — subtle breathe pulse while branding is visible
##   7. Rift Collapse  — SORA dissolves back into the rift
##   8. Rift Expansion — the rift tears open (the big moment)
##   9. ASTRA Title    — ASTRA: RIFT logo revealed from the rift
##  10. Transition     — fade to Main Menu
## ─────────────────────────────────────────────────────────────────────────────

# ── Configurable Timing (seconds) ─────────────────────────────────────────────
const SKIP_ENABLED                  := true
const MINIMUM_DISPLAY_TIME          := 1.5    # seconds before player can skip
const DARK_SPACE_DURATION           := 0.40
const ENERGY_INTRO_DURATION         := 0.52
const RIFT_FORM_DURATION            := 0.65
const SORA_REVEAL_DURATION          := 0.55
const SORA_HOLD_DURATION            := 0.32
const RIFT_COLLAPSE_DURATION        := 0.38
const RIFT_EXPAND_DURATION          := 0.42
const ASTRA_TITLE_DURATION          := 0.65
const COPYRIGHT_HOLD_DURATION       := 0.32
const MAIN_MENU_TRANSITION_DURATION := 0.48

# ── Colour Palette ─────────────────────────────────────────────────────────────
const COLOR_CYAN   := Color(0.310, 0.875, 1.000, 1.0)   # #4FDFFF
const COLOR_PURPLE := Color(0.784, 0.357, 1.000, 1.0)   # #C85BFF
const COLOR_WHITE  := Color(1.000, 1.000, 1.000, 1.0)
const COLOR_BLACK  := Color(0.000, 0.000, 0.000, 1.0)

# ── Node References ────────────────────────────────────────────────────────────
@onready var fade_overlay:        ColorRect       = $FadeOverlay
@onready var nebula_glow:         CanvasItem      = $Background/NebulaGlow
@onready var star_particles:      CPUParticles2D  = $Background/StarParticles

@onready var rift_outer_glow:     CanvasItem      = $RiftLayer/RiftOuterGlow
@onready var rift_mid_glow:       CanvasItem      = $RiftLayer/RiftMidGlow
@onready var rift_core:           CanvasItem      = $RiftLayer/RiftCore
@onready var rift_particles:      CPUParticles2D  = $RiftLayer/RiftParticles

@onready var sora_label:          Label           = $BrandingLayer/SoraLabel
@onready var presents_label:      Label           = $BrandingLayer/PresentsLabel

@onready var astra_label:         Label           = $TitleLayer/AstraLabel
@onready var copyright_label:     Label           = $TitleLayer/CopyrightLabel

@onready var skip_hint:           Label           = $SkipHint

@onready var startup_audio = $AudioLayer

# ── Internal State ─────────────────────────────────────────────────────────────
var _elapsed:        float = 0.0
var _can_skip:       bool  = false
var _skip_requested: bool  = false
var _sequence_done:  bool  = false
var _hold_tween:     Tween = null   # looping tween for SORA hold phase

# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	if not _startup_is_enabled():
		# Skip startup — go directly to main menu next frame to allow scene init.
		await get_tree().process_frame
		_go_to_main_menu()
		return
	_init_state()
	_run_sequence()


func _process(delta: float) -> void:
	_elapsed += delta
	if SKIP_ENABLED and _elapsed >= MINIMUM_DISPLAY_TIME and not _can_skip:
		_can_skip = true
		_show_skip_hint()


func _unhandled_input(event: InputEvent) -> void:
	if not SKIP_ENABLED or not _can_skip or _skip_requested or _sequence_done:
		return
	var pressed := false
	if event is InputEventKey       and (event as InputEventKey).pressed       and not (event as InputEventKey).echo:
		pressed = true
	elif event is InputEventMouseButton  and (event as InputEventMouseButton).pressed:
		pressed = true
	elif event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed:
		pressed = true
	if pressed:
		_skip_requested = true
		_trigger_skip()


# ─────────────────────────────────────────────────────────────────────────────
## Set every element to its pre-animation state.
func _init_state() -> void:
	# Full-screen black overlay starts opaque — reveals on phase 1
	fade_overlay.color = COLOR_BLACK

	# Nebula invisible
	nebula_glow.modulate.a = 0.0

	# Rift layers: tiny and transparent
	rift_outer_glow.modulate.a = 0.0
	rift_outer_glow.scale      = Vector2(0.08, 0.08)
	rift_mid_glow.modulate.a   = 0.0
	rift_mid_glow.scale        = Vector2(0.08, 0.08)
	rift_core.modulate.a       = 0.0
	rift_core.scale            = Vector2(0.04, 0.04)
	rift_particles.emitting    = false
	rift_particles.modulate.a  = 0.0

	# Branding and title completely hidden
	sora_label.modulate.a      = 0.0
	sora_label.scale           = Vector2(0.72, 0.72)
	presents_label.modulate.a  = 0.0

	astra_label.modulate.a     = 0.0
	astra_label.scale          = Vector2(0.80, 0.80)
	copyright_label.modulate.a = 0.0

	# Skip hint invisible
	skip_hint.modulate.a = 0.0


# ─────────────────────────────────────────────────────────────────────────────
## Main coroutine — phases execute sequentially.
func _run_sequence() -> void:
	await _phase_dark_space()
	if _should_abort(): return

	await _phase_energy_point()
	if _should_abort(): return

	await _phase_rift_formation()
	if _should_abort(): return

	await _phase_sora_reveal()
	if _should_abort(): return

	await _phase_sora_hold()
	if _should_abort(): return

	await _phase_rift_collapse()
	if _should_abort(): return

	await _phase_rift_expansion()
	if _should_abort(): return

	await _phase_astra_title()
	if _should_abort(): return

	_sequence_done = true
	skip_hint.modulate.a = 0.0
	await _phase_transition()


func _should_abort() -> bool:
	return _skip_requested or not is_inside_tree()


# ─────────────────────────────────────────────────────────────────────────────
## PHASE 1 — Dark Space
## Almost black screen fades into deep space.  Audio ambience begins.
func _phase_dark_space() -> void:
	startup_audio.play_ambience()
	var tw := create_tween().set_parallel(true)
	tw.tween_property(fade_overlay, "color:a", 0.0, DARK_SPACE_DURATION)\
	  .set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(nebula_glow, "modulate:a", 0.08, DARK_SPACE_DURATION)\
	  .set_ease(Tween.EASE_IN_OUT)
	await tw.finished


## PHASE 2 — Energy Point
## A tiny cyan energy point materialises at the rift centre.
func _phase_energy_point() -> void:
	startup_audio.play_energy_hum()
	var tw := create_tween().set_parallel(true)
	tw.tween_property(rift_core, "modulate:a", 1.0, ENERGY_INTRO_DURATION * 0.5)\
	  .set_ease(Tween.EASE_OUT)
	tw.tween_property(rift_core, "scale", Vector2(0.10, 0.10), ENERGY_INTRO_DURATION)\
	  .set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(rift_mid_glow, "modulate:a", 0.10, ENERGY_INTRO_DURATION)\
	  .set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(rift_mid_glow, "scale", Vector2(0.18, 0.18), ENERGY_INTRO_DURATION)\
	  .set_ease(Tween.EASE_OUT)
	await tw.finished
	# Small energy pulse before the rift begins to form
	await _scale_pulse(rift_core, 0.10, 0.13, 0.20)


## PHASE 3 — Rift Formation
## Energy expands into a dimensional rift with orbital particles.
func _phase_rift_formation() -> void:
	rift_particles.emitting = true
	var tw := create_tween().set_parallel(true)
	# Core grows into the rift opening
	tw.tween_property(rift_core, "scale", Vector2(0.40, 0.40), RIFT_FORM_DURATION)\
	  .set_ease(Tween.EASE_OUT)
	tw.tween_property(rift_core, "modulate", COLOR_CYAN, RIFT_FORM_DURATION * 0.55)
	# Mid glow expands
	tw.tween_property(rift_mid_glow, "scale", Vector2(0.68, 0.68), RIFT_FORM_DURATION)\
	  .set_ease(Tween.EASE_OUT)
	tw.tween_property(rift_mid_glow, "modulate:a", 0.55, RIFT_FORM_DURATION)
	# Outer glow phased in after the mid glow is visible
	tw.tween_property(rift_outer_glow, "modulate:a", 0.30, RIFT_FORM_DURATION)\
	  .set_delay(RIFT_FORM_DURATION * 0.35)
	tw.tween_property(rift_outer_glow, "scale", Vector2(0.65, 0.65), RIFT_FORM_DURATION)\
	  .set_ease(Tween.EASE_OUT).set_delay(RIFT_FORM_DURATION * 0.35)
	# Orbital particles brighten
	tw.tween_property(rift_particles, "modulate:a", 1.0, RIFT_FORM_DURATION * 0.5)\
	  .set_delay(RIFT_FORM_DURATION * 0.4)
	# Nebula deepens
	tw.tween_property(nebula_glow, "modulate:a", 0.22, RIFT_FORM_DURATION)
	await tw.finished
	# Rift "stabilises" — brief colour shift toward purple
	var stab_tw := create_tween()
	stab_tw.tween_property(rift_mid_glow, "modulate",\
	    Color(COLOR_PURPLE.r, COLOR_PURPLE.g, COLOR_PURPLE.b, 0.55), 0.22)
	await stab_tw.finished


## PHASE 4+5 — SORA Reveal + PRESENTS
## SORA letter-by-letter energy construction effect, then PRESENTS beneath.
func _phase_sora_reveal() -> void:
	var tw := create_tween().set_parallel(true)
	tw.tween_property(sora_label, "modulate:a", 1.0, SORA_REVEAL_DURATION)\
	  .set_ease(Tween.EASE_OUT)
	tw.tween_property(sora_label, "scale", Vector2(1.0, 1.0), SORA_REVEAL_DURATION)\
	  .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw.finished
	# Energy shimmer — simulates the letters being "formed" by rift energy
	await _shimmer_label(sora_label, 3, 0.09)
	startup_audio.play_sora_chime()
	# PRESENTS fades in beneath
	var tw2 := create_tween()
	tw2.tween_property(presents_label, "modulate:a", 1.0, 0.28)\
	   .set_ease(Tween.EASE_IN_OUT)
	await tw2.finished


## PHASE — SORA Hold
## SORA and PRESENTS are visible; a subtle breath pulse keeps it alive.
func _phase_sora_hold() -> void:
	_hold_tween = create_tween().set_loops()
	_hold_tween.tween_property(sora_label, "scale", Vector2(1.025, 1.025), 0.25)\
	           .set_ease(Tween.EASE_IN_OUT)
	_hold_tween.tween_property(sora_label, "scale", Vector2(1.0, 1.0), 0.25)\
	           .set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(SORA_HOLD_DURATION).timeout
	if _hold_tween != null:
		_hold_tween.kill()
		_hold_tween = null


## PHASE 7 — Rift Collapse
## SORA dissolves back into the rift.  The rift intensifies.
func _phase_rift_collapse() -> void:
	startup_audio.play_rift_collapse()
	var tw := create_tween().set_parallel(true)
	# SORA expands and fades — dissolving into energy
	tw.tween_property(sora_label, "scale", Vector2(1.18, 1.18), RIFT_COLLAPSE_DURATION * 0.65)\
	  .set_ease(Tween.EASE_IN)
	tw.tween_property(sora_label, "modulate:a", 0.0, RIFT_COLLAPSE_DURATION * 0.65)\
	  .set_ease(Tween.EASE_IN)
	tw.tween_property(presents_label, "modulate:a", 0.0, RIFT_COLLAPSE_DURATION * 0.45)\
	  .set_ease(Tween.EASE_IN)
	# Rift intensifies as the energy returns
	tw.tween_property(rift_core, "modulate", COLOR_WHITE, RIFT_COLLAPSE_DURATION)
	tw.tween_property(rift_core, "scale", Vector2(0.28, 0.28), RIFT_COLLAPSE_DURATION)\
	  .set_ease(Tween.EASE_IN)
	tw.tween_property(rift_mid_glow, "modulate:a", 0.75, RIFT_COLLAPSE_DURATION)
	tw.tween_property(rift_outer_glow, "modulate:a", 0.40, RIFT_COLLAPSE_DURATION)
	await tw.finished


## PHASE 8 — Rift Expansion (the cinematic peak)
## The rift tears open — screen fills with energy before clearing.
func _phase_rift_expansion() -> void:
	startup_audio.play_rift_whoosh()
	var tw := create_tween().set_parallel(true)
	# Core rips outward
	tw.tween_property(rift_core, "scale", Vector2(5.5, 5.5), RIFT_EXPAND_DURATION * 0.55)\
	  .set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tw.tween_property(rift_core, "modulate:a", 0.0, RIFT_EXPAND_DURATION * 0.55)\
	  .set_delay(RIFT_EXPAND_DURATION * 0.25)
	# Mid glow floods outward
	tw.tween_property(rift_mid_glow, "scale", Vector2(4.2, 4.2), RIFT_EXPAND_DURATION)\
	  .set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(rift_mid_glow, "modulate:a", 0.0, RIFT_EXPAND_DURATION)\
	  .set_delay(RIFT_EXPAND_DURATION * 0.2)
	# Outer glow floods screen
	tw.tween_property(rift_outer_glow, "scale", Vector2(6.5, 6.5), RIFT_EXPAND_DURATION)\
	  .set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(rift_outer_glow, "modulate:a", 0.0, RIFT_EXPAND_DURATION)\
	  .set_delay(RIFT_EXPAND_DURATION * 0.28)
	# Dimensional energy flash across entire screen
	tw.tween_property(fade_overlay, "color",\
	    Color(0.22, 0.65, 1.0, 0.92), RIFT_EXPAND_DURATION * 0.18)\
	  .set_trans(Tween.TRANS_EXPO)
	# Nebula shifts to purple depth during rift tear
	tw.tween_property(nebula_glow, "modulate",\
	    Color(COLOR_PURPLE.r, COLOR_PURPLE.g, COLOR_PURPLE.b, 0.55), RIFT_EXPAND_DURATION)
	await tw.finished

	# Flash fades — we have emerged on the other side of the rift
	var fade_tw := create_tween().set_parallel(true)
	fade_tw.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), RIFT_EXPAND_DURATION * 0.9)\
	       .set_ease(Tween.EASE_IN_OUT)
	fade_tw.tween_property(rift_particles, "modulate:a", 0.0, RIFT_EXPAND_DURATION * 0.55)
	await fade_tw.finished


## PHASE 9+10 — ASTRA: RIFT Title
## Post-rift deep space settling, then ASTRA: RIFT revealed.
func _phase_astra_title() -> void:
	startup_audio.play_title_impact()
	# Settle nebula colour to calm deep cyan-space
	var settle_tw := create_tween().set_parallel(true)
	settle_tw.tween_property(nebula_glow, "modulate", Color(0.30, 0.88, 1.0, 0.22), 0.38)\
	         .set_ease(Tween.EASE_IN_OUT)
	# Start revealing the title with a short delay
	settle_tw.tween_property(astra_label, "modulate:a", 1.0, ASTRA_TITLE_DURATION)\
	         .set_delay(0.22).set_ease(Tween.EASE_OUT)
	settle_tw.tween_property(astra_label, "scale", Vector2(1.0, 1.0), ASTRA_TITLE_DURATION)\
	         .set_delay(0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await settle_tw.finished

	# Energy shimmer across the title letters
	await _shimmer_label(astra_label, 2, 0.10)

	# Copyright fades in subtly beneath
	var cr_tw := create_tween()
	cr_tw.tween_property(copyright_label, "modulate:a", 0.65, 0.22)
	await cr_tw.finished

	# Hold so the player can read the title
	await get_tree().create_timer(COPYRIGHT_HOLD_DURATION).timeout


## PHASE 12 — Transition to Main Menu
## Fade to black, then load the main menu.
func _phase_transition() -> void:
	var tw := create_tween().set_parallel(true)
	tw.tween_property(astra_label,     "modulate:a", 0.0, MAIN_MENU_TRANSITION_DURATION * 0.7)
	tw.tween_property(copyright_label, "modulate:a", 0.0, MAIN_MENU_TRANSITION_DURATION * 0.4)
	tw.tween_property(nebula_glow,     "modulate:a", 0.0, MAIN_MENU_TRANSITION_DURATION)
	tw.tween_property(fade_overlay, "color", COLOR_BLACK, MAIN_MENU_TRANSITION_DURATION)\
	  .set_ease(Tween.EASE_IN)
	await tw.finished
	_go_to_main_menu()


# ─────────────────────────────────────────────────────────────────────────────
## Player requested skip: fast fade and jump to main menu.
func _trigger_skip() -> void:
	if _hold_tween != null:
		_hold_tween.kill()
		_hold_tween = null
	var skip_tw := create_tween()
	skip_tw.tween_property(fade_overlay, "color", COLOR_BLACK, 0.28)\
	       .set_ease(Tween.EASE_IN)
	await skip_tw.finished
	if is_inside_tree():
		_go_to_main_menu()


func _go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")


# ─────────────────────────────────────────────────────────────────────────────
## Utility: scale a node from base to peak and back (energy pulse).
func _scale_pulse(node: CanvasItem, base: float, peak: float, duration: float) -> void:
	var tw := create_tween()
	tw.tween_property(node, "scale", Vector2(peak, peak), duration * 0.5)\
	  .set_ease(Tween.EASE_OUT)
	tw.tween_property(node, "scale", Vector2(base, base), duration * 0.5)\
	  .set_ease(Tween.EASE_IN)
	await tw.finished


## Utility: shimmer brightness flash on a Label — simulates energy construction.
func _shimmer_label(label: Label, count: int, interval: float) -> void:
	for _i in count:
		var tw := create_tween()
		tw.tween_property(label, "modulate", Color(1.35, 1.5, 1.5, 1.0), interval * 0.5)\
		  .set_ease(Tween.EASE_OUT)
		tw.tween_property(label, "modulate", Color.WHITE, interval * 0.5)\
		  .set_ease(Tween.EASE_IN)
		await tw.finished


## Utility: fade in the skip hint label.
func _show_skip_hint() -> void:
	var tw := create_tween()
	tw.tween_property(skip_hint, "modulate:a", 0.60, 0.4)


## Utility: safe audio play — logs a warning if no stream is assigned.
func _play_audio(player: AudioStreamPlayer) -> void:
	if player == null: return
	if player.stream == null:
		push_warning("StartupController: No audio stream assigned to '%s' — skipping." % player.name)
		return
	if not player.playing:
		player.play()


# ─────────────────────────────────────────────────────────────────────────────
## Read whether the startup animation is enabled from a lightweight config file.
## Default is enabled (ON).  Connect to a SaveManager later if one is added.
func _startup_is_enabled() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load("user://startup_config.cfg") != OK:
		return true   # Default: ON
	return cfg.get_value("startup", "enabled", true)


## Call from a Settings screen to persist the startup ON/OFF toggle.
func save_startup_setting(enabled: bool) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("startup", "enabled", enabled)
	if cfg.save("user://startup_config.cfg") != OK:
		push_error("StartupController: Could not save startup_config.cfg")
