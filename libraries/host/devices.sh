#!/bin/bash

detect_hostdevice_type(){
    local device="UNKNOWN"

    if [ -e /proc/device-tree/model ]; then
        if grep -qi "Raspberry Pi" /proc/device-tree/model; then
            device="RASPBERRY_PI"
        elif grep -qi "Jetson Nano" /proc/device-tree/model; then
            device="JETSON_NANO"
        elif grep -qi "Jetson Orin" /proc/device-tree/model; then
            device="JETSON_ORIN_NANO"
        else
            device="DESKTOP_COMPUTER"
        fi
    else
        device="DESKTOP_COMPUTER"
    fi

    echo "$device"
}

load_hostdevice_properties(){
    local device="$1"
    local -a args=()

    append_hostdevice_properties args "$device"
    printf '%s ' "${args[@]}"
}

append_hostdevice_properties(){
    local -n _out="$1"
    local device="$2"
    local enable_gpu="${3:-1}"

    case "$device" in
        "RASPBERRY_PI")
            ;;
        "JETSON_NANO")
            _out+=("--privileged")
            _out+=("--runtime=nvidia")
            _out+=("--gpus" "all")
            _out+=("-v" "/proc/device-tree/compatible:/proc/device-tree/compatible")
            _out+=("-v" "/proc/device-tree/chosen:/proc/device-tree/chosen")
            ;;
        "JETSON_ORIN_NANO")
            _out+=("--runtime=nvidia")
            _out+=("--gpus" "all")
            _out+=("--device=/dev/nvidia-modeset")
            _out+=("-v" "/proc/device-tree/compatible:/proc/device-tree/compatible")
            _out+=("-v" "/proc/device-tree/chosen:/proc/device-tree/chosen")
            _out+=("--device=/dev/dri:/dev/dri")
            ;;
        "DESKTOP_COMPUTER")
            if [ "$enable_gpu" -eq 1 ] && command -v nvidia-smi >/dev/null 2>&1; then
                _out+=("--gpus" "all")
                _out+=("--runtime=nvidia")
                if [ -e /dev/nvidia-modeset ]; then
                    _out+=("--device=/dev/nvidia-modeset")
                fi
            fi
            if [ -e /dev/dri ]; then
                _out+=("--device=/dev/dri:/dev/dri")
            fi
            ;;
        *)
            echo "Unknown device"
            ;;
    esac
}

load_videocameras() {
    local video_devices=$(ls /dev/video* 2>/dev/null)

    if [ -n "$video_devices" ]; then
        echo "$video_devices"
    else
        echo "No video device found" >&2
        return 1
    fi
}

load_audio_devices() {
    local -a args=()
    append_audio_devices args
    printf '%s ' "${args[@]}"
}

append_audio_devices() {
    local -n _out="$1"

    if [ -e /dev/snd ]; then
        _out+=("-v" "/dev/snd:/dev/snd")
    fi

    if [ -e /dev/bus/usb ]; then
        _out+=("-v" "/dev/bus/usb:/dev/bus/usb")
    fi

    if [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -S "${XDG_RUNTIME_DIR}/pulse/native" ]; then
        _out+=("-e" "PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native")
        _out+=("-v" "${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native")
    fi
}

load_hid() {
    local -a args=()
    append_hid_devices args
    printf '%s ' "${args[@]}"
}

append_hid_devices() {
    local -n _out="$1"

    shopt -s nullglob
    local hid_devices=(/dev/hidraw*)
    shopt -u nullglob

    if [ "${#hid_devices[@]}" -eq 0 ]; then
        return 0
    fi

    local dev
    for dev in "${hid_devices[@]}"; do
        _out+=("--device" "$dev:$dev")
    done
}

load_peripherals(){
    local -a args=()
    append_peripherals args
    printf '%s ' "${args[@]}"
}

append_peripherals(){
    local -n _out="$1"
    _out+=("--group-add" "gpio")
    _out+=("--group-add" "i2c")

    for i in {0..2}; do
        if [ -e /dev/i2c-$i ]; then
            _out+=("--device" "/dev/i2c-$i:/dev/i2c-$i")
        fi
    done

    if [ -e /dev/gpiochip0 ]; then
        _out+=("--device" "/dev/gpiochip0")
    fi
    if [ -e /dev/gpiochip1 ]; then
        _out+=("--device" "/dev/gpiochip1")
    fi
    if [ -e /dev/spidev0.0 ]; then
       _out+=("--device" "/dev/spidev0.0")
    fi
    if [ -e /dev/spidev0.1 ]; then
       _out+=("--device" "/dev/spidev0.1")
    fi
    if [ -e /dev/spidev1.0 ]; then
       _out+=("--device" "/dev/spidev1.0")
    fi
    if [ -e /dev/spidev1.1 ]; then
       _out+=("--device" "/dev/spidev1.1")
    fi
}

append_video_devices() {
    local -n _out="$1"

    shopt -s nullglob
    local video_devices=(/dev/video*)
    shopt -u nullglob

    if [ "${#video_devices[@]}" -eq 0 ]; then
        return 1
    fi

    local dev
    for dev in "${video_devices[@]}"; do
        _out+=("--device" "$dev:$dev")
    done

    if [ -e /dev/bus/usb ]; then
        _out+=("-v" "/dev/bus/usb:/dev/bus/usb")
    fi
}
