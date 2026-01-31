#!/bin/bash

# Waybar module for power-daemon-mgr CLI
# Only uses power-daemon-mgr commands

INTERVAL=${1:-5}
STATE_FILE="/tmp/power_daemon_state"

get_available_profiles() {
    power-daemon-mgr list-profiles 2>/dev/null | tr -d '[]",' | tr ' ' '\n' | grep -v '^$' || echo "Balanced"
}

get_current_profile() {
    # Read from state file if it exists and is recent
    if [[ -f "$STATE_FILE" ]]; then
        local file_age=$(($(date +%s) - $(stat -c %Y "$STATE_FILE" 2>/dev/null || echo 0)))
        if [[ $file_age -lt 30 ]]; then  # File is less than 30 seconds old
            cat "$STATE_FILE"
            return
        fi
    fi
    
    # Fallback detection from system state
    local governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
    local epp=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null)
    
    case "$governor" in
        "performance")
            echo "Performance"
            ;;
        "powersave")
            if [[ "$epp" == "balance_power" ]]; then
                echo "Balanced"
            else
                echo "Powersave"
            fi
            ;;
        "ondemand"|"conservative"|"schedutil")
            echo "Balanced"
            ;;
        *)
            echo "Balanced"
            ;;
    esac
}

set_profile() {
    local profile="$1"
    # Use power-daemon-mgr CLI
    if power-daemon-mgr set-profile-override "$profile" >/dev/null 2>&1; then
        # Save to state file for tracking
        echo "$profile" > "$STATE_FILE"
    fi
}

cycle_profile() {
    local profiles=($(get_available_profiles))
    local current=$(get_current_profile)
    local next_index=0
    
    # Find current profile index
    for i in "${!profiles[@]}"; do
        if [[ "${profiles[$i]}" == "$current" ]]; then
            next_index=$(((i + 1) % ${#profiles[@]}))
            break
        fi
    done
    
    set_profile "${profiles[$next_index]}"
}

# Handle click actions
case "$2" in
    "cycle")
        cycle_profile
        sleep 2 # Allow time for changes to take effect
        ;;
esac

# Main output
profile=$(get_current_profile)

# Static energy icon from Adwaita
icon="󱐌"

case "$profile" in
    *"Performance"*"++"*)
        text="Performance++"
        class="performance"
        ;;
    *"Performance"*)
        text="Performance"
        class="performance"
        ;;
    *"Powersave"*"++"*)
        text="Powersave++"
        class="power-saver"
        ;;
    *"Powersave"*)
        text="Powersave"
        class="power-saver"
        ;;
    *"Balanced"*)
        text="Balanced"
        class="balanced"
        ;;
    *)
        text="$profile"
        class="balanced"
        ;;
esac

# Output JSON for Waybar
echo "{\"text\": \"$icon $text\", \"tooltip\": \"Power Profile: $text\\nLeft click: Cycle profiles\", \"class\": \"$class\"}"
