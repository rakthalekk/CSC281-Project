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

func _ready():
	disable_all()
	_on_PlayTab_pressed()
	
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
	musicSlider.disabled = false
	musicSlider.mouse_filter = Control.MOUSE_FILTER_STOP
	difficultyButton.disabled = false
	difficultyButton.mouse_filter = Control.MOUSE_FILTER_STOP
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
	musicSlider.disabled = true
	musicSlider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorialButton.disabled = true
	tutorialButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	startButton.disabled = true
	startButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quitButton.disabled = true
	quitButton.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_MusicSlider_pressed():
	MusicSliderVisual.rect_size.x = MusicSliderVisual.get_local_mouse_position().x

func _on_DifficultyButton_pressed():
	var current = difficultyVisual.frame
	current = (current + 1) % 3
	difficultyVisual.frame = current
