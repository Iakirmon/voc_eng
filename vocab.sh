#!/bin/bash

# Konfiguracja
NTFY_TOPIC="vocab-reminder"
WORDS_FILE="words.txt"
API_TRANSLATE="https://translate.googleapis.com/translate_a/single"

# Losuj 5 słówek z lokalnego pliku
words=$(shuf -n 5 "$WORDS_FILE")

# Przygotuj wiadomość
message="🧠 Twoje słówka:
"

# Funkcja tłumaczenia słowa
translate_word() {
  local word="$1"
  local retries=0
  local translation=""

  while [ $retries -lt 3 ]; do
    response_translate=$(curl -s --max-time 5 --get --data-urlencode "client=gtx" \
      --data-urlencode "sl=en" \
      --data-urlencode "tl=pl" \
      --data-urlencode "dt=t" \
      --data-urlencode "q=$word" \
      "$API_TRANSLATE")

    if [ -z "$response_translate" ] || [[ "$response_translate" == *"Error"* ]]; then
      ((retries++))
      sleep 1
      continue
    fi

    translation=$(echo "$response_translate" | jq -r '.[0][0][0]')

    if [ "$translation" != "null" ] && [ -n "$translation" ]; then
      break
    fi

    ((retries++))
    sleep 1
  done

  if [ -z "$translation" ] || [ "$translation" == "null" ]; then
    translation="(błąd tłumaczenia)"
  fi

  echo "$translation"
}

# Pętla po słówkach
for word in $words; do
  translated=$(translate_word "$word")
  message+="$word → $translated
"
done

# Wyślij powiadomienie
curl -H "Title: Nowe słówka" -H "Tags: books" -d "$message" "https://ntfy.sh/$NTFY_TOPIC"

exit 0
