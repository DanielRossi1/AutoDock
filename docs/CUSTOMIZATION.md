# Customization-
## Introduction
Here you can find some already-tested solution to install system packages, third-party software, and so on, in your container. You can add the lines you find in this document within the dockerfile. Always remember, the order matters, containers are built layer by layer from the beginning. Some of these solution may require already-installed system packages. For example, if you need to add the container user to the audio group, the user must be already defined in the Dockerfile.

## System packages & drivers

### *Audio*
```
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get clean -y
RUN apt-get install -y -q \
    espeak \
    pulseaudio \
    pulseaudio-utils \
    libasound2 \
    sox \
    libpulse0 \
    alsa-base \
    alsa-utils \
    usbutils \
    mpg123 \
    portaudio19-dev

RUN usermod -aG audio $USER_NAME
RUN mkdir -p /etc/pulse

RUN echo "default-server = unix:/run/user/1000/pulse/native" >> /etc/pulse/client.conf && \
    echo "" >> /etc/pulse/client.conf && \
    echo "autospawn = no" >> /etc/pulse/client.conf && \
    echo "daemon-binary = /bin/true" >> /etc/pulse/client.conf && \
    echo "" >> /etc/pulse/client.conf && \
    echo "enable-shm = false" >> /etc/pulse/client.conf
```

## Softwares

### *ROS (Robot Operating System)*
```
# --- ROS NOETIC (you must use Ubuntu 20.04) ---
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list'

RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
RUN apt-get update 
RUN apt-get install -y -q ros-noetic-desktop-full
RUN apt-get install -y -q \
        python3-rosdep \
        python3-rosinstall \
        python3-rosinstall-generator \
        python3-wstool \
        build-essential \
        python3-yaml \
        python3-catkin-tools \
        ros-noetic-tf \
        ros-noetic-usb-cam \
        ros-noetic-sensor-msgs \
        ros-noetic-geometry-msgs \
        ros-noetic-desktop 

RUN echo '#!/bin/bash\nsource /opt/ros/noetic/setup.bash\nexec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh
```

before `CMD ["/bin/bash"]` you should add the following line:
```
ENTRYPOINT ["/entrypoint.sh"] # Always for ROS
```

### *Anaconda (Python virtual environments manger)*
```
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && /bin/bash ~/miniconda.sh -b -p /opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

COPY ../src/environment.yml ./tmp/environment.yml
RUN conda env create -f tmp/environment.yml
RUN /bin/bash -c "conda init bash"
RUN echo "source /opt/conda/bin/activate your_environment_name" >> /home/${USER_NAME}/.bashrc
```

## Hints
### *Python packages install through .whl url*
```
RUN python -m pip download --only-binary :all: --dest . --no-cache PACKAGE-DOWNLOAD-LINK.whl
```

### *Embedded Systems Pheripherals*
```
usermod -aG gpio $USER
usermod -aG i2c $USER
```