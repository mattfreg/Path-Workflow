#!/bin/bash

# Specify the full path to the onyx command
onyx_command="/Applications/Onyx-Latest/Onyx.app/Contents/MacOS/onyx"
rm -rf paths
rm final_output.txt

# Store the original directory
original_dir=$(pwd)

# Specify the parent directory to search for RB2CON files
parent_directory="."

# Loop through each subdirectory (excluding hidden directories)
for dir in "$parent_directory"/*/; do
    # Check if the directory contains a song.yml file
    if [ -f "$dir/song.yml" ]; then
        echo "Processing directory: $dir"

        # Extract title and artist from song.yml
        title=$(awk '/^ *title:/{gsub(/^ *title: /, ""); print}' "$dir/song.yml")
        artist=$(awk '/^ *artist:/{gsub(/^ *artist: /, ""); print}' "$dir/song.yml")

        shortname=$(basename "$dir")

        # Create the output string in the desired format
        title_artist="$title by $artist"

        # Save the formatted output to a text file in the same directory
        echo "$title_artist" > "$dir/songtitle.txt"

        echo "Extracted and saved: $title_artist"
        echo "-------------------------------------"

        # Create song.ini file
        echo "[song]" > "$dir/song.ini"
        echo "name = $title" >> "$dir/song.ini"
        echo "artist = $artist" >> "$dir/song.ini"
        echo "charter = Harmonix, Rhythm Authors" >> "$dir/song.ini"

        # Change directory to process subdirectory files
        cd "$dir" || continue

        # Read entire contents of songtitle.txt into title_artist
        title_artist=$(<songtitle.txt)

        # Create the clean title_artist string
        clean_title_artist=$(echo "$title_artist" | iconv -f utf-8 -t ascii//TRANSLIT | sed -e 's/[^[:alnum:]?[:space:]]//g' -e 's/ /_/g' | tr '[:upper:]' '[:lower:]')

        # Guitar output file name
        guitar_output="${clean_title_artist}_guitar.png"
        # Bass output file name
        bass_output="${clean_title_artist}_bass.png"

        # Drums output file name
        drums_output="${clean_title_artist}_drums.png"
        # Pad Bass output file name
        mbass_output="${clean_title_artist}_mbass.png"

        # Lead output file name
        lead_output="${clean_title_artist}_lead.png"
        # Pad Bass output file name
        vocals_output="${clean_title_artist}_vocals.png"

        #### PRO LEAD #####

        # Assign the Guitar path output of CHOpt command to the variable $guitar_path
        guitar_path=$( ../cli/fnf_chopt -f *_pro.mid --lazy 1000000 --squeeze 40 --early-whammy 0 --no-image --engine rb  | \
        grep -v "Optimising" | \
        sed -e 's/ ([^(]*)//g' | \
        awk '/^Total score:/ {next} !/^Path:|^No SP score:/ {gsub(/: /, "/", $0); gsub(/: /, ",", $0); gsub("/ ", "/", $0); if (NR > 1 && items) printf ", "; printf "%s", $0; items=1} END {if (NR > 0) printf "\n"}' )

        # Set guitar image path variable
        guitar_path_image="'$guitar_output'"

        # Guitar Score
        guitar_score=$( ../cli/CHOpt -f *_pro.mid --early-whammy 0 --squeeze 40 --engine fnf -o "$guitar_output" | \
        awk '/^Total score:/ {print $NF; exit}' )

        #### PRO BASS #####

        # Assign the Bass path output of CHOpt command to the variable $bass_path
        bass_path=$( ../cli/fnf_chopt -f *_pro.mid -i bass --lazy 100000 --squeeze 40 --no-image --early-whammy 0 --engine rb -o "$bass_output" | \
        grep -v "Optimising" | \
        sed -e 's/ ([^(]*)//g' | \
        awk '/^Total score:/ {next} !/^Path:|^No SP score:/ {gsub(/: /, "/", $0); gsub(/: /, ",", $0); gsub("/ ", "/", $0); if (NR > 1 && items) printf ", "; printf "%s", $0; items=1} END {if (NR > 0) printf "\n"}' )

        # Set bass image path variable
        bass_path_image="'$bass_output'"

        # Bass Score
        bass_score=$( ../cli/CHOpt -f *_pro.mid -i bass --early-whammy 0 --squeeze 40 --engine fnf -o "$bass_output" | \
        awk '/^Total score:/ {print $NF; exit}' )

        #### DRUMS #####
        # Assign the drums path output of CHOpt command to the variable $drums_path
        drums_path=$( ../cli/fnf_chopt -f *_drumvox.mid --lazy 1000000 --squeeze 40 --early-whammy 0 --no-image --engine rb  | \
        grep -v "Optimising" | \
        sed -e 's/ ([^(]*)//g' | \
        awk '/^Total score:/ {next} !/^Path:|^No SP score:/ {gsub(/: /, "/", $0); gsub(/: /, ",", $0); gsub("/ ", "/", $0); if (NR > 1 && items) printf ", "; printf "%s", $0; items=1} END {if (NR > 0) printf "\n"}' )

        # Set drums image path variable
        drums_path_image="'$drums_output'"

        # drums Score
        drums_score=$( ../cli/CHOpt -f *_drumvox.mid --early-whammy 0 --squeeze 40 --engine fnf -o "$drums_output" | \
        awk '/^Total score:/ {print $NF; exit}' )

        #### VOCALS ####

        # Assign the vocals path output of CHOpt command to the variable $vocals_path
        vocals_path=$( ../cli/fnf_chopt -f *_drumvox.mid -i bass --lazy 100000 --squeeze 40 --no-image --early-whammy 0 --engine rb -o "$vocals_output" | \
        grep -v "Optimising" | \
        sed -e 's/ ([^(]*)//g' | \
        awk '/^Total score:/ {next} !/^Path:|^No SP score:/ {gsub(/: /, "/", $0); gsub(/: /, ",", $0); gsub("/ ", "/", $0); if (NR > 1 && items) printf ", "; printf "%s", $0; items=1} END {if (NR > 0) printf "\n"}' )

        # Set vocals image path variable
        vocals_path_image="'$vocals_output'"

        # vocals Score
        vocals_score=$( ../cli/CHOpt -f *_drumvox.mid -i bass --early-whammy 0 --squeeze 40 --engine fnf -o "$vocals_output" | \
        awk '/^Total score:/ {print $NF; exit}' )    

        #### LEAD #####

        # Assign the lead path output of CHOpt command to the variable $lead_path
        lead_path=$( ../cli/fnf_chopt -f *.mid --lazy 1000000 --early-whammy 0 --squeeze 40 --no-image --engine rb  | \
        grep -v "Optimising" | \
        sed -e 's/ ([^(]*)//g' | \
        awk '/^Total score:/ {next} !/^Path:|^No SP score:/ {gsub(/: /, "/", $0); gsub(/: /, ",", $0); gsub("/ ", "/", $0); if (NR > 1 && items) printf ", "; printf "%s", $0; items=1} END {if (NR > 0) printf "\n"}' )

        # Set lead image path variable
        lead_path_image="'$lead_output'"

        # lead Score
        lead_score=$( ../cli/CHOpt -f *.mid --early-whammy 0 --squeeze 40 --engine fnf -o "$lead_output" | \
        awk '/^Total score:/ {print $NF; exit}' )

        #### BASS #####

        # Assign the mbass path output of CHOpt command to the variable $mbass_path
        mbass_path=$( ../cli/fnf_chopt -f *.mid -i bass --lazy 100000 --squeeze 40 --no-image --early-whammy 0 --engine rb -o "$mbass_output" | \
        grep -v "Optimising" | \
        sed -e 's/ ([^(]*)//g' | \
        awk '/^Total score:/ {next} !/^Path:|^No SP score:/ {gsub(/: /, "/", $0); gsub(/: /, ",", $0); gsub("/ ", "/", $0); if (NR > 1 && items) printf ", "; printf "%s", $0; items=1} END {if (NR > 0) printf "\n"}' )

        # Set mbass image path variable
        mbass_path_image="'$mbass_output'"

        # mbass Score
        mbass_score=$( ../cli/CHOpt -f *.mid -i bass --early-whammy 0 --squeeze 40 --engine fnf -o "$mbass_output" | \
        awk '/^Total score:/ {print $NF; exit}' )    

        ##############################################

        # Export the template using the $path and $title variables
        template='{ value : "'"$title_artist"'", 
            data : {
            shortname : "'"$shortname"'",

            dpath : "'"$drums_path"'",
            d_image : "'"${drums_path_image}"'",
            dscore :  "'"$drums_score"'",

            gpath : "'"$guitar_path"'",
            gscore : "'"$guitar_score"'",
            g_image : "'"${guitar_path_image}"'",

            bpath : "'"$bass_path"'",
            bscore : "'"$bass_score"'",
            b_image : "'"$bass_path_image"'",

            lpath : "'"$lead_path"'",
            lscore : "'"$lead_score"'",
            l_image : "'"$lead_path_image"'",

            vpath : "'"$vocals_path"'",
            vscore : "'"$vocals_score"'",
            v_image : "'"$vocals_path_image"'",

            mpath : "'"$mbass_path"'",
            mscore : "'"$mbass_score"'",
            m_image : "'"$mbass_path_image"'",
        }}'

        # Add an extra comma at the end of the template
        template="$template,"

        # Append the template to the array
        templates+=("$template")

        # Echo progress
        echo "$title_artist path saved"

        # Save the template to a file in the original directory
        echo "$template" >> "$original_dir"/final_output.txt

        # Return to the original directory
        cd "$original_dir" || exit
    fi
done

# Specify the parent directory to search for PNG files
parent_directory="."

# Specify the directory to move PNG files into
paths_directory="$parent_directory/paths"
mkdir -p "$paths_directory"  # Create 'paths' directory if it doesn't exist

# Move all .png files to the 'paths' directory
echo "Moving .png files to 'paths' directory..."
find "$parent_directory" -type f -name "*.png" -exec mv {} "$paths_directory" \;
echo "All .png files moved to 'paths' directory: $paths_directory"

# Remove directories ending with _import
echo "Removing directories ending with '_import'..."
find "$parent_directory" -type d -name "*_import" -exec rm -rf {} +
echo "Directories ending with '_import' removed."