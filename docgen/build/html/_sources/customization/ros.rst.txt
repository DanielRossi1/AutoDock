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

.. note::
    This section is still under development. Please check back later for updates.