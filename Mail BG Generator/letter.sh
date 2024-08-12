# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

clear
echo "${CYAN}========================================================"
echo "${BOLD}       Wii Message Board Letterhead Generator${RESET}"
echo "${CYAN}          by Alex, based on larsenv's work"
echo "${CYAN}========================================================${RESET}"

if [ ! -f "./input/letter.png" ]
then
    echo "${RED}${BOLD}Error:${RESET}${BOLD}Please make a letterhead that is 512x376 and save it in this directory as letter.png.${RESET}"
    exit
fi

if [ -d "letterhead.d" ]
then
    rm -rf letterhead.d
fi

mkdir -p letterhead.d/letter.d/img/

curl -o letterhead.d/wszst-setup.txt https://transfer.notkiska.pw/Z8Cbx/wszst-setup.txt
cp letterhead.d/wszst-setup.txt letterhead.d/letter.d/wszst-setup.txt

# Crop the letterhead into 9 parts
echo "\n${YELLOW}Cropping letterhead...${RESET}\n"
magick input/letter.png -resize 512x376\! input/letter.png
magick input/letter.png -crop 64x144+0+0 letterhead.d/letter.d/img/my_Letter_a.tpl.png
magick input/letter.png -crop 384x144+64+0 letterhead.d/letter.d/img/my_Letter_b.tpl.png
magick input/letter.png -crop 64x144+448+0 letterhead.d/letter.d/img/my_Letter_c.tpl.png
magick input/letter.png -crop 64x168+0+144 letterhead.d/letter.d/img/my_Letter_d.tpl.png
magick input/letter.png -crop 384x168+64+144 letterhead.d/letter.d/img/my_Letter_e.tpl.png
magick input/letter.png -crop 64x168+448+144 letterhead.d/letter.d/img/my_Letter_f.tpl.png
magick input/letter.png -crop 64x64+0+312 letterhead.d/letter.d/img/my_Letter_g.tpl.png
magick input/letter.png -crop 384x64+64+312 letterhead.d/letter.d/img/my_Letter_h.tpl.png
magick input/letter.png -crop 64x64+448+312 letterhead.d/letter.d/img/my_Letter_i.tpl.png

echo "\n${YELLOW}Encoding letterhead...${RESET}\n"

# Encode the cropped images and remove the originals
./tools/wimgt encode letterhead.d/letter.d/img/*.tpl.png -x TPL.CMPR

# Create the letter_LZ.bin
./tools/wszst create letterhead.d/letter.d/
mv letterhead.d/letter.u8 letterhead.d/letter_LZ.bin

# Compress the letter_LZ.bin in LZSS
./tools/lzss -evn letterhead.d/letter_LZ.bin letterhead.d/letter_LZ.bin 

echo "\n${YELLOW}Encoding thumbnail...${RESET}\n"

if [ ! -f "./input/thumbnail.png" ]
then
    echo "${RED}${BOLD}Error:${RESET}${BOLD}Please make a thumbnail that is 144x96 and save it in the 'input' folder as 'thumbnail.png'.${RESET}"
    exit
fi

mkdir -p letterhead.d/thumbnail.d/img/
cp letterhead.d/wszst-setup.txt letterhead.d/thumbnail.d/wszst-setup.txt

# Resize the thumbnail and encode it
magick input/thumbnail.png -resize 144x96\! letterhead.d/thumbnail.d/img/my_LetterS_b.tpl.png
./tools/wimgt encode letterhead.d/thumbnail.d/img/my_LetterS_b.tpl.png -x TPL.CMPR

# Create the thumbnail_LZ.bin
./tools/wszst create letterhead.d/thumbnail.d/
mv letterhead.d/thumbnail.u8 letterhead.d/thumbnail_LZ.bin

# Compress the tumbnail_LZ.bin in LZSS
./tools/lzss -evn letterhead.d/thumbnail_LZ.bin letterhead.d/thumbnail_LZ.bin

echo "\n${YELLOW}Packing up the files into .arc...${RESET}\n"

# Remove the letter.d and thumbnail.d directories, we no longer need them as we have the .bin files
rm -rf letterhead.d/letter.d/
rm -rf letterhead.d/thumbnail.d/

# Create the letterhead.arc
./tools/wszst create letterhead.d
mv letterhead.u8 letterhead.arc

# Remove the letterhead.d directory, we no longer need it as we have the .arc file
rm -rf letterhead.d

if [ ! -f "letterhead.arc" ]
then
    echo "${RED}${BOLD}Error:${RESET}${BOLD}The letterhead.arc file was not created check if you have permission to write to this directory.${RESET}"
    exit
    fi

rm -rf output/*

echo "\n${YELLOW}Converting letterhead.arc to base64...${RESET}\n"
# Convert the letterhead.arc to base64
base64 -b 76 -i letterhead.arc -o output/letterhead.txt

if [ -f "./input/sound.wav" ]; then
    echo "\n${CYAN}${BOLD}sound.vaw file found!\n${RESET}${CYAN}Do you want to add a sound to the letterhead?${RESET} (y/n)"
    read sound
    if [ "$sound" = "y" ]; then
        echo "\n${CYAN}Do you want to loop the sound?${RESET} (y/n)"
        read loop
        echo "\n${YELLOW}Encoding sound...${RESET}\n"
        if [ "$loop" = "y" ]; then
            ./tools/sharpii BNS -to input/sound.wav sound.bns -m -l
        else
            ./tools/sharpii BNS -to input/sound.wav sound.bns -m
        fi
        wszst x letterhead.arc
        mv sound.bns letterhead.d/sound.bns
        ./tools/wszst create letterhead.d
        mv letterhead.u8 letterhead.arc
        base64 -b 76 -i letterhead.arc -o output/letterhead.txt
        rm -rf letterhead.d
    fi
fi

echo "\n${GREEN}${BOLD}The letterhead has been successfully created!${RESET}\n"

echo "${CYAN}Do you want to keep the letterhead.arc file?${RESET} (y/n)"
read keep
if [ "$keep" = "n" ]; then
    rm -rf letterhead.arc
    echo "\nThe letterhead has been removed.\n\n\n${GREEN}${BOLD}The operation has completed successfully.${RESET}"
    exit
fi

mv letterhead.arc output/letterhead.arc
echo "\nThe letterhead.arc file has been moved to the 'output' folder.\n\n\n${GREEN}${BOLD}The operation has completed successfully.${RESET}"