Pheripherals and external devices
=================================
In this section, we will cover the installation of specific peripherals and external devices in the AutoDock-AI container.

Microsoft XBox 360 Kinect
-------------------------
Add the following lines after python requirements installation. As for the docker base image, we suggest to use an Ubuntu-18.04-based image with CUDA enabled (i.e. ``nvidia/cuda:12.0.0-base-ubuntu18.04``). 
In order to successfully retrieve depth and RGB streams, add ``--privileged`` to the docker run options in ``run.sh`` (``base-options`` variable). Once the container has built, run it with ``./run -w -a -i``

.. code-block:: bash 

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