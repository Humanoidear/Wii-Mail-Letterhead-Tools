#!/bin/bash

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

clear
echo -e "${CYAN}========================================================"
echo -e "${BOLD}       Wii Message Board Letterhead Decompressor${RESET}"
echo -e "${CYAN}          by Alex, based on larsenv's work"
echo -e "${CYAN}========================================================${RESET}"

echo -e "\n${RED}${BOLD}Make sure the input arc is inside the 'input' folder and named 'input.arc', otherwise this process will not work!${RESET}\n"
# Remove previous decompressed files if they exist
rm -rf input/input.d
# Extract the input ARC file
wszst x input/input.arc

# Decompress the LZ files
./tools/lzss -d input/input.d/thumbnail_LZ.bin input/input.d/thumbnail_LZ.bin
./tools/lzss -d input/input.d/letter_LZ.bin input/input.d/letter_LZ.bin

# Rename the decompressed files
mv input/input.d/thumbnail_LZ.bin input/input.d/thumbnail.u8
wszst x input/input.d/thumbnail.u8

mv input/input.d/letter_LZ.bin input/input.d/letter.u8
wszst x input/input.d/letter.u8

rm input/input.d/thumbnail.u8
rm input/input.d/letter.u8

./tools/wimgt decode input/input.d/letter.d/img/*.tpl -x TPL.CMPR
./tools/wimgt decode input/input.d/thumbnail.d/img/*.tpl -x TPL.CMPR

rm -rf output
mkdir -p output/letter
mkdir -p output/thumbnail
mv input/input.d/letter.d/img/*.tpl.png output/letter/
mv input/input.d/thumbnail.d/img/*.tpl.png output/thumbnail/

if [ -f "./input/input.d/sound.bns" ]; then
       ./tools/sharpii BNS -from input/input.d/sound.bns output/sound.wav 
fi

rm -rf input/input.d

echo -e "\n${GREEN}Decompression complete!${RESET}\n"