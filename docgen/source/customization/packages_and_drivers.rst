System Packages and Drivers
============================
This section will treat the installation of specific system packages and drivers in the AutoDock-AI container. 

.. note::
    All the solutions presented here have been already tested and are known to work. However, it is important to note that the user should always check the official documentation of the software to be installed for the most up-to-date information.


PulseAudio and ALSA for Audio Support
--------------------------------------
To enable audio support in the AutoDock-AI container, PulseAudio and ALSA packages must be installed. The run file already provides directives to mount the host's PulseAudio socket and ALSA configuration files into the container.
To properly enable the container to use audio devices, add the following lines to the bottom of your Dockerfile:

.. code-block:: bash

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

These lines will install the necessary packages and configure the PulseAudio server to run in the container. The usermod command will add the user to the audio group, allowing access to the audio devices.

.. important::
    After adding these lines to the Dockerfile, leave `` CMD ["/bin/bash"] `` as the last line in the file. Rebuild the container with the new configuration, and audio support will be enabled.