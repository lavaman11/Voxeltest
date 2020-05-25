extends KinematicBody2D

var knockback = Vector2.ZERO
var state = CHASE
var velocity = Vector2.ZERO

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

onready var stats = $Stats
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox



func _ready():
	animationTree.active = true

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
		WANDER:
			pass
			
		CHASE:
			chase_state(delta)
			
	velocity = move_and_slide(velocity)
	
func chase_state(delta):
	
	var player = playerDetectionZone.player
	
	if player != null:
		var playerdirection = (player.global_position - global_position).normalized()
		animationTree.set("parameters/Run/blend_position", playerdirection)
		animationState.travel("Run")
		velocity = velocity.move_toward(playerdirection * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	

func wander():
	if playerDetectionZone.can_not_see_player():
		state = WANDER

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()


func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
