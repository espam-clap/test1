extends Control

signal game_exited

func _on_back_button_pressed():
    game_exited.emit()
    hide()
