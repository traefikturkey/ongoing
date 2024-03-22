#!/bin/bash

# Check if /var/run/docker.sock exists
if [ -S "/var/run/docker.sock" ]; then
    echo "Docker socket detected. changing ownership to  ${USER}:${USER}..."
    sudo chown ${USER}:${USER} /var/run/docker.sock
fi