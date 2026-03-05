#!/usr/bin/env python3

import os
import sys
import subprocess
import shutil
import time

# ─────────────────────────────────────────────────────────────────────────────
#  Color Palette
# ─────────────────────────────────────────────────────────────────────────────

C_MAIN    = '\033[38;2;202;169;224m'
C_ACCENT  = '\033[38;2;145;177;240m'
C_DIM     = '\033[38;2;129;122;150m'
C_GREEN   = '\033[38;2;166;209;137m'
C_YELLOW  = '\033[38;2;229;200;144m'
C_RED     = '\033[38;2;231;130;132m'
C_BOLD    = '\033[1m'
C_RESET   = '\033[0m'

# ─────────────────────────────────────────────────────────────────────────────
#  TUI Utilities
# ─────────────────────────────────────────────────────────────────────────────

def clear_screen():
    os.system('clear')

def header():
    clear_screen()
    print(f"{C_MAIN}{C_BOLD}")
    print(" ╭──────────────────────────────────────────╮")
    print(" │         󱓞 SDDM THEME INSTALLER 󱓞          │")
    print(" ╰──────────────────────────────────────────╯")
    print(f"{C_RESET}")

def info(msg):
    print(f"{C_MAIN}{C_BOLD} ╭─ 󰓅 {msg}{C_RESET}")

def substep(msg):
    print(f"{C_MAIN}{C_BOLD} │  {C_DIM}❯ {C_RESET}{msg}")

def success(msg):
    print(f"{C_MAIN}{C_BOLD} ╰─ {C_GREEN}✔ {C_RESET}{msg}\n")
    time.sleep(0.5)

def warn(msg):
    print(f"{C_MAIN}{C_BOLD} ╰─ {C_YELLOW}⚠ {C_RESET}{msg}\n")

def error(msg):
    print(f"{C_MAIN}{C_BOLD} ╰─ {C_RED}✘ {C_RESET}{msg}\n")

def dim_on():
    sys.stdout.write(C_DIM)
    sys.stdout.flush()

def dim_off():
    sys.stdout.write(C_RESET)
    sys.stdout.flush()

def run_command(command, sudo=False):
    dim_on()
    if sudo:
        command = f"sudo {command}"
    try:
        subprocess.run(command, shell=True, check=True)
        dim_off()
        return True
    except subprocess.CalledProcessError:
        dim_off()
        return False

# ─────────────────────────────────────────────────────────────────────────────
#  Core Logic
# ─────────────────────────────────────────────────────────────────────────────

def check_sddm_status():
    info("Checking SDDM installation...")
    
    # Check if sddm binary is in path
    if shutil.which("sddm"):
        substep("SDDM is already installed.")
        
        # Check if it's the active display manager
        active_dm = ""
        try:
            active_dm = os.readlink("/etc/systemd/system/display-manager.service")
        except OSError:
            pass
            
        if "sddm.service" in active_dm:
            success("SDDM is already set as the default display manager.")
            return True
        else:
            substep("SDDM is installed but not set as the default display manager.")
            return False
    else:
        substep("SDDM is not installed.")
        return False

def get_aur_helper():
    info("Checking for AUR helper...")
    if shutil.which("yay"):
        success("Yay detected.")
        return "yay"
    elif shutil.which("paru"):
        success("Paru detected.")
        return "paru"
    else:
        warn("No AUR helper found.")
        return None

def install_yay():
    info("Installing Yay from source...")
    substep("Cloning repository...")
    src_dir = os.path.expanduser("~/.srcs/yay")
    if os.path.exists(src_dir):
        shutil.rmtree(src_dir)
    os.makedirs(os.path.expanduser("~/.srcs"), exist_ok=True)
    
    if run_command(f"git clone https://aur.archlinux.org/yay.git {src_dir}"):
        substep("Building package...")
        os.chdir(src_dir)
        if run_command("makepkg -si --noconfirm"):
            os.chdir(os.path.expanduser("~"))
            success("Yay installed successfully.")
            return "yay"
    
    error("Failed to install Yay.")
    return None

def main():
    if os.geteuid() == 0:
        print(f"{C_RED}{C_BOLD} ╭─ 🛑 CRITICAL ERROR{C_RESET}")
        print(f"{C_RED}{C_BOLD} ╰─ Do NOT run this script as root. Use a standard user with sudo privileges.{C_RESET}")
        sys.exit(1)

    header()
    warn("This installer requires sudo privileges.")

    # 1. Check/Install SDDM and display manager status
    sddm_ready = check_sddm_status()

    # 2. Setup AUR Helper
    aur_helper = get_aur_helper()
    if not aur_helper:
        info("Installing base build tools...")
        run_command("pacman -S --needed --noconfirm git base-devel", sudo=True)
        aur_helper = install_yay()
        if not aur_helper:
            error("Cannot proceed without an AUR helper.")
            sys.exit(1)

    # 3. Define dependencies
    dependencies = [
        "sddm",
        "qt5-graphicaleffects",
        "qt5-multimedia",
        "qt5-quickcontrols",
        "qt5-quickcontrols2",
        "qt5-svg",
        "gst-libav",
        "gst-plugins-good",
        "gst-plugins-bad",
        "gst-plugins-ugly",
        "fzf",
        "ttf-jetbrains-mono-nerd"
    ]

    info("Installing theme dependencies...")
    dep_str = " ".join(dependencies)
    if run_command(f"{aur_helper} -S --needed --noconfirm {dep_str}"):
        success("All dependencies installed.")
    else:
        error("Some dependencies failed to install.")

    # 4. Enable SDDM if not default
    if not sddm_ready:
        info("Enabling SDDM as default display manager...")
        if run_command("systemctl enable sddm", sudo=True):
            success("SDDM is now the default display manager.")
        else:
            warn("Failed to enable SDDM service automatically.")

    # 5. Finish
    header()
    print(f"{C_GREEN}{C_BOLD} ╭─ 󰗤 INSTALLATION COMPLETE!{C_RESET}")
    print(f"{C_GREEN}{C_BOLD} ╰─ Dependencies have been successfully installed.{C_RESET}\n")

    print(f"{C_MAIN}{C_BOLD} ╭─ 󰑓 NEXT STEPS{C_RESET}")
    print(f"{C_MAIN}{C_BOLD} │  {C_DIM}Run the setup.py to select and apply your themes.{C_RESET}")
    print(f"{C_MAIN}{C_BOLD} ╰─ {C_DIM}Command: {C_ACCENT}./setup.py{C_RESET}\n")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n")
        error("Installation cancelled by user.")
        sys.exit(1)
