#!/bin/bash

WEBHOOK="" #Discord Web Hook goes here

inotifywait -m /etc/accserver-data/instances/IBS/results -e create -e moved_to |
    while read dir action file; do
        echo "The file '$file' appeared in directory '$dir' via '$action'"

        file_content=$(sed $'s/[^[:print:]\t]//g' /etc/accserver-data/instances/IBS/results/${file})

        track_name=$(jq '.trackName' <<< "$file_content")
        session_type=$(jq '.sessionType' <<< "$file_content")

        case "$session_type" in
                FP)
                        s_type="PRACTICE"
                        ;;
                Q)
                        s_type="QUALIFYING"
                        ;;
                R)
                        s_type="RACE"
                        ;;
                *)
                        s_type="UNKNOWN"
                        ;;
        esac

        ./discord.sh \
        --webhook-url=$WEBHOOK \
        --username "ACC Server Bot" \
        --title "New $s_type Result!" \
        --description "RACE RESULTS WILL GO HERE WHEN I GET ROUND TO PROGRAMMING IT..." \
        --color "0xFFFFFF" \
        --timestamp
    done
