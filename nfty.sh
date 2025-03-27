#!/bin/zsh

# Konfiguracja
NTFY_TOPIC="twoj-temat-ntfy"
API_URL="https://random-word-api.herokuapp.com/word?number=10"

# Pobierz 10 słówek
words=$(curl -s "$API_URL" | jq -r '.[]')

# Przetłumacz każde słowo przez LibreTranslate (demo)
message="🧠 *Twoje słówka:*\n"
for word in $words; do
    translated=$(curl -s -X POST https://libretranslate.de/translate \
        -H 'Content-Type: application/json' \
        -d "{\"q\":\"$word\", \"source\":\"en\", \"target\":\"pl\", \"format\":\"text\"}" \
        | jq -r '.translatedText')
    message+="$word → $translated\n"
done

# Wyślij powiadomienie przez ntfy
curl -H "Title: Nowe słówka" -H "Tags: books" -d "$message" https://ntfy.sh/$NTFY_TOPIC