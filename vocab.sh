#!/bin/bash

# Konfiguracja
NTFY_TOPIC="vocab-reminder"
API_WORDS="https://random-word-api.herokuapp.com/word?number=5"
API_TRANSLATE="https://translate.argosopentech.com/translate"

# Pobierz 5 słówek po angielsku
words=$(curl -s "$API_WORDS" | jq -r '.[]')

# Przygotowanie wiadomości
message="🧠 *Twoje słówka:*\n"

for word in $words; do
    retries=0
    translated=""

    while [ $retries -lt 3 ]; do
        response=$(curl -s --max-time 5 -X POST "$API_TRANSLATE" \
            -H 'Content-Type: application/json' \
            -d "{\"q\":\"$word\", \"source\":\"en\", \"target\":\"pl\", \"format\":\"text\"}")

        if [ -z "$response" ] || [[ "$response" == *"error"* ]]; then
            ((retries++))
            sleep 1
            continue
        fi

        translated=$(echo "$response" | jq -r '.translatedText')

        if [ "$translated" != "null" ] && [ -n "$translated" ]; then
            break
        fi

        ((retries++))
        sleep 1
    done

    if [ -z "$translated" ] || [ "$translated" == "null" ]; then
        translated="(błąd tłumaczenia)"
    fi

    message+="$word → $translated\n"
done

# Wysłanie powiadomienia na telefon przez ntfy
curl -H "Title: Nowe słówka" -H "Tags: books" -d "$message" "https://ntfy.sh/$NTFY_TOPIC"

exit 0
