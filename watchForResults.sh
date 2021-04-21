#!/bin/bash

results_dir="/etc/accserver-data/instances/IBS/results/"
WEBHOOK=""

car_lookup(){
  read foo
  case "$foo" in
    0)
    echo "Porsche 911 991 GT3 R"
    ;;
    1)
    echo "MercedesAMG GT3"
    ;;
    2)
    echo "Ferrari 488 GT3"
    ;;
    3)
    echo "Audi R8 LMS"
    ;;
    4)
    echo "Lamborghini Huracán GT3"
    ;;
    5)
    echo "McLaren 650S GT3"
    ;;
    6)
    echo "Nissan GTR Nismo GT3 2018"
    ;;
    7)
    echo "BMW M6 GT3"
    ;;
    8)
    echo "Bentley Continental GT3 2018"
    ;;
    9)
    echo "Porsche 9112 GT3 Cup"
    ;;
    10)
    echo "Nissan GTR Nismo GT3 2017"
    ;;
    11)
    echo "Bentley Continental GT3 2016"
    ;;
    12)
    echo "Aston Martin Racing V12 Vantage GT3"
    ;;
    13)
    echo "Lamborghini Gallardo REX"
    ;;
    14)
    echo "Jaguar G3"
    ;;
    15)
    echo "Lexus RC F GT3"
    ;;
    16)
    echo "Lamborghini Huracan Evo 2019"
    ;;
    17)
    echo "HondaAcura NSX GT3"
    ;;
    18)
    echo "Lamborghini Huracán Super Trofeo 2015"
    ;;
    19)
    echo "Audi R8 LMS Evo 2019"
    ;;
    20)
    echo "AMR V8 Vantage 2019"
    ;;
    21)
    echo "Honda NSX Evo 2019"
    ;;
    22)
    echo "McLaren 720S GT3 Special"
    ;;
    23)
    echo "Porsche 911 II GT3 R 2019"
    ;;
    24)
    echo "Ferrari 488 GT3 Evo 2020"
    ;;
    25)
    echo "MercedesAMG GT3 2020"
    ;;
    50)
    echo "Alpine A110 GT4"
    ;;
    51)
    echo "Aston Martin Vantage GT4"
    ;;
    52)
    echo "Audi R8 LMS GT4"
    ;;
    53)
    echo "BMW M4 GT4"
    ;;
    55)
    echo "Chevrolet Camaro GT4"
    ;;
    56)
    echo "Ginetta G55 GT4"
    ;;
    57)
    echo "KTM XBow GT4"
    ;;
    58)
    echo "Maserati MC GT4"
    ;;
    59)
    echo "McLaren 570S GT4"
    ;;
    60)
    echo "Mercedes AMG GT4"
    ;;
    61)
    echo "Porsche 718 Cayman GT4"
    ;;
    *)
    echo "Unknown"
    ;;
  esac
}

function convert_time() {
  read foo
  seconds=$(echo "$foo / 1000" | bc -l)
  printf '%i:%02i:%06.3f\n' $(dc -e "${seconds} d 3600 / n [ ] n d 60 / 60 % n [ ] n 60 % f") | awk -F\: '{print $2":"$3}'
}

inotifywait -m ${results_dir} -e create -e moved_to |
while read dir action file; do
  echo "The file '$file' appeared in directory '$dir' via '$action'"
  
  file_content=$(sed $'s/[^[:print:]\t]//g' ${dir}${file})
  
  track_name=$(jq -r '.trackName' <<< "$file_content")
  session_type=$(jq -r '.sessionType' <<< "$file_content")
  fastest_lap=$(jq -r '.sessionResult.bestlap' <<< "$file_content")
  
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
  
  title=$(echo "$s_type - $track_name")
  
  i=1
  output="Leaderboard"
  while read line; do
    name=$(echo $line | awk '{print $1" "$2}')
    car=$(echo $line | awk '{print $3}' | car_lookup)
    ms=$(echo $line | awk '{print $4}')
    time=$(echo $line | awk '{print $4}' | convert_time)
    laps=$(echo $line | awk '{print $5}')
    #Filter out stupidly long lap times from leaderboard
    if [ "$ms" -le "300000" ]; then
      if [ "$ms" -eq "$fastest_lap" ]; then
        output="${output}\n $i - $name - $car - $time (FASTEST LAP) - $laps laps"
      else
        output="${output}\n $i - $name - $car - $time - $laps laps"
      fi
      let i++
    fi
  done<<<$(jq -c '.sessionResult.leaderBoardLines[]|[.currentDriver.firstName,.currentDriver.lastName,.car.carModel,.timing.bestLap,.timing.lapCount]' <<< "$file_content" | column -t -s'[],"')
  
  ./discord.sh \
  --webhook-url=$WEBHOOK \
  --username "ACC Server Bot" \
  --title "$title" \
  --description "$output" \
  --color "0xFFFFFF" \
  --timestamp
done
