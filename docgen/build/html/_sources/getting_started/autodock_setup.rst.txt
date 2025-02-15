AutoDock-AI setup 🐳
====================
The following steps will guide you through the process of setting up the AutoDock-AI framework using Docker. This will allow you to run your AI projects seamlessly across different machines, ensuring optimal sharing and reproducibility.
Ensure to use AutoDock-AI on Linux machines, as it is not supported on Windows or MacOS.

1. Please follow docker base installation
------------------------------------------
you can visit the official docker documentation and follow the installation procedures: https://docs.docker.com/engine/install/
or install docker with the following commands:

.. code-block:: bash

    wget https://get.docker.com/ -O get_docker.sh
    chmod +x get_docker.sh
    bash get_docker.sh
   

2. Install nvidia-docker2 for GPU support
------------------------------------------
Once Docker has been installed, install nvidia-docker2 for GPU support (otherwise you can follow `this <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html>`_ procedure (Recommended)):

Download and add the GPG key for the official nvidia container toolkit repository:

.. code-block:: bash

    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

update and install the nvidia container toolkit:    

.. code-block:: bash

    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    
Configure the nvidia container toolkit to use the nvidia runtime with docker:

.. code-block:: bash

    configure nvidia container tool

Restart docker to apply the changes:

.. code-block:: bash

    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker

3. Add required permissions to your user account
-------------------------------------------------
Add your user to the docker group to be able to run docker commands:
 
.. code-block:: bash

    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker


4. Import and build docker image
--------------------------------
Please note that here you are downloading ubuntu, cuda and pytorch, and it may take several minutes!
    
Importing AutoDock as submodule (to use it as it is)

.. code-block:: bash

        git submodule add https://github.com/DanielRossi1/AutoDock
        git fetch
        git pull

- Cloning: recommended when you need to work on a private repository. Delete .git directory within AutoDock, in this way you can push your changes without any issue

.. code-block:: bash

    git clone https://github.com/DanielRossi1/AutoDock
        
    
then go to AutoDock directory and build the docker

.. code-block:: bash

    cd AutoDock
    ./build.sh


5. run docker image
---------------------
Once the image is built, you can run it with the following command:

.. code-block:: bash

    ./run.sh
    
- params:
    - ``-d /path/to/dir_to_mount``: optionally you can specify supplementary volumes (directory) which tipically can be used as data directory (where you store your datasets). You will find it under ``/home/user``
    - ``-w``: enables the docker to mount a webcam
    - ``-a``: load audio devices (microphone and speakers). Please make sure to correctly install audio drivers in the container, otherwise it will not work
    - ``-p``: load I/O pheripherals on embedded devices (such as GPIOs, I2C)

6. Stop docker image
----------------------
To stop the docker image, you can use the following command to be launched inside the docker container terminal:

.. code-block:: bash

    exit

or just press ``Ctrl + D``

7. Connect to a remote docker container
----------------------------------------
The script ``remote.sh`` configures the local host and the remote host in order to run the docker remotely while developing through VSCode running on the local machine. 
It creates a local SSH key to be used later to attach docker to the remote container, and adds that key into the remote host ``~/.ssh/authorized_keys``. 
Then it creates a local ``~/.ssh/config`` pointing to that remote host, with the generated key. 
Finally it updates a docker context on the local machine in order to connect and list the containers running on the remote machine.

The difference between using a basic SSH connection on VSCode to connect to the host machine and establishing a remote container connection (still over SSH) is that, in the second case, it enables VSCode to discover running container on the remote machine and attach to them. This means that you can launch debug sessions.
If you want to connect to a remote docker container, you can use the following command:

.. code-block:: bash

    ./remote.sh

This command will ask for the IP address (or DNS) of the remote machine and the password of the user. You halso have to provide your email and your GitHub username. Once you have provided the required information, you will be connected to the remote machine.
You need to use this script only once, as it will create a configuration file that will be used for the following connections.
To switch back to the local machine, you can use the following command:

.. code-block:: bash

    docker context use default

If your context is set to default, and you want to reconnect to the remote machine, you can use the following command:

.. code-block:: bash

    docker context use remote