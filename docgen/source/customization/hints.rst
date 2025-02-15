Hints and Tips
==============

Python packages install through .whl url
----------------------------------------
If you have a python package that is not available in the PyPi repository, you can install it through the .whl file. A .whl file is a built distribution of a Python package that can be installed using the pip install command. To install a package from a .whl file, you can use the following command:

.. code-block:: bash

    RUN python -m pip download --only-binary :all: --dest . --no-cache PACKAGE-DOWNLOAD-LINK.whl

Embedded Systems Pheripherals
-----------------------------
When working with embedded systems, it is common to use peripherals such as sensors, actuators, and communication modules. To enable the use of these peripherals in the AutoDock-AI container, you need to install the necessary drivers and libraries. The run file already provides directives to mount the host's devices into the container.
Nevertheless, you need to grant permission to the container user to access these devices. Add the following lines after user account creation of your Dockerfile:

.. code-block:: bash

    RUN usermod -aG gpio $USER
    RUN usermod -aG i2c $USER