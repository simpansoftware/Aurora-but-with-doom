#!/bin/bash

export COLOR_RESET="\033[0m"
export BLACK_B="\033[1;30m"
export RED_B="\033[1;31m"
export GEEN="\033[0;32m"
export GEEN_B="\033[1;32m"
export YELLOW="\033[0;33m"
export YELLOW_B="\033[1;33m"
export BLUE_B="\033[1;34m"
export MAGENTA_B="\033[1;35m"
export PINK_B="\x1b[1;38;2;235;170;238m"
export CYAN_B="\033[1;36m"

echo_c() {
    local text="$1"
    local color_variable="$2"
    local color="${!color_variable}"
    echo -e "${color}${text}${COLOR_RESET}"
}
