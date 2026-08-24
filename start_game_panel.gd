extends Panel

@export var sfx_slider: HSlider
@export var music_slider: HSlider

# Called when the node enters the scene tree for the first time.
func _ready():
	$SafeModeLabel.text = "Ваш рекорд: %d м. %02d сек." % [floori(BGMusic.record_time / 60), posmod(BGMusic.record_time, 60)]
	
	sfx_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("SFX"))
	music_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music"))
	
	sfx_slider.value_changed.connect(func(value):
		if !$SoundCheck.playing or $SoundCheck.get_playback_position() > 0.1:
			$SoundCheck.play()
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value)
		)
	music_slider.value_changed.connect(func(value):
		if (!$SoundCheck.playing or $SoundCheck.get_playback_position() > 0.1) and !BGMusic.playing:
			$SoundCheck.play()
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), value)
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
