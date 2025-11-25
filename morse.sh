# Morse code definitions for "42"
FOUR="....-"
TWO="..---"

# LED device
LED="/sys/class/leds/tpacpi::lid_logo_dot/brightness"

# Timing (in seconds)
DOT_DURATION=0.2
DASH_DURATION=0.8
SYMBOL_PAUSE=0.2
CHARACTER_PAUSE=0.6

# fns to turn on and off
led_on() {
    echo 255 | sudo tee "$LED" > /dev/null
}

led_off() {
    echo 0 | sudo tee "$LED" > /dev/null
}

# pattern function
blink() {
    local pattern=$1
    for (( i=0; i<${#pattern}; i++ )); do
        local symbol="${pattern:$i:1}"
        if [ "$symbol" == "." ]; then
            led_on
            sleep "$DOT_DURATION"
            led_off
        elif [ "$symbol" == "-" ]; then
            led_on
            sleep "$DASH_DURATION"
            led_off
        fi
        sleep "$SYMBOL_PAUSE"
    done
}

main() {
    # Make sure the LED is off initially
    led_off

    while true; do
        blink "$FOUR"
        sleep "$CHARACTER_PAUSE"
        blink "$TWO"
        sleep 2
    done
}

main
