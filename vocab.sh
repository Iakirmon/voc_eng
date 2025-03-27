#!/bin/zsh

# Konfiguracja
NTFY_TOPIC="vocab-reminder"
API_URL="https://random-word-api.herokuapp.com/word?number=10"
TRANSLATE_URL="https://libretranslate.de/translate"

# Pobierz 10 słówek
words=$(curl -s "$API_URL" | jq -r 'if . then .[] else empty end')

# Sprawdzenie, czy API zwróciło poprawne dane
if [[ -z "$words" ]]; then
    echo "Błąd: API nie zwróciło słów!" >&2
    exit 1
fi

# Debugowanie pobranych słów
echo "Pobrane słowa: $words"

# Przetłumacz każde słowo przez LibreTranslate
message="🧠 *Twoje słówka:*\n"
for word in $words; do
    response=$(curl -s -X POST $TRANSLATE_URL \
        -H 'Content-Type: application/json' \
        -d "{\"q\":\"$word\", \"source\":\"en\", \"target\":\"pl\", \"format\":\"text\"}")

    translated=$(echo "$response" | jq -r '.translatedText // "Błąd tłumaczenia"')

    # Debugowanie tłumaczenia
    echo "$word → $translated"

    message+="$word → $translated\n"
done

# Wysyłka powiadomienia przez ntfy
response=$(curl -s -H "Title: Nowe słówka" -H "Tags: books" -d "$message" https://ntfy.sh/$NTFY_TOPIC)

# Debugowanie wysyłki
if [[ $? -ne 0 ]]; then
    echo "Błąd wysyłania powiadomienia!" >&2
    exit 1
fi

echo "Powiadomienie wysłane: $response"
