#!/usr/bin/env bash
set -euo pipefail

cache_dir="$HOME/.cache"
# Get Steam API Key here https://steamcommunity.com/login/home/?goto=%2Fdev%2Fapikey
api_key="xxxxxx"
# Replace with your steam ID
steamid="xxxxxx"
filename="$steamid.json"

depchecks(){
    if ! command -v jq >/dev/null; then
        echo "Please install jq."
        exit 1
    fi
    if ! command -v dmenu >/dev/null; then
        echo "Please install dmenu."
        exit 1
    fi
}

localfile(){
    if [ ! -f $HOME/.cache/$filename ]; then
        curl "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=$api_key&steamid=$steamid&include_appinfo=1&include_played_free_games=1&format=json" -o $cache_dir/$filename
    else
        if test `find "$cache_dir/$filename" -mtime +7`; then
                    curl "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=$api_key&steamid=$steamid&include_appinfo=1&include_played_free_games=1&format=json" -o $cache_dir/$filename
        fi
    fi
    mapfile -t names < <( jq -r '.response.games | sort_by(.name) | .[].name' $cache_dir/$filename )
    mapfile -t appid < <( jq -r '.response.games | sort_by(.name) | .[].appid' $cache_dir/$filename )
    i=0
    len=${#names[@]}
    combined="$(
        while [ $i -lt $len ]; do
        echo "${names[$i]} - ${appid[$i]}"
        let i++
        done
    )" 
}

main() {
    choice=$(printf '%s\n' "$combined" | dmenu -i -l 20 -p "Games: ")
    # choice=$(printf '%s\n' "$combined" | wofi -i -d -S dmenu -p "Games: ")
    # choice=$(printf '%s\n' "$combined" | rofi -i -d -S dmenu -p "Games: ")
    choiceid=$(echo $choice | awk '{print $NF}')
    steam -applaunch $choiceid >/dev/null 2>&1 &
}

depchecks
localfile
main

exit 0
