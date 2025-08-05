import random

# --- Klassen-Definitionen für das Kartenspiel ---

class Karte:
    """
    Repräsentiert eine einzelne Spielkarte mit Farbe und Wert.
    """
    def __init__(self, farbe, wert):
        self.farbe = farbe
        self.wert = wert

    def __repr__(self):
        """Sorgt für eine saubere Textdarstellung der Karte, z.B. 'König von Herz'."""
        return f"{self.wert} von {self.farbe}"

class Deck:
    """
    Repräsentiert ein Deck aus 52 Spielkarten. Bietet Methoden zum Mischen und Austeilen.
    """
    def __init__(self):
        """Initialisiert ein neues, geordnetes Deck mit 52 Karten."""
        self.karten = []
        farben = ["Herz", "Karo", "Kreuz", "Pik"]
        werte = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "Bube", "Dame", "König", "Ass"]

        # Erstellt das Deck, indem alle Farben mit allen Werten kombiniert werden.
        for farbe in farben:
            for wert in werte:
                self.karten.append(Karte(farbe, wert))

    def mischen(self):
        """Mischt die Karten im Deck zufällig."""
        random.shuffle(self.karten)

    def geben(self):
        """Nimmt die oberste Karte vom Deck und gibt sie zurück."""
        if len(self.karten) > 0:
            return self.karten.pop()
        return None

# --- Spiellogik-Funktionen ---

def berechne_karten_wert(hand):
    """
    Berechnet den Blackjack-Wert einer Hand. Asse werden flexibel als 1 oder 11 gezählt.
    """
    wert = 0
    anzahl_asse = 0
    for karte in hand:
        if karte.wert.isdigit():
            wert += int(karte.wert)
        elif karte.wert in ["Bube", "Dame", "König"]:
            wert += 10
        else:  # Ass
            anzahl_asse += 1
            wert += 11

    # Wenn der Wert 21 übersteigt, werden Asse von 11 auf 1 abgewertet.
    while wert > 21 and anzahl_asse:
        wert -= 10
        anzahl_asse -= 1
    return wert

def spiele_eine_runde_blackjack():
    """Führt eine komplette, interaktive Runde Blackjack durch."""

    # 1. Setup: Ein neues, gemischtes Deck erstellen und Hände für Spieler und Dealer anlegen.
    deck = Deck()
    deck.mischen()

    spieler_hand = [deck.geben(), deck.geben()]
    dealer_hand = [deck.geben(), deck.geben()]

    print("\n--- Neues Spiel: Willkommen bei Blackjack! ---")

    # 2. Spielzug des Spielers: Der Spieler zieht Karten, bis er hält oder sich überkauft.
    while True:
        spieler_wert = berechne_karten_wert(spieler_hand)
        print(f"\nDeine Hand: {spieler_hand} (Wert: {spieler_wert})")
        print(f"Dealer's offene Karte: [{dealer_hand[1]}]")

        if spieler_wert >= 21:  # Automatisches Halten bei 21 oder mehr.
            break

        aktion = input("Möchtest du (z)iehen oder (h)alten? ").lower()
        if aktion.startswith('z'):
            neue_karte = deck.geben()
            spieler_hand.append(neue_karte)
            print(f"Du ziehst: {neue_karte}")
        elif aktion.startswith('h'):
            break
        else:
            print("Ungültige Eingabe. Bitte 'z' oder 'h' eingeben.")

    # 3. Ergebnis des Spielerzugs auswerten.
    spieler_wert = berechne_karten_wert(spieler_hand)
    if spieler_wert > 21:
        print(f"Du hast dich mit {spieler_wert} überkauft! Du verlierst.")
    else:
        # 4. Spielzug des Dealers (nur wenn der Spieler sich nicht überkauft hat).
        print("\n--- Dealer ist am Zug ---")
        dealer_wert = berechne_karten_wert(dealer_hand)
        print(f"Dealer deckt auf: {dealer_hand} (Wert: {dealer_wert})")

        # Dealer zieht nach der "Stand on 17"-Regel.
        while dealer_wert < 17:
            neue_karte = deck.geben()
            dealer_hand.append(neue_karte)
            dealer_wert = berechne_karten_wert(dealer_hand)
            print(f"Dealer zieht: {neue_karte} | Neue Hand: {dealer_hand} (Wert: {dealer_wert})")

        # 5. Finalen Gewinner ermitteln.
        print("\n--- Ergebnis ---")
        print(f"Dein Wert: {spieler_wert} | Dealer Wert: {dealer_wert}")

        if dealer_wert > 21:
            print("Dealer hat sich überkauft! Du gewinnst!")
        elif dealer_wert > spieler_wert:
            print("Dealer gewinnt!")
        elif spieler_wert > dealer_wert:
            print("Du gewinnst!")
        else:
            print("Unentschieden (Push)!")

    # 6. Fragen, ob eine weitere Runde gespielt werden soll.
    nochmal_spielen = input("\nNochmal spielen? (j/n): ").lower()
    return nochmal_spielen.startswith('j')

# --- Hauptprogramm ---

if __name__ == "__main__":
    # Das Spiel läuft in einer Schleife, bis der Spieler entscheidet aufzuhören.
    while spiele_eine_runde_blackjack():
        pass  # Die Schleife läuft weiter, solange die Funktion True zurückgibt.

    print("\nDanke fürs Spielen! Auf Wiedersehen.")
