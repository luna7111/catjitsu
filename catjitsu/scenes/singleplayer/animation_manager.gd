extends Node2D

@onready var battle_manager = $"../BattleManager"

var center_screen_x

func _ready() -> void:
	center_screen_x = get_viewport().get_visible_rect().size.x / 2

func show_point(element, score, player):
	var target_points
	if player == "Player":
		target_points = $"../PlayerPoints"
	else:
		target_points = $"../OpponentPoints"
	var sprite_folder = target_points.get_node("%s" % [element])
	sprite_folder.visible = true
	var sprite = target_points.get_node("%s/%s%d" % [element, element, score])
	sprite.visible = true

func play_card_from_opponent_hand_animation(card, opponent_card_slot):
	var tween = get_tree().create_tween()
	tween.tween_property(
		card,
		"position",
		Vector2(opponent_card_slot.position.x, opponent_card_slot.position.y),
		0.2
	)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(
		card,
		"scale",
		Vector2(1, 1),
		0.2
	)
	card.get_node("AnimationPlayer").play("card_flip")

func animate_cards_battle_phase(player_card_on_slot, opponent_card_on_slot):
	var opponent_original_position = opponent_card_on_slot.position
	var player_original_position = player_card_on_slot.position

	for i in range(3):
		var tween = create_tween()

		tween.parallel().tween_property(
			opponent_card_on_slot,
			"position",
			opponent_original_position - Vector2(210, 0),
			0.2
		)

		tween.parallel().tween_property(
			player_card_on_slot,
			"position",
			player_original_position + Vector2(210, 0),
			0.2
		)

		await tween.finished

		tween = create_tween()

		tween.parallel().tween_property(
			opponent_card_on_slot,
			"position",
			opponent_original_position + Vector2(105, 0),
			0.2
		)

		tween.parallel().tween_property(
			player_card_on_slot,
			"position",
			player_original_position - Vector2(105, 0),
			0.2
		)

		await tween.finished

func opponent_win_animation(player_card_on_slot, opponent_card_on_slot):
		var tween = get_tree().create_tween()
		tween.tween_property(
			opponent_card_on_slot, 
			"position", 
			Vector2(center_screen_x, opponent_card_on_slot.position.y), 
			0.09)
		await tween.finished
		
		# Animate player out and destroy card
		var anim = player_card_on_slot.get_node("AnimationPlayer")
		anim.play("card_flip_reverse")
		var tween2 = get_tree().create_tween()
		tween2.tween_property(
			player_card_on_slot, 
			"position", 
			Vector2(center_screen_x * 2 + 210, player_card_on_slot.position.y),
			0.09)
		await anim.animation_finished
		
		# Highlight opponent and destroy card
		battle_manager.battle_timer.start()
		await battle_manager.battle_timer.timeout
		var anim2 = opponent_card_on_slot.get_node("AnimationPlayer")
		anim2.play("card_flip_reverse")
		var tween3 = get_tree().create_tween()
		tween3.tween_property(
			opponent_card_on_slot, 
			"position", 
			Vector2(-210, opponent_card_on_slot.position.y),
			0.2)
		await anim2.animation_finished

func player_win_animation(player_card_on_slot, opponent_card_on_slot):
		var tween = get_tree().create_tween()
		tween.tween_property(
			player_card_on_slot, 
			"position", 
			Vector2(center_screen_x, player_card_on_slot.position.y),
			0.1)
		await tween.finished
		
		# Animate Opponent out and destroy card
		var anim = opponent_card_on_slot.get_node("AnimationPlayer")
		anim.play("card_flip_reverse")
		var tween2 = get_tree().create_tween()
		tween2.tween_property(
			opponent_card_on_slot, 
			"position", 
			Vector2(-210, opponent_card_on_slot.position.y),
			0.2)
		await anim.animation_finished
		
		# Highlight Player and destroy card
		battle_manager.battle_timer.start()
		await battle_manager.battle_timer.timeout
		var anim2 = player_card_on_slot.get_node("AnimationPlayer")
		anim2.play("card_flip_reverse")
		var tween3 = get_tree().create_tween()
		tween3.tween_property(
			player_card_on_slot, 
			"position", 
			Vector2(center_screen_x * 2 + 210, player_card_on_slot.position.y),
			0.2)
		await anim2.animation_finished

func tie_animation(player_card_on_slot, opponent_card_on_slot):
	var anim = opponent_card_on_slot.get_node("AnimationPlayer")
	anim.play("card_flip_reverse")
	var tween = create_tween()
	tween.parallel().tween_property(
		opponent_card_on_slot,
		"position",
		Vector2(-210, opponent_card_on_slot.position.y),
		0.2
		)
	#await anim.animation_finished

	var anim2 = player_card_on_slot.get_node("AnimationPlayer")
	anim2.play("card_flip_reverse")
	tween.parallel().tween_property(
		player_card_on_slot,
		"position",
		Vector2(center_screen_x * 2 + 210, player_card_on_slot.position.y),
		0.2
	)
	await tween.finished
