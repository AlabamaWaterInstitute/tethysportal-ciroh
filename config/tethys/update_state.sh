#!/bin/bash

TETHYS_PERSIST_HOME="$1"
#create list of Intalled apps
# apps_strings=$(tethys list)
# echo $apps_strings
# apps_strings_pre=$(sed -i '/Apps:/,$p' "$apps_strings")
# echo $apps_strings_pre
# apps_strings=$(echo $(tethys list) | sed -n '/Apps:/,$p' | sed -n -e 's/\(Apps:\)//g' | sed -r 's/Extension.*//g')


apps_strings=$(echo $(tethys list) | grep 'Apps:')
# echo $apps_strings
apps_arr=($apps_strings)


# Print the dictionary string
echo "$dict_string"

for app_installed in ${apps_arr[@]:1}; do 

    echo $app_installed;
    
    # Execute the command and store the output in a variable
    output=$(tethys app_settings list "$app_installed")
    # echo "$output"
    # Extract unlinked settings
    unlinked_settings=$(echo "$output" | awk '/Unlinked Settings:/{flag=1; next} /Linked Settings:/{flag=0} flag')
    # echo $unlinked_settings
    # Extract linked settings
    linked_settings=$(echo "$output" | awk '/Linked With/{flag=1; next} flag')
    # echo $linked_settings
    # echo "-------"
    # Parse unlinked settings
    IFS=$'\n'
    unlinked_array=()
    for line in $(echo "$unlinked_settings" | awk 'NR>1{print $0}'); do
        id=$(echo "$line" | awk '{print $1}')
        name=$(echo "$line" | awk '{print $2}')
        type=$(echo "$line" | awk '{print $3}')
        unlinked_array+=("{\"ID\": \"$id\", \"Name\": \"$name\", \"Type\": \"$type\"}")
    done

    # Parse linked settings
    IFS=$'\n'
    linked_array=()

    for line in $(echo "$linked_settings" | awk 'NF>1{print $0}'); do
        echo $line

        id=$(echo "$line" | awk '{print $1}')
        name=$(echo "$line" | awk '{print $2}')
        type=$(echo "$line" | awk '{print $3}')
        linked_with=$(echo "$line" | awk '{$1=$2=$3=""; print substr($0,4)}')
        linked_array+=("{\"ID\": \"$id\", \"Name\": \"$name\", \"Type\": \"$type\", \"Linked With\": \"$linked_with\"}")
    done

    # # Output the arrays
    # echo "Unlinked Settings:"
    # for item in "${unlinked_array[@]}"; do
    #     echo "$item" | sed "s/'/\"/g"
        
    # done


    for ((i=0; i<${#linked_array[@]}; i++)); do
        linked_array[$i]=$(echo "${linked_array[$i]}" | sed 's/"{\(.*\)}"/{\1}/')
        linked_array[$i]="${linked_array[$i]//\'/\"}" 
        # echo ${linked_array[$i]}
        # echo ${linked_array[$i]} | sed 's/"{\(.*\)}"/{\1}/'
        # linked_array[$i]="${linked_array[$i]//\"/\\\"}"
    done

    for ((i=0; i<${#unlinked_array[@]}; i++)); do
        ulinked_array[$i]="${ulinked_array[$i]//\'/\"}"
        # ulinked_array[$i]="${ulinked_array[$i]//\"/\\\"}"
    done
    # echo "${linked_array[@]}"

    # if (( ${#linked_array[@]} )); then
    #     update_settings="$(python3 "$TETHYS_PERSIST_HOME/update_settings.py" --app_name "$app_installed" --linked_settings "${linked_array[@]:1}")"
    # fi

    if (( ${#linked_array[@]} )) && (( ${#unlinked_array[@]} )); then
        update_settings="$(python3 "$TETHYS_PERSIST_HOME/update_settings.py" --app_name "$app_installed" --linked_settings "${linked_array[@]}" --unlinked_settings "${unlinked_array[@]}")"
    elif (( ${#linked_array[@]} ))
    then
        update_settings="$(python3 "$TETHYS_PERSIST_HOME/update_settings.py" --app_name "$app_installed" --linked_settings "${linked_array[@]}")"
    elif (( ${#unlinked_array[@]} ))
    then
        update_settings="$(python3 "$TETHYS_PERSIST_HOME/update_settings.py" --app_name "$app_installed" --unlinked_settings "${unlinked_array[@]}")"
    fi


    # update_settings="$(python3 "$TETHYS_PERSIST_HOME/update_settings.py" --app_name "$app_installed" --linked_settings "${linked_array[@]}" --unlinked_settings "${unlinked_array[@]}")"
    echo "$update_settings"

    # echo "Linked Settings:"
    # for item in "${linked_array[@]}"; do
    #     # echo $item
    #     #replace all single quotes to double quotes
    #     setting_val=$(echo "$item" | sed "s/'/\"/g")
    #     #escape double quotes
    #     setting_val=${setting_val//\"/\\\"}
    #     update_linked_settings="$(python3 "$TETHYS_PERSIST_HOME/update_settings.py" "\"$setting_val\"")"

    # done
    
done



