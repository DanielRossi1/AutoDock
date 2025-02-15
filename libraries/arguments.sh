#!/bin/bash

source libraries/logging.sh
source libraries/devices.sh

load_arguments(){
    options=""

    while getopts "d:aipw" opt; do
        case ${opt} in
            a)
                options+=$(load_audio_devices)
                ;;
            d)
                shift
                directory=$(import_directory "$1")
                if [ $? -eq 0 ]; then
                    folder_name=$(basename "$directory")
                    options+="-v $directory:/home/user/"$folder_name" "
                else
                    log_error "load_arguments: could not import path $directory"
                    exit 1
                fi
                ;;
            i)
                options+=$(load_hid)
                ;;
            
            p) 
                options+=$(load_peripherals)
                ;;
            w)
                video_devices=$(load_videocameras) 
                if [ $? -eq 0 ]; then
                    for device in $video_devices; do
                        options+="--device $device:$device "
                    done
                    options+="-v /dev/bus/usb:/dev/bus/usb " 
                fi
                ;;
            \?)
                log_error "load_arguments: unrecognized argument $1"
                exit 1
                ;;
        esac
        shift
    done

    echo "$options"
}