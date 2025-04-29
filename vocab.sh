#!/bin/bash

# Konfiguracja
NTFY_TOPIC="vocab-reminder"
API_TRANSLATE="https://translate.argosopentech.com/translate"
WORDS_FILE="words.txt"

# Losuj 5 słówek z lokalnego pliku
words=$(shuf -n 5 "$WORDS_FILE")

# Przygotuj wiadomość
message="🧠 *Twoje słówka:*\n"

for word in $words; do
    retries=0
    translated=""

    while [ $retries -lt 3 ]; do
        response_translate=$(curl -s --max-time 5 -X POST "$API_TRANSLATE" \
            -H 'Content-Type: application/json' \
            -d "{\"q\":\"$word\", \"source\":\"en\", \"target\":\"pl\", \"format\":\"text\"}")

        if [ -z "$response_translate" ] || [[ "$response_translate" == *"error"* ]]; then
            ((retries++))
            sleep 1
            continue
        fi

        translated=$(echo "$response_translate" | jq -r '.translatedText')

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
