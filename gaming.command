#!/bin/zsh

# Define colors for better readability
RED='%F{1}'
GREEN='%F{2}'
YELLOW='%F{3}'
BLUE='%F{4}'
NC='%f' # Reset color

# Requesting sudo privileges at the start
print -P "${BLUE}Requesting sudo privileges...${NC}"
sudo -v
if [ $? -ne 0 ]; then
    print -P "${RED}Error: Failed to obtain sudo privileges.${NC}"
    exit 1
fi

# Keep sudo alive while the script runs
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Function to revert all tweaks
revert_changes() {
    print -P "${YELLOW}Reverting all performance tweaks...${NC}"

    # Reset system parameters to macOS defaults
    sudo sysctl -w vm.compressor_mode=4
    sudo sysctl -w kern.maxvnodes=131072
    sudo sysctl -w debug.lowpri_throttle_enabled=1
    sudo sysctl -w kern.sched_preempt_thresh=0

    # Restore power-saving features
    sudo pmset -a autopoweroff 1
    sudo pmset -a powernap 1
    sudo pmset -a standby 1
    sudo pmset -a proximitywake 1

    # Restore UI animations and transparency
    defaults write com.apple.universalaccess reduceMotion -bool false
    defaults write com.apple.universalaccess reduceTransparency -bool false
    killall Dock
    killall SystemUIServer

    print -P "${GREEN}All settings reverted to default. A restart is recommended.${NC}"
    exit 0
}

# Function to apply performance tweaks
apply_tweaks() {
    print -P "${GREEN}Applying performance tweaks...${NC}"

    # Apply general performance optimizations
    sudo sysctl -w vm.compressor_mode=1
    sudo sysctl -w kern.maxvnodes=524288
    sudo sysctl -w debug.lowpri_throttle_enabled=0
    sudo sysctl -w kern.sched_preempt_thresh=1

    # Disable power-saving features
    sudo pmset -a autopoweroff 0
    sudo pmset -a powernap 0
    sudo pmset -a standby 0
    sudo pmset -a proximitywake 0

    # Reduce UI overhead
    defaults write com.apple.universalaccess reduceMotion -bool true
    defaults write com.apple.universalaccess reduceTransparency -bool true
    killall Dock
    killall SystemUIServer

    print -P "${GREEN}Performance tweaks applied successfully!${NC}"
}

# Prompt the user for selecting an option
while true; do
    print -P "${BLUE}Select an option:${NC}"
    print -P "${YELLOW}[1] Revert all performance tweaks to default${NC}"
    print -P "[2] Apply performance tweaks"
    print -P "[3] Exit"
    read "user_option?$(print -P ${BLUE}Enter your choice:${NC} )"

    case $user_option in
        1) 
            revert_changes
            ;;
        2)
            apply_tweaks
            ;;
        3)
            print -P "${BLUE}Exiting script.${NC}"
            exit 0
            ;;
        *)
            print -P "${RED}Invalid option. Please select 1, 2, or 3.${NC}"
            ;;
    esac
done
