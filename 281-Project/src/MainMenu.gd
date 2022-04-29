extends Control

onready var menuVisual = $Folder
onready var startButton = $Folder/StartButton
onready var quitButton = $Folder/QuitButton
onready var tutorialButton = $Folder/TutorialButton
onready var musicSlider = $Folder/MusicSlider
onready var MusicSliderVisual = $Folder/MusicSliderVisual
onready var difficultyButton = $Folder/DifficultyButton
onready var difficultyVisual = $Folder/Difficulty
onready var audio = $AudioStreamPlayer
onready var soundSlider = $Folder/SoundSlider
onready var soundSliderVisual = $Folder/SoundSliderVisual

func _ready():
	disable_all()
	_on_PlayTab_pressed()
	MusicSliderVisual.rect_size.x = Global.music * 230
	soundSliderVisual.rect_size.x = Global.sound * 230
	difficultyVisual.frame = 1
	setSoundVolumes(Global.sound)
	setMusicVolume(Global.music)
	
func noise():
	audio.play()

func _on_StartButton_pressed():
	get_tree().change_scene("res://src/Main.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_PlayTab_pressed():
	noise()
	menuVisual.frame = 0
	disable_all()
	startButton.mouse_filter = Control.MOUSE_FILTER_STOP
	startButton.disabled = false

func _on_TutorialTab_pressed():
	noise()
	disable_all()
	tutorialButton.mouse_filter = Control.MOUSE_FILTER_STOP
	tutorialButton.disabled = false
	menuVisual.frame = 1

func _on_SettingsTab_pressed():
	noise()
	disable_all()
	MusicSliderVisual.show()
	difficultyVisual.show()
	soundSliderVisual.show()
	musicSlider.disabled = false
	musicSlider.mouse_filter = Control.MOUSE_FILTER_STOP
	difficultyButton.disabled = false
	difficultyButton.mouse_filter = Control.MOUSE_FILTER_STOP
	soundSlider.disabled = false
	soundSlider.mouse_filter = Control.MOUSE_FILTER_STOP
	menuVisual.frame = 2

func _on_ExitTab_pressed():
	noise()
	menuVisual.frame = 3
	disable_all()
	quitButton.mouse_filter = Control.MOUSE_FILTER_STOP
	quitButton.disabled = false

func _on_TutorialButton_pressed():
	disable_all()
	get_tree().change_scene("res://src/Tutorial.tscn")
	
func disable_all():
	difficultyButton.disabled = true
	difficultyButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	MusicSliderVisual.hide()
	difficultyVisual.hide()
	soundSliderVisual.hide()
	musicSlider.disabled = true
	musicSlider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorialButton.disabled = true
	tutorialButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	startButton.disabled = true
	startButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quitButton.disabled = true
	quitButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	soundSlider.disabled = true
	soundSlider.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_MusicSlider_pressed():
	MusicSliderVisual.rect_size.x = MusicSliderVisual.get_local_mouse_position().x
	setMusicVolume(MusicSliderVisual.rect_size.x / 230)

func _on_DifficultyButton_pressed():
	var current = difficultyVisual.frame
	current = (current + 1) % 3
	Global.difficulty = current
	difficultyVisual.frame = current


func _on_SoundSlider_pressed():
	soundSliderVisual.rect_size.x = soundSliderVisual.get_local_mouse_position().x
	setSoundVolumes(soundSliderVisual.rect_size.x / 230)

func setSoundVolumes(vol):
	Global.sound = vol
	if(vol > 0.1):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("World"), vol * 24 - 18)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("World"), -76)

func setMusicVolume(vol):
	Global.music = vol
	if(vol > 0.1):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), vol * 24 - 18)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -76)
