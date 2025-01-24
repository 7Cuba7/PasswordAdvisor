#!/bin/bash

menu() {
  echo "Pasirinkite veiksmą:"
  echo "1. Analizuoti slaptažodžius iš failo"
  echo "2. Rankiniu būdu įvesti slaptažodžį analizei"
  echo "3. Išeiti"
  read -p "Įveskite pasirinkimo numerį: " choice
}

commonWords() {
  while IFS= read -r word; do
    common_words[word]="1"
  done < common_words.txt
}

textFile() {

  echo "Analizuojami slaptažodžiai iš failo: passwords.txt"
  echo
  awk -v common_words_file="common_words.txt" '
  BEGIN {
    while ((getline word < common_words_file) > 0) {
      common_words[word] = 1
    }
  }

  function strength(pwd) {
    if (length(pwd) < 8) return "Silpnas (trumpas)"
    if (pwd ~ /^[0-9]+$/) return "Silpnas (tik skaičiai)"
    if (pwd ~ /^[a-zA-Z]+$/) return "Silpnas (tik raidės)"
    if (pwd ~ /[A-Za-z]/ && pwd ~ /[0-9]/ && pwd ~ /[!@#$%^&*()_+]/) return "Stiprus"
    return "Vidutinis"
  }

  function suggest_strong(pwd) {
    if (length(pwd) < 8) pwd = pwd "123!"
    if (pwd !~ /[A-Z]/) pwd = pwd "A"
    if (pwd !~ /[a-z]/) pwd = pwd "a"
    if (pwd !~ /[0-9]/) pwd = pwd "1"
    if (pwd !~ /[!@#$%^&*()_+]/) pwd = pwd "!"
    return pwd
  }

  function contains_common_word(pwd) {
    for (word in common_words) {
      if (index(pwd, word) > 0) return "Taip"
    }
    return "Ne"
  }

  {
    s = strength($0)
    print "Slaptažodis:", $0, "- Stiprumas:", s
    if (s != "Stiprus") print "  Pasiūlymas stiprinti:", suggest_strong($0)

    common = contains_common_word($0)
    if (common == "Taip") {
      print "  Įspėjimas: Slaptažodyje yra populiarus ar lengvai atspėjamas žodis!"
    }

    if (length($0) > 20) {
      print "  Pastaba: Slaptažodis gali būti per ilgas ir sunkiai įsimenamas."
    }

    if ($0 ~ /\s/) {
      print "  Pastaba: Slaptažodyje neturėtų būti tarpų."
    }
    print " "
  }
  ' passwords.txt
}

writeText() {
  read -p "Įveskite slaptažodį analizei: " password
  echo "$password" | awk -v common_words_file="common_words.txt" '
  BEGIN {
    while ((getline word < common_words_file) > 0) {
      common_words[word] = 1
    }
  }

  function strength(pwd) {
    if (length(pwd) < 8) return "Silpnas (trumpas)"
    if (pwd ~ /^[0-9]+$/) return "Silpnas (tik skaičiai)"
    if (pwd ~ /^[a-zA-Z]+$/) return "Silpnas (tik raidės)"
    if (pwd ~ /[A-Za-z]/ && pwd ~ /[0-9]/ && pwd ~ /[!@#$%^&*()_+]/) return "Stiprus"
    return "Vidutinis"
  }

  function suggest_strong(pwd) {
    if (length(pwd) < 8) pwd = pwd "123!"
    if (pwd !~ /[A-Z]/) pwd = pwd "A"
    if (pwd !~ /[a-z]/) pwd = pwd "a"
    if (pwd !~ /[0-9]/) pwd = pwd "1"
    if (pwd !~ /[!@#$%^&*()_+]/) pwd = pwd "!"
    return pwd
  }

  function contains_common_word(pwd) {
    for (word in common_words) {
      if (index(pwd, word) > 0) return "Taip"
    }
    return "Ne"
  }

  {
    s = strength($0)
    print "Slaptažodis:", $0, "- Stiprumas:", s
    if (s != "Stiprus") print "  Pasiūlymas stiprinti:", suggest_strong($0)

    common = contains_common_word($0)
    if (common == "Taip") {
      print "  Įspėjimas: Slaptažodyje yra populiarus ar lengvai atspėjamas žodis!"
    }

    if (length($0) > 20) {
      print "  Pastaba: Slaptažodis gali būti per ilgas ir sunkiai įsimenamas."
    }

    if ($0 ~ /\s/) {
      print "  Pastaba: Slaptažodyje neturėtų būti tarpų."
    }
  }
  '
}

commonWords

while true; do
  menu
  case $choice in
    1) textFile ;;
    2) writeText ;;
    3) echo "Išėinama."; exit 0 ;;
    *) echo "Neteisingas pasirinkimas. Bandykite dar kartą." ;;
  esac
  echo ""
done
