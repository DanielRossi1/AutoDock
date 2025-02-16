Robot Operating System (ROS)
============================
This section will treat the installation of the Robot Operating System (ROS) in the AutoDock-AI container. 

.. note::
    All the solutions presented here have been already tested and are known to work. However, it is important to note that the user should always check the official documentation of the software to be installed for the most up-to-date information.

Classic ROS 
-----------

By adding the following lines to the bottom of your Dockerfile, you can install ROS Noetic in the AutoDock-AI container. Installing different versions of ROS require small changes to the commands below.

.. code-block:: bash

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

    RUN rosdep init
    RUN rosdep update

    RUN echo '#!/bin/bash\nsource /opt/ros/noetic/setup.bash\nexec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh

To properly enable ``catkin build`` of ``catkin_make`` in the container, add the following line before the ``CMD`` line in your Dockerfile:

.. code-block:: bash

    ENTRYPOINT ["/entrypoint.sh"] # Always for ROS

These lines will install ROS Noetic and the necessary packages to run it in the AutoDock-AI container. The ``rosdep init`` and ``rosdep update`` commands will initialize and update the ROS dependency manager. The ``entrypoint.sh`` script will source the ROS setup file before executing any commands in the container.

ROS 2
-----
ROS 2 is the next generation of ROS, and it is designed to be more modular and scalable than ROS 1. To install ROS 2 in the AutoDock-AI container, add the following lines to the bottom of your Dockerfile:

.. note::
    ROS 2 Jazzy requires Ubuntu 24.04. You can start from ``FROM ubuntu:24.04`` in your Dockerfile.

.. code-block:: bash

    # --- ROS 2 Jazzy ---
    RUN locale  # check for UTF-8

    RUN apt update && apt install -y -q locales
    RUN locale-gen en_US en_US.UTF-8
    RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    ENV LANG en_US.UTF-8

    RUN apt install -y -q software-properties-common
    RUN add-apt-repository universe
    RUN apt update && sudo apt install curl -y -q 
    RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | \
        tee /etc/apt/sources.list.d/ros2.list > /dev/null

    RUN apt update && apt upgrade -y -q && \
        apt install -y -q \
        ros-dev-tools \
        ros-jazzy-desktop
        
    RUN echo '#!/bin/bash\nsource /opt/ros/jazzy/setup.bash\nexec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh

To properly enable ``colcon build`` in the container, add the following line before the ``CMD`` line in your Dockerfile:

.. code-block:: bash

    ENTRYPOINT ["/entrypoint.sh"] # Always for ROS

.. important::
    Newer Debian/Ubuntu versions require python packages to be installed only within virtual environments. To bypass this check, add ``--break-system-packages`` when installing python packages.