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
    local device=$1
    options=""
    case $device in
        "RASPBERRY_PI")
            ;;
        "JETSON_NANO")
            options+="--privileged "
            options+="--runtime=nvidia "
            options+="--gpus all "
            #options+="--device=/dev/nvidia-modeset "
            options+="-v /proc/device-tree/compatible:/proc/device-tree/compatible "
            options+="-v /proc/device-tree/chosen:/proc/device-tree/chosen "            
            ;;
        "JETSON_ORIN_NANO")
            options+="--runtime=nvidia "
            options+="--gpus all "
            options+="--device=/dev/nvidia-modeset "
            options+="-v /proc/device-tree/compatible:/proc/device-tree/compatible "
            options+="-v /proc/device-tree/chosen:/proc/device-tree/chosen "
            options+="--device=/dev/dri:/dev/dri "
            ;;
        "DESKTOP_COMPUTER")
            if command nvcc -V > /dev/null 2>&1 && command nvidia-smi > /dev/null 2>&1; then
                options+="--gpus all "                                              # eat all gpus
                options+="--runtime=nvidia "
                options+="--device=/dev/nvidia-modeset "                            # nvidia modeset map to support graphic card acceleration
            fi
            options+="--device=/dev/dri:/dev/dri "                                  # map host DRI (Direct Rendering Infrastructure) to container
            ;;
        *)
            echo "Unknown device"
            ;;
    esac

    echo "$options"
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
    options=""
    options+="-v /dev/snd:/dev/snd "
    options+="-v /dev/bus/usb:/dev/bus/usb "
    options+="-e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native "
    options+="-v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native "
    echo "$options"
}

load_peripherals(){
    options=""
    options+="--group-add gpio "
    options+="--group-add i2c "

    for i in {0..2}; do
        if [ -e /dev/i2c-$i ]; then
            options+="--device=/dev/i2c-$i:/dev/i2c-$i "
        fi
    done

    if [ -e /dev/gpiochip0 ]; then
        options+="--device=/dev/gpiochip0 "
    fi
    if [ -e /dev/gpiochip1 ]; then
        options+="--device=/dev/gpiochip1 "
    fi
    if [ -e /dev/spidev0.0 ]; then
       options+="--device=/dev/spidev0.0 "
    fi
    if [ -e /dev/spidev0.1 ]; then
       options+="--device=/dev/spidev0.1 "
    fi
    if [ -e /dev/spidev1.0 ]; then
       options+="--device=/dev/spidev1.0 "
    fi
    if [ -e /dev/spidev1.1 ]; then
       options+="--device=/dev/spidev1.1 "
    fi
    echo "$options"
}