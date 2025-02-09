#!/bin/bash

log_error(){
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> errors.txt
}