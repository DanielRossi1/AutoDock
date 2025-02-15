Containers from the ground up
==============================

Here we want to provide some information about the basic usage of Docker, in order to help the user to get started with the AutoDock-AI framework.
We will explore how to make a container from scratch, how to run it, and how to manage it.

.. important::
    To apply any changes to the Docker container, you need to rebuild it. If you modify a running container, the changes will be lost when the container is stopped. 
    To customize the container, you need to modify the Dockerfile and rebuild the container!

1. Create a Dockerfile
------------------------
To create a container you first need to create a Dockerfile. This file contains the instructions on how to build the container and what to put inside it.
Here is an example of a simple Dockerfile that creates a container based on the official Ubuntu image and installs the Python package manager pip:

.. code-block:: bash

    FROM ubuntu:24.04
    RUN apt-get update && apt-get upgrade && apt-get install -y -q python3.10 python3-pip
    CMD ["/bin/bash"]

This Dockerfile starts from the official Ubuntu 24.04 image, updates the package list, installs Python 3.10 and pip, and then sets the default command to run when the container starts.
Put these lines in a file named ``Dockerfile``.

2. Build the container
------------------------

To build the container, you need to run the ``docker build`` command. This command takes the path to the directory containing the Dockerfile and builds the container based on the instructions in the Dockerfile.

.. code-block:: bash

    docker build -t foo .

This command builds the container and tags it with the name ``foo``. The ``-t`` option specifies the name of the container, and the ``.`` at the end of the command specifies the path to the directory containing the Dockerfile.

3. Run the container
----------------------
To run the container, you can use the ``docker run`` command. This command starts a new container based on the specified image.

.. code-block:: bash

    docker run foo

This command starts a new container based on the ``foo`` image.
