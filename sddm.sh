#!/usr/bin/env bash

# Capture the exact directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
THEMES_DIR="$SCRIPT_DIR/themes"
SYSTEM_THEMES_DIR="/usr/share/sddm/themes"
SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF="$SDDM_CONF_DIR/theme.conf"

# Check for Qt5 legacy themes
if [ -d "$SCRIPT_DIR/themes-qt5" ]; then
    # Define colors locally if not yet defined (they are defined below, but we can move this check after them)
    # Moving the check after color definitions for better UI
    :
fi

# Reset terminal colors on exit or crash
trap 'echo -ne "\033[0m"' EXIT

# ─────────────────────────────────────────────────────────────────────────────
#  Theme Palette
# ─────────────────────────────────────────────────────────────────────────────

C_MAIN='\033[38;2;202;169;224m'
C_ACCENT='\033[38;2;145;177;240m'
C_DIM='\033[38;2;129;122;150m'
C_GREEN='\033[38;2;166;209;137m'
C_YELLOW='\033[38;2;229;200;144m'
C_RED='\033[38;2;231;130;132m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

header() {
    clear
    echo -e "${C_MAIN}${C_BOLD}"
    echo " ╭──────────────────────────────────────────╮"
    echo " │           󱓞 SDDM THEME SETUP 󱓞           │"
    echo " ╰──────────────────────────────────────────╯"
    echo -e "${C_RESET}"
}

info() {
    echo -e "${C_MAIN}${C_BOLD} ╭─ 󰓅 $1${C_RESET}"
}

substep() {
    echo -e "${C_MAIN}${C_BOLD} │  ${C_DIM}❯ ${C_RESET}$1"
}

success() {
    echo -e "${C_MAIN}${C_BOLD} ╰─ ${C_GREEN}✔ ${C_RESET}$1\n"
}

error() {
    echo -e "${C_MAIN}${C_BOLD} ╰─ ${C_RED}✘ ${C_RESET}$1\n"
}

# ─────────────────────────────────────────────────────────────────────────────
#  Core Logic
# ─────────────────────────────────────────────────────────────────────────────

header

# Dependency check
info "Checking dependencies..."

if ! command -v sddm &> /dev/null; then
    error "SDDM is not installed. Install it with: pacman -S sddm"
    exit 1
fi
substep "SDDM found"

if ! sudo -n true 2>/dev/null; then
    substep "${C_YELLOW}Note: sudo may prompt for your password during installation${C_RESET}"
fi

success "Dependencies verified"

# Check for Qt5 legacy themes
if [ -d "$SCRIPT_DIR/themes-qt5" ]; then
    echo -e "${C_YELLOW}${C_BOLD} ╭─ 󰓅 LEGACY THEMES DETECTED${C_RESET}"
    echo -ne "${C_MAIN}${C_BOLD} ╰─ ${C_YELLOW}Use Qt5 compatible versions? (y/n): ${C_RESET}"
    read -rp "" USE_QT5
    if [[ "$USE_QT5" =~ ^[Yy]$ ]]; then
        THEMES_DIR="$SCRIPT_DIR/themes-qt5"
        substep "Using legacy directory: themes-qt5/"
    fi
fi

# Check if themes directory exists
if [ ! -d "$THEMES_DIR" ]; then
    error "Themes directory not found at $THEMES_DIR"
    exit 1
fi

# Selection Logic
info "Selecting a theme..."

if ! command -v fzf &> /dev/null; then
    substep "fzf not found. Using basic list..."
    THEMES=($(ls -1 "$THEMES_DIR"))
    for i in "${!THEMES[@]}"; do
        echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}$((i+1)) ${C_DIM}❯ ${C_RESET}${THEMES[$i]}"
    done
    echo -ne "${C_MAIN}${C_BOLD} ╰─ ${C_YELLOW}Choice: ${C_RESET}"
    read -rp "" SELECTION
    if [[ "$SELECTION" =~ ^[0-9]+$ ]] && [ "$SELECTION" -ge 1 ] && [ "$SELECTION" -le "${#THEMES[@]}" ]; then
        SELECTED_THEME="${THEMES[$((SELECTION-1))]}"
    else
        error "Invalid selection. Exiting."
        exit 1
    fi
else
    # List themes and let user select one using fzf
    SELECTED_THEME=$(ls -1 "$THEMES_DIR" | fzf --prompt="Select theme: " --height=15 --reverse --border --header="Use arrow keys/Enter to select")
fi

# Sub-selection for Terraria theme
if [ "$SELECTED_THEME" == "terraria" ]; then
    info "Customizing Terraria sub-theme..."
    substep "Select mode:"
    echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}1 ${C_DIM}❯ ${C_RESET}Time-based (Transitions with day/night)"
    echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}2 ${C_DIM}❯ ${C_RESET}Random (New background per boot)"
    echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}3 ${C_DIM}❯ ${C_RESET}Manual selection"
    echo -ne "${C_MAIN}${C_BOLD} ╰─ ${C_YELLOW}Choice: ${C_RESET}"
    read -rp "" SUB_OPT
    
    case $SUB_OPT in
        1)
            sed -i "s/^background_mode=.*/background_mode=time/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
            substep "Time-based mode activated!"
            ;;
        2)
            sed -i "s/^background_mode=.*/background_mode=random/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
            substep "Random mode activated!"
            ;;
        3)
            info "Available sub-themes:"
            echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}1 ${C_DIM}❯ ${C_RESET}Forest mountains"
            echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}2 ${C_DIM}❯ ${C_RESET}Tall mountains, flying islands"
            echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}3 ${C_DIM}❯ ${C_RESET}Halloween lands with skull"
            echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}4 ${C_DIM}❯ ${C_RESET}Midnight scary"
            echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}5 ${C_DIM}❯ ${C_RESET}Icy cold mountains"
            echo -ne "${C_MAIN}${C_BOLD} ╰─ ${C_YELLOW}Choice: ${C_RESET}"
            read -rp "" SUB_CHOICE
            if [[ "$SUB_CHOICE" =~ ^[1-5]$ ]]; then
                sed -i "s/^background_mode=.*/background_mode=static/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
                sed -i "s/^background_index=.*/background_index=$SUB_CHOICE/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
                substep "Sub-theme $SUB_CHOICE activated!"
            else
                error "Invalid choice. Defaulting to random."
                sed -i "s/^background_mode=.*/background_mode=random/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
            fi
            ;;
        *)
            substep "Defaulting to random mode."
            sed -i "s/^background_mode=.*/background_mode=random/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
            ;;
    esac
fi

# Sub-selection for Genshin theme
if [ "$SELECTED_THEME" == "Genshin" ]; then
    info "Customizing Genshin Impact sub-theme..."
    substep "Select background mode:"
    echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}1 ${C_DIM}❯ ${C_RESET}Time-based (Dawn / Day / Dusk / Night)"
    echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}2 ${C_DIM}❯ ${C_RESET}Random (New background per boot)"
    echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}3 ${C_DIM}❯ ${C_RESET}Manual selection"
    echo -ne "${C_MAIN}${C_BOLD} ╰─ ${C_YELLOW}Choice: ${C_RESET}"
    read -rp "" SUB_OPT

    case $SUB_OPT in
        1)
            sed -i "s/^background_mode=.*/background_mode=time/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
            substep "Time-based mode activated! (dawn → day → dusk → night)"
            ;;
        2)
            sed -i "s/^background_mode=.*/background_mode=random/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
            substep "Random mode activated!"
            ;;
        3)
            info "Available backgrounds:"
            echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}1 ${C_DIM}❯ ${C_RESET}Day (bright sky)"
            echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}2 ${C_DIM}❯ ${C_RESET}Night (dark stars)"
            echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}3 ${C_DIM}❯ ${C_RESET}Dawn (golden sunrise)"
            echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}4 ${C_DIM}❯ ${C_RESET}Dusk (sunset orange)"
            echo -ne "${C_MAIN}${C_BOLD} ╰─ ${C_YELLOW}Choice: ${C_RESET}"
            read -rp "" SUB_CHOICE
            if [[ "$SUB_CHOICE" =~ ^[1-4]$ ]]; then
                sed -i "s/^background_mode=.*/background_mode=static/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
                sed -i "s/^background_index=.*/background_index=$SUB_CHOICE/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
                substep "Background $SUB_CHOICE activated!"
            else
                error "Invalid choice. Defaulting to time-based."
                sed -i "s/^background_mode=.*/background_mode=time/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
            fi
            ;;
        *)
            substep "Defaulting to time-based mode."
            sed -i "s/^background_mode=.*/background_mode=time/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
            ;;
    esac
fi

# Clockwork Theme
if [ "$SELECTED_THEME" == "clockwork" ]; then
    info "Customizing Clockwork sub-theme..."
    
    # Theme Mode
    substep "Select theme mode:"
    echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}1 ${C_DIM}❯ ${C_RESET}Dark Mode (Default)"
    echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}2 ${C_DIM}❯ ${C_RESET}Light Mode"
    echo -ne "${C_MAIN}${C_BOLD} ╰─ ${C_YELLOW}Choice: ${C_RESET}"
    read -rp "" MODE_S
    
    if [ "$MODE_S" == "2" ]; then
        sed -i "s/^themeMode=.*/themeMode=light/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
        substep "Light mode activated!"
    else
        sed -i "s/^themeMode=.*/themeMode=dark/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
        substep "Dark mode activated!"
    fi
    
    # Windup Animation
    substep "Enable windup animation? (y/n):"
    echo -ne "${C_MAIN}${C_BOLD} ╰─ ${C_YELLOW}Choice: ${C_RESET}"
    read -rp "" WIND_S
    if [[ "$WIND_S" =~ ^[Nn]$ ]]; then
        sed -i "s/^enableWindup=.*/enableWindup=false/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
        substep "Windup animation disabled."
    else
        sed -i "s/^enableWindup=.*/enableWindup=true/" "$THEMES_DIR/$SELECTED_THEME/theme.conf"
        substep "Windup animation enabled."
    fi
fi

if [ -z "$SELECTED_THEME" ]; then
    error "No theme selected. Exiting."
    exit 0
fi

substep "Selected: ${C_ACCENT}${SELECTED_THEME}${C_RESET}"

# Check for fonts in the selected theme
FONT_COUNT=$(ls -1 "$THEMES_DIR/$SELECTED_THEME/font" 2>/dev/null | grep -E "\.(ttf|otf)$" | wc -l)
if [ "$FONT_COUNT" -eq 0 ]; then
    echo -e "${C_YELLOW}${C_BOLD} ╭─   MISSING FONT DETECTED${C_RESET}"
    echo -e "${C_YELLOW}${C_BOLD} │${C_RESET}  ${C_DIM}This theme looks better with its specific font!${C_RESET}"
    echo -e "${C_YELLOW}${C_BOLD} │${C_RESET}  ${C_DIM}Please put the .ttf/.otf file in:${C_RESET}"
    echo -e "${C_YELLOW}${C_BOLD} │${C_RESET}  ${C_ACCENT}$THEMES_DIR/$SELECTED_THEME/font/${C_RESET}"
    echo -e "${C_YELLOW}${C_BOLD} ╰─ ${C_DIM}Refer to README.md for font suggestions.${C_RESET}\n"
fi

# Installation Logic
info "Applying configuration changes..."

# Create system themes directory if it doesn't exist
if [ ! -d "$SYSTEM_THEMES_DIR" ]; then
    substep "Creating system directory..."
    sudo mkdir -p "$SYSTEM_THEMES_DIR"
fi

# Copy theme to system directory
substep "Copying theme to /usr/share/sddm/themes/..."
sudo cp -r "$THEMES_DIR/$SELECTED_THEME" "$SYSTEM_THEMES_DIR/"

# Update SDDM configuration
substep "Updating sddm settings..."
if [ ! -d "$SDDM_CONF_DIR" ]; then
    sudo mkdir -p "$SDDM_CONF_DIR"
fi

if [ ! -f "$SDDM_CONF" ]; then
    echo -e "[Theme]\nCurrent=$SELECTED_THEME" | sudo tee "$SDDM_CONF" > /dev/null
else
    # Update existing 'Current=' line or add it under [Theme]
    if grep -q "^Current=" "$SDDM_CONF"; then
        sudo sed -i "s/^Current=.*/Current=$SELECTED_THEME/" "$SDDM_CONF"
    else
        if grep -q "^\[Theme\]" "$SDDM_CONF"; then
            sudo sed -i "/^\[Theme\]/a Current=$SELECTED_THEME" "$SDDM_CONF"
        else
            echo -e "\n[Theme]\nCurrent=$SELECTED_THEME" | sudo tee -a "$SDDM_CONF" > /dev/null
        fi
    fi
fi

success "Theme '$SELECTED_THEME' is now active!"
