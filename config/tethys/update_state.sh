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

INIT_UPDATE=$(cat <<END
import yaml
with open("$TETHYS_PERSIST_HOME/portal_config.yaml") as portal_configuration:
    with open("$TETHYS_PERSIST_HOME/portal_changes.yaml") as portal_changes:
        ymlportal_changes = yaml.safe_load(portal_changes)
        ymlportal = yaml.safe_load(portal_configuration)
        if not ymlportal['apps']:
            ymlportal['apps'] = ymlportal_changes['apps']

with open("$TETHYS_PERSIST_HOME/portal_config.yaml", "w") as portal_configuration:
    yaml.dump(ymlportal, portal_configuration)
END
)
update_with_changes="$(python3 -c "$INIT_UPDATE")"




for app_installed in ${apps_arr[@]:1}; do 

    echo $app_installed;
    
    # Execute the command and store the output in a variable
    output=$(tethys app_settings list "$app_installed")
    # echo "$output"
    # Extract unlinked settings
    unlinked_settings=$(echo "$output" | awk '/Unlinked Settings:/{flag=1; next} /Linked Settings:/{flag=0} flag')
    echo $unlinked_settings
    # Extract linked settings
    linked_settings=$(echo "$output" | awk '/Linked Settings:/{flag=1; next} flag')
    echo $linked_settings
    echo "-------"
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
        id=$(echo "$line" | awk '{print $1}')
        name=$(echo "$line" | awk '{print $2}')
        type=$(echo "$line" | awk '{print $3}')
        linked_with=$(echo "$line" | awk '{$1=$2=$3=""; print substr($0,4)}')
        linked_array+=("{\"ID\": \"$id\", \"Name\": \"$name\", \"Type\": \"$type\", \"Linked With\": \"$linked_with\"}")
    done

    # Print the arrays
    echo "Unlinked Settings:"
    for item in "${unlinked_array[@]}"; do
        echo "$item"
    done

    echo "Linked Settings:"
    for item in "${linked_array[@]}"; do
        echo "$item"
    done
    
done

#Loop over the list of apps
    #Update the apps portion in the portal_config
    #Check for new settings/services in the portal_state.yaml
    #Run the tethys install for each appp to update the unliked services

# if at least one contains a database run syncstores all
# collect all ? probably not since the post_app ssl collects it anyway


