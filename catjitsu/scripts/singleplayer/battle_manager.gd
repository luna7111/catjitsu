extends Node

var battle_timer
var opponent_card_slot
var player_card_slot
var opponent_card_on_slot
var player_card_on_slot

var	player_points = {
		"Fire" = 0,
		"Ice" = 0,
		"Water" = 0,
		"None" = 0
	}
var	opponent_points = {
		"Fire" = 0,
		"Ice" = 0,
		"Water" = 0,
		"None" = 0
	}

enum BATTLE_RESULT {
	PLAYER,
	OPPONENT,
	DRAW,
}

var center_screen_x

func _ready() -> void:
	battle_timer = $"../BattleTimer"
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	opponent_card_slot = $"../../Opponent/OpponentCardSlot"
	player_card_slot = $"../../Player/PlayerCardSlot"
	center_screen_x = get_viewport().size.x / 2

func _on_end_turn_button_pressed() -> void:
	opponent_turn()

func opponent_turn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false

	battle_timer.start()
	await battle_timer.timeout

	await try_play_card_highest_attack()
	await battle_phase()
	end_opponent_turn()

func try_play_card_highest_attack():
	var opponent_hand = $"../../Opponent/OpponentHand".opponent_hand

	if opponent_hand.size() == 0:
		end_opponent_turn()
		return

	var card_with_highest_attack = opponent_hand[0]
	
	# Enemy AI
	for card in opponent_hand:
		if card.points > card_with_highest_attack.points:
			card_with_highest_attack = card

	var tween = get_tree().create_tween()
	tween.tween_property(
		card_with_highest_attack,
		"position",
		Vector2(opponent_card_slot.position.x, opponent_card_slot.position.y),
		0.2
	)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(
		card_with_highest_attack,
		"scale",
		Vector2(1, 1),
		0.2
	)
	card_with_highest_attack.get_node("AnimationPlayer").play("card_flip")

	$"../../Opponent/OpponentHand".remove_card_from_hand(card_with_highest_attack)

	opponent_card_on_slot = card_with_highest_attack

	battle_timer.start()
	await battle_timer.timeout

func battle_phase():
	await animate_cards_battle_phase()
	var battle_result
	battle_result = calculate_battle_result()
	
	print(battle_result)
	match battle_result[0]:
		BATTLE_RESULT.OPPONENT:
			opponent_points[battle_result[1]] += 1
			show_point(battle_result[1], opponent_points[battle_result[1]], "Opponent")
			await opponent_win_animation()
		BATTLE_RESULT.PLAYER:
			player_points[battle_result[1]] += 1
			show_point(battle_result[1], player_points[battle_result[1]], "Player")
			await player_win_animation()
		BATTLE_RESULT.DRAW:
			print ("Draw")
			await draw_animation()

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

func calculate_battle_result():
	var result = [BATTLE_RESULT.DRAW, "None"]
	if opponent_card_on_slot.type == player_card_on_slot.type:
		if opponent_card_on_slot.points == player_card_on_slot.points:
			result = [BATTLE_RESULT.DRAW, "None"]
		else:
			result[0] = opponent_card_on_slot.points > player_card_on_slot.points
			result[1] = opponent_card_on_slot.type
	elif (opponent_card_on_slot.type == "Fire" && player_card_on_slot.type == "Ice" 
		or opponent_card_on_slot.type == "Ice" && player_card_on_slot.type == "Water"
		or opponent_card_on_slot.type == "Water" && player_card_on_slot.type == "Fire") :
			result = [BATTLE_RESULT.OPPONENT, opponent_card_on_slot.type]
	else:
		result = [BATTLE_RESULT.PLAYER, player_card_on_slot.type]
	return result

func opponent_win_animation():
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
		destroy_card(player_card_on_slot)
		
		# Highlight opponent and destroy card
		battle_timer.start()
		await battle_timer.timeout
		var anim2 = opponent_card_on_slot.get_node("AnimationPlayer")
		anim2.play("card_flip_reverse")
		var tween3 = get_tree().create_tween()
		tween3.tween_property(
			opponent_card_on_slot, 
			"position", 
			Vector2(-210, opponent_card_on_slot.position.y),
			0.2)
		await anim2.animation_finished
		destroy_card(opponent_card_on_slot)

func player_win_animation():
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
		destroy_card(opponent_card_on_slot)
		
		# Highlight Player and destroy card
		battle_timer.start()
		await battle_timer.timeout
		var anim2 = player_card_on_slot.get_node("AnimationPlayer")
		anim2.play("card_flip_reverse")
		var tween3 = get_tree().create_tween()
		tween3.tween_property(
			player_card_on_slot, 
			"position", 
			Vector2(center_screen_x * 2 + 210, player_card_on_slot.position.y),
			0.2)
		await anim2.animation_finished
		destroy_card(player_card_on_slot)

func draw_animation():
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
	#await anim2.animation_finished
	await tween.finished
	destroy_card(opponent_card_on_slot)
	destroy_card(player_card_on_slot)

func animate_cards_battle_phase():
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

func destroy_card(selected_card):
	selected_card.queue_free()

func end_opponent_turn():
	var player_elements = 0
	var opponent_elements = 0
	for key in player_points:
		if player_points[key]:
			player_elements += 1
		if opponent_points[key]:
			opponent_elements +=1
		if (player_points[key] == 3 or player_elements == 3
		or opponent_points[key] == 3 or opponent_elements == 3) :
			print("Game Over!")
			get_tree().quit()
		elif $"../../Player/PlayerHand".player_hand.size() == 0:
			print("!")
			get_tree().quit()

	#$"../EndTurnButton".disabled = false
	#$"../EndTurnButton".visible = true
	$"../../Player/PlayerDeck".reset_draw()
	$"../../CardManager".reset_played_monster()
	opponent_card_on_slot = null
	player_card_on_slot = null
	opponent_card_slot.card_in_slot = false
	player_card_slot.card_in_slot = false
	if $"../../Opponent/OpponentDeck".opponent_deck.size() != 0:
		$"../../Opponent/OpponentDeck".draw_card()
	$"../../Player/PlayerDeck".draw_card()
