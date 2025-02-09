# Customization
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

### *XBOX 360 Kinect*
Add the following lines after python requirements installation. As for the docker base image, we suggest to use an Ubuntu-18.04-based image with CUDA enabled (i.e. `nvidia/cuda:12.0.0-base-ubuntu18.04`). In order to successfully retrieve depth and RGB streams, add `--privileged` to the docker run options in `run.sh` (`base-options` variable). Once the container has built, run it with `./run -w -a -i`
```
# Kinect and Vrui dependencies
RUN apt-get update && apt-get install -y -q \
    g++ \
    gcc \
    cmake \
    libx11-dev \
    libxext-dev \
    libssl-dev \
    libtiff-dev \
    libfreetype6-dev \
    libxi-dev \ 
    libxrandr-dev \
    libglu-dev \
    libusb-dev \
    libusb-1.0-0-dev \
    zlib1g-dev \
    mesa-common-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev 

RUN apt-get install -y -q \
    libjpeg62-dev \
    libasound2-dev \
    libdc1394-22-dev \
    libspeex-dev \
    libogg-dev \
    libtheora-dev \
    libbluetooth-dev \
    libopenal-dev


# Vrui Installation: this is one of the few versions which compiles without errors
WORKDIR ${USER_HOME}
RUN wget https://web.cs.ucdavis.edu/~okreylos/ResDev/Vrui/Vrui-4.2-006.tar.gz && \
    tar -xvzf Vrui-4.2-006.tar.gz && \
    rm Vrui-4.2-006.tar.gz &&\
    cd Vrui-4.2-006 && \
    make clean && \
    make -j$NUM_CPUS && \
    make install

# Kinect Installation
WORKDIR ${USER_HOME}
RUN wget https://web.cs.ucdavis.edu/~okreylos/ResDev/Kinect/Kinect-3.2.tar.gz && \
    tar -xvzf Kinect-3.2.tar.gz && \
    rm Kinect-3.2.tar.gz && \
    cd Kinect-3.2 && \
    make clean && \
    make -j$NUM_CPUS && \
    make install

# Freenect Installation
WORKDIR ${USER_HOME}
RUN apt-get install -y -q \
    udev \
    libudev-dev \
    usbutils \
    libva-dev \
    libva-drm2 \
    libturbojpeg0-dev \
    libglfw3 \
    libglfw3-dev \
    libcppunit-dev \
    libopenni2-dev
    
RUN git clone https://github.com/OpenKinect/libfreenect2.git
RUN cd libfreenect2 && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=${USER_HOME}/freenect2 -DBUILD_OPENNI2_DRIVER=ON -DENABLE_CXX11=ON && \
    make -j$NUM_CPUS && \
    make install
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