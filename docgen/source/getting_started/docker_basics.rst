Docker basics ⌨️
================
Here we want to provide sone information about the basic usage of Docker, in order to help the user to get started with the AutoDock-AI framework.
In particular, we will explore a few commands that are essential to manage containers and images, and that will be useful to the user in the context of this framework.

.. important::
    To apply any changes to the Docker container, you need to rebuild it. If you modify a running container, the changes will be lost when the container is stopped. 
    To customize the container, you need to modify the Dockerfile and rebuild the container!

1. Pulling an image from Docker Hub
-------------------------------------
To pull an image from Docker Hub, you can use the following command:

.. code-block:: bash

    docker pull <image_name>

where ``<image_name>`` is the name of the image you want to pull. For example, to pull the official Ubuntu image, you can use:

.. code-block:: bash

    docker pull ubuntu

2. Running a container
------------------------
To run a container, you can use the following command:

.. code-block:: bash

    docker run <image_name>

where ``<image_name>`` is the name of the image you want to run. For example, to run the official Ubuntu image, you can use:

.. code-block:: bash

    docker run ubuntu

This will start a new container based on the specified image.

3. Listing running containers
-------------------------------
To list the containers that are currently running, you can use the following command:

.. code-block:: bash

    docker ps

This will display a list of the running containers, along with some information about each container.

4. Listing all containers
---------------------------
To list all the containers on your system, including those that are not currently running, you can use the following command:

.. code-block:: bash

    docker ps -a

This will display a list of all the containers on your system, along with some information about each container.

5. Stopping a container
-------------------------
To stop a running container, you can use the following command:

.. code-block:: bash

    docker stop <container_id>

where ``<container_id>`` is the ID of the container you want to stop. You can get the container ID by running ``docker ps``.

6. Removing a container
-------------------------
To remove a container from your system, you can use the following command:

.. code-block:: bash

    docker rm <container_id>

where ``<container_id>`` is the ID of the container you want to remove. You can get the container ID by running ``docker ps -a``.

7. Listing images
------------------
To list the images that are currently on your system, you can use the following command:

.. code-block:: bash

    docker images

This will display a list of the images on your system, along with some information about each image.

8. Removing an image
----------------------
To remove an image from your system, you can use the following command:

.. code-block:: bash

    docker rmi <image_id>

where ``<image_id>`` is the ID of the image you want to remove. You can get the image ID by running ``docker images``.

These are some of the basic commands that you can use to manage containers and images with Docker. For more information, you can refer to the Docker documentation at https://docs.docker.com/.