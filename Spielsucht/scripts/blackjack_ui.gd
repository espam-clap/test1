extends Control

signal game_exited

# UI Node References
@onready var dealer_score_label = $DealerScoreLabel
@onready var dealer_hand_label = $DealerHandLabel
@onready var player_score_label = $PlayerScoreLabel
@onready var player_hand_label = $PlayerHandLabel
@onready var result_label = $ResultLabel
@onready var hit_button = $HBoxContainer/HitButton
@onready var stand_button = $HBoxContainer/StandButton
@onready var new_game_button = $HBoxContainer/NewGameButton
@onready var back_button = $BackButton

# Game State
var deck
var player_hand = []
var dealer_hand = []
var DeckScript = load("res://scripts/deck.gd")


func _ready():
    hit_button.pressed.connect(_on_hit_button_pressed)
    stand_button.pressed.connect(_on_stand_button_pressed)
    new_game_button.pressed.connect(start_new_game)
    back_button.pressed.connect(_on_back_button_pressed)

    deck = DeckScript.new()
    # Call deferred to avoid issues with signals during initial setup
    call_deferred("start_new_game")

func start_new_game():
    deck = DeckScript.new()
    deck.shuffle()
    player_hand = [deck.deal(), deck.deal()]
    dealer_hand = [deck.deal(), deck.deal()]

    update_ui()

    result_label.text = "Your turn! Good luck."
    hit_button.disabled = false
    stand_button.disabled = false
    new_game_button.visible = false
    hit_button.visible = true
    stand_button.visible = true

    var player_score = calculate_score(player_hand)
    if player_score == 21:
        end_turn()

func _on_hit_button_pressed():
    player_hand.append(deck.deal())
    update_ui()

    var player_score = calculate_score(player_hand)
    if player_score >= 21:
        end_turn()

func _on_stand_button_pressed():
    end_turn()

func end_turn():
    hit_button.disabled = true
    stand_button.disabled = true
    hit_button.visible = false
    stand_button.visible = false

    var dealer_score = calculate_score(dealer_hand)
    update_ui(true) # Reveal dealer's hand

    while dealer_score < 17:
        dealer_hand.append(deck.deal())
        dealer_score = calculate_score(dealer_hand)
        update_ui(true)

    var player_score = calculate_score(player_hand)

    if player_score > 21:
        result_label.text = "You busted! Dealer wins."
    elif dealer_score > 21:
        result_label.text = "Dealer busted! You win!"
    elif player_score > dealer_score:
        result_label.text = "You win!"
    elif dealer_score > player_score:
        result_label.text = "Dealer wins."
    else:
        result_label.text = "It's a push (tie)."

    new_game_button.visible = true

func calculate_score(hand):
    var score = 0
    var ace_count = 0
    for card in hand:
        score += deck.get_card_value(card.rank)
        if card.rank == "A":
            ace_count += 1

    while score > 21 and ace_count > 0:
        score -= 10
        ace_count -= 1

    return score

func hand_to_string(hand, hide_first_card = false):
    var hand_str = ""
    if hide_first_card:
        hand_str = "[Hidden]"
        for i in range(1, hand.size()):
            hand_str += ", " + hand[i].rank
    else:
        var card_strings = []
        for card in hand:
            card_strings.append(card.rank)
        hand_str = ", ".join(card_strings)
    return hand_str

func update_ui(reveal_dealer_card = false):
    player_hand_label.text = "Player's Hand: " + hand_to_string(player_hand)
    player_score_label.text = "Player's Score: " + str(calculate_score(player_hand))

    if reveal_dealer_card:
        dealer_hand_label.text = "Dealer's Hand: " + hand_to_string(dealer_hand)
        dealer_score_label.text = "Dealer's Score: " + str(calculate_score(dealer_hand))
    else:
        dealer_hand_label.text = "Dealer's Hand: " + hand_to_string(dealer_hand, true)
        dealer_score_label.text = "Dealer's Score: ?"

func _on_back_button_pressed():
    game_exited.emit()
    # The game should be unpaused by the player controller
