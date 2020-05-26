extends Node

export(int) var max_health = 1 setget set_max_health
var health = max_health setget set_health

const Restart = preload("res://Player/Restart.tscn")
const Player = preload("res://Player/Player.tscn")

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", health)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")
		var restart = Restart.instance()
		get_parent().add_child(restart)
func _ready():
	self.health = max_health


func _on_TextureButton_pressed():
	if Input.action_press("restart"):
		var player = Player.instance()
		get_parent().add_child(player)
		
	
