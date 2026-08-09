## Lightweight procedural sound layer for the startup sequence.
## It intentionally is not an autoload or audio manager: it lives and dies with Startup.tscn.
extends Node

const MIX_RATE := 22050.0
const AMBIENCE := &"Ambience"
const ENERGY := &"Energy"
const SORA_CHIME := &"SoraChime"
const RIFT := &"Rift"
const TITLE := &"Title"

var _players: Dictionary = {}
var _voices: Array[Dictionary] = []

func _ready() -> void:
	_create_player(AMBIENCE, -30.0)
	_create_player(ENERGY, -24.0)
	_create_player(SORA_CHIME, -15.0)
	_create_player(RIFT, -14.0)
	_create_player(TITLE, -16.0)

func play_ambience() -> void:
	if not _has_voice(AMBIENCE): _start_voice(AMBIENCE, [48.0, 71.0], 6.0, 0.035, true)
func play_energy_hum() -> void: _start_voice(ENERGY, [140.0, 211.0], 1.7, 0.055, false)
func play_sora_chime() -> void: _start_voice(SORA_CHIME, [523.25, 659.25, 783.99], 0.55, 0.11, false)
func play_rift_collapse() -> void: _start_voice(RIFT, [310.0, 155.0], 0.38, 0.08, false)
func play_rift_whoosh() -> void: _start_voice(RIFT, [92.0, 370.0], 0.70, 0.12, false)
func play_title_impact() -> void: _start_voice(TITLE, [82.0, 164.0, 328.0], 0.58, 0.10, false)

func _process(_delta: float) -> void:
	for voice in _voices.duplicate():
		var elapsed: float = voice.elapsed
		var playback: AudioStreamGeneratorPlayback = voice.playback
		var available := playback.get_frames_available()
		for frame in available:
			var time := elapsed + float(frame) / MIX_RATE
			if not voice.looping and time >= voice.duration: break
			var sample := 0.0
			for frequency in voice.frequencies: sample += sin(TAU * float(frequency) * time)
			sample = sample / float(voice.frequencies.size()) * voice.amplitude * _envelope(time, voice.duration, voice.looping)
			playback.push_frame(Vector2(sample, sample))
		elapsed += float(available) / MIX_RATE
		voice.elapsed = elapsed
		if not voice.looping and elapsed >= voice.duration:
			(_players[voice.name] as AudioStreamPlayer).stop()
			_voices.erase(voice)
		else: _voices[_voices.find(voice)] = voice

func _create_player(name: StringName, volume_db: float) -> void:
	var player := AudioStreamPlayer.new()
	player.name = name
	player.bus = _available_bus("SFX" if name != AMBIENCE else "Ambient")
	player.volume_db = volume_db
	add_child(player)
	_players[name] = player

func _start_voice(name: StringName, frequencies: Array[float], duration: float, amplitude: float, looping: bool) -> void:
	_stop_voice(name)
	var player: AudioStreamPlayer = _players[name]
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = MIX_RATE
	generator.buffer_length = 0.25
	player.stream = generator
	player.play()
	_voices.append({"name": name, "playback": player.get_stream_playback(), "frequencies": frequencies, "duration": duration, "amplitude": amplitude, "looping": looping, "elapsed": 0.0})

func _stop_voice(name: StringName) -> void:
	for voice in _voices.duplicate():
		if voice.name == name: _voices.erase(voice)
	if _players.has(name): (_players[name] as AudioStreamPlayer).stop()

func _has_voice(name: StringName) -> bool:
	return _voices.any(func(voice: Dictionary) -> bool: return voice.name == name)

func _available_bus(preferred: StringName) -> StringName:
	return preferred if AudioServer.get_bus_index(preferred) >= 0 else &"Master"

func _envelope(time: float, duration: float, looping: bool) -> float:
	if looping: return 0.62 + sin(time * 0.65) * 0.18
	return max(0.0, min(time / 0.045, 1.0) * min((duration - time) / 0.16, 1.0))
