#!/bin/bash
# @Author: lioniac (github.com/lioniac)

##--- Usage:
  # (Optional) Backup Files
  #find ./data/ -depth -print |cpio -pvd BKP
  #find ./src/  -depth -print |cpio -pvd BKP

  # Execute:
  #clear;./decap.sh

  # With Timer:
  #clear;{ date;./decap.sh;date; }|tee -a output.txt

##--- Vars
RESERVED="HM HP HQ ID KO LR OK OT PA PC PP RS TM TV AKA DMA DNA GBA LOL NES RPG ZZZ NULL"
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

##--- Filter to your list of files
FILTER_FILES="charmap.txt|items.json.txt|wild_encounters.json|layouts.json|map.json|map_groups.json|braille.inc|agb_flash_1m.c|battle_bg.c|battle_interface.c|dodrio_berry_picking.c|isagbprn.c|keyboard_text.c|libgcnmultiboot.s|librfu_rfu.c|link_rfu_2.c|main.c|string_util.c|berry_crush.c|credits.c|help_system.c|naming_screen.c|item_menu.c"
FILTER_LINES="[\s\.#]include|[\s]*[\.#]define|INCBIN_|^\/\/|^@|^[\s]\.section|asm\(|\"itemId\":|\"holdEffect\":|\"pocket\":|\"fieldUseFunc\":|Binary file"

##--- Decap Function
decap () {
  RETURN=1

  # Special Cases (Outside of the loop for performance reasons):
  grep -rn "_(\"S\")" {src,data} |grep -v "output.txt" |while IFS=: read -r file line content; do
    sed -i "${line}s|_(\"S\")|_(\"s\")|g" $file
  done 1>/dev/null
  grep -rn "_(\"IES\")" {src,data} |grep -v "output.txt" |while IFS=: read -r file line content; do
    sed -i "${line}s|_(\"IES\")|_(\"ies\")|g" $file
  done 1>/dev/null
  grep -rn "\bMARTS\b" {src,data} |grep -v "output.txt" |while IFS=: read -r file line content; do
    sed -i "${line}s|\bMARTS\b|Marts|g" $file
  done 1>/dev/null
  grep -rn "\bTRAINERS\b" {src,data} |grep -v "output.txt" |while IFS=: read -r file line content; do
    sed -i "${line}s|\bTRAINERS\b|Trainers|g" $file
  done 1>/dev/null
  grep -rn "\bUH-HUH\b" {src,data} |grep -v "output.txt" |while IFS=: read -r file line content; do
    sed -i "${line}s|\bUH-HUH\b|Uh-Huh|g" $file
  done 1>/dev/null
  grep -rn "\"GO-GOGGLES\"" {src,data} |grep -v "output.txt" |while IFS=: read -r file line content; do
    sed -i "${line}s|\"GO-GOGGLES\"|\"Go-Goggles\"|g" $file
  done 1>/dev/null

  # Let's Go:
  grep -rEn "\".*[A-Z]{2,}.*\"" {data,src} |tr -d '\r' \
  |grep -vE "$FILTER_FILES" \
  |grep -vE "$FILTER_LINES" \
  |while read -r wholeline; do
    IFS=: read -r file line str_original <<< "$wholeline"
    grep -E "[\ -~	é\…\‥\♀\♂\¥\“\”\▶\®ÃãÕõàÀÈÌÒÙàèìòùÛûÁÉÍÓÚáéíóúñÑÇç\{\}\._\$]+$" <<< "${str_original}" 1>/dev/null && {
      str_modified="$str_original"

      # Uppercase to "Capital Case" if it's not a {VARIABLE}:
      wordlist=$(echo -n "$str_modified" |grep -Eo "\".*\b[npl]?[A-Z0-9é_\']+\b.*\"" |grep -Eo "[{]?[A-Z0-9é_']{2,}[}]?" |grep -v "{\|}")
      for word in $wordlist; do
        grep -v "$word" <<< "$RESERVED" 1>/dev/null && grep -Ev "TM|HM[0-9]{2}" <<< "$word" 1>/dev/null && {
          newword="${word:0:1}$(tr '[:upper:]' '[:lower:]' <<< ${word:1})"
          str_modified=$(sed -E "s|(.*\".*)([^\"\{]\+)?$word([^\"\}]\+)?(.*\".*)|\1\2$newword\3\4|g" <<< "$str_modified")  
        }
      done

      # OUTPUT:
      [ "$str_modified" != "$str_original" ] && {
        RETURN=0
        str_modified=${str_modified//\\/\\\\}
        str_modified=${str_modified//\&/\\\&}
        str_modified=${str_modified//\?/\\\?}
        str_modified=${str_modified//\!/\\\!}
        str_modified=${str_modified//\./\\\.}
        str_modified=${str_modified//\$/\\\$}
        sed -i "${line}s|.*|${str_modified}|g" $file \
          && sed -Ei "s|[\\\]{2,}|\\\|g" $file \
          && echo "Original: $wholeline" \
          && echo -en "${GREEN}"  && echo "Modified: ${file}:${line}:$(sed -n "${line}p" ${file})" || {
            echo -en "${RED}"    && echo "[ERROR] : $wholeline"
          }
        echo -en "${NC}"
      }
    }
  done

  # Fixing a collateral damage:
  sed -i 's|[\\]\+n|\\\\n|g' src/data/items.json

  # Exit
  return $RETURN
}

while decap; do 
  echo "Running Again..." && decap
done

exit 0
