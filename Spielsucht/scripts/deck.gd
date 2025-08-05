class_name Deck

var cards = []
var suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]

func _init():
    for suit in suits:
        for rank in ranks:
            cards.append({"rank": rank, "suit": suit})

func shuffle():
    cards.shuffle()

func deal():
    if cards.size() > 0:
        return cards.pop_front()
    else:
        # For simplicity, we'll just rebuild and reshuffle if the deck is empty.
        print("Deck empty. Reshuffling.")
        _init()
        shuffle()
        return cards.pop_front()

func get_card_value(card_rank):
    if card_rank in ["J", "Q", "K"]:
        return 10
    elif card_rank == "A":
        return 11 # The main game logic will handle the 1 or 11 choice.
    else:
        return int(card_rank)
