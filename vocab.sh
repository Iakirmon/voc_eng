#!/bin/bash

# Konfiguracja
NTFY_TOPIC="vocab-reminder"
API_URL="https://random-word-api.herokuapp.com/word?number=5"
TRANSLATE_URL="https://translate.argosopentech.com/translate"

# Pobierz 5 słówek po angielsku
words=$(curl -s "$API_URL" | jq -r '.[]')

# Przygotuj wiadomość
message="🧠 *Twoje słówka:*\n"

for word in $words; do
    # Tłumaczenie słówka
    translated=$(curl -s --max-time 5 -X POST "$TRANSLATE_URL" \
        -H "Content-Type: application/json" \
        -d "{\"q\":\"$word\", \"source\":\"en\", \"target\":\"pl\", \"format\":\"text\"}" \
        | jq -r '.translatedText')

    # Sprawdzenie odpowiedzi
    if [[ -z "$translated" || "$translated" == "null" ]]; then
        translated="(błąd tłumaczenia)"
    fi

    message+="$word → $translated\n"
done

# Wyślij powiadomienie na ntfy
curl -H "Title: Nowe słówka" -H "Tags: books" -d "$message" "https://ntfy.sh/$NTFY_TOPIC"
