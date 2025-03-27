#!/bin/zsh

# Konfiguracja
NTFY_TOPIC="vocab-reminder"
API_URL="https://random-word-api.herokuapp.com/word?number=10"

# Pobierz 10 słówek po angielsku
words=$(curl -s "$API_URL" | jq -r '.[]')

# Przygotowanie wiadomości
message="🧠 *Twoje słówka:*\n"

for word in $words; do
    translated=$(curl -s -X POST https://libretranslate.de/translate \
        -H 'Content-Type: application/json' \
        -d "{\"q\":\"$word\", \"source\":\"en\", \"target\":\"pl\", \"format\":\"text\"}" \
        | jq -r '.translatedText')
    
    # Sprawdzenie, czy tłumaczenie się udało
    if [[ -z "$translated" || "$translated" == "null" ]]; then
        translated="(błąd tłumaczenia)"
    fi
    
    message+="$word → $translated\n"
done

# Wysłanie powiadomienia na telefon przez ntfy
curl -H "Title: Nowe słówka" -H "Tags: books" -d "$message" https://ntfy.sh/$NTFY_TOPIC
