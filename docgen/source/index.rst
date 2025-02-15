.. AutoDock-AI documentation master file, created by
   sphinx-quickstart on Sat Feb 15 12:12:23 2025.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

.. toctree::
   :maxdepth: 1
   :glob:
   :hidden:
   :caption: Getting started

   getting_started/autodock_setup.rst
   getting_started/docker_basics.rst
   getting_started/container_example.rst
   getting_started/connect_vscode.rst


.. toctree::
   :maxdepth: 1
   :glob:
   :hidden:
   :caption: Customization

   customization/hints.rst
   customization/packages_and_drivers.rst
   customization/softwares.rst
   customization/ros.rst
   customization/peripherals.rst


.. toctree::
   :maxdepth: 1
   :glob:
   :hidden:
   :caption: References

   related/autodock_works.rst
   related/license.rst


AutoDock-AI documentation
=========================
.. image:: _static/AutoDockAI-logo.jpeg
   :alt: Designer

Introduction 📖
================

This Docker-based framework is designed to facilitate research by enabling projects to run seamlessly across different machines while ensuring optimal sharing and reproducibility.

Its primary objective is to minimize the setup and execution times of AI projects by providing a streamlined and standardized environment. By leveraging containerization, the framework eliminates compatibility issues, reduces dependency conflicts, and ensures a reproducible execution across different machines. This not only accelerates the deployment process but also enhances collaboration by allowing researchers to share their work more efficiently. Ultimately, it enables faster experimentation, facilitating innovation and reducing the overhead associated with configuring and managing computational environments.

Advantages of Using Docker 💥
=============================

Docker offers several advantages over traditional environment management methods, including virtual machines, Anaconda environments, and basic "requirements.txt" files. By providing a lightweight, portable, and reproducible solution, AutoDock-AI enhances efficiency in AI research and development. The key benefits include:

- **Lightweight and Efficient** – Uses fewer system resources compared to virtual machines by sharing the host OS kernel.  
- **Fast Deployment** – Enables quick setup and execution, reducing time spent on environment configuration.  
- **Full Reproducibility** – Ensures consistency across different machines by encapsulating the entire software environment.  
- **Comprehensive Dependency Management** – Handles system-level dependencies, including CUDA and GPU drivers, unlike Anaconda.  
- **Cross-Platform Compatibility** – Allows projects to run seamlessly on different operating systems without modification.  
- **Scalability and Automation** – Facilitates easy replication and deployment across multiple environments with Dockerfiles.  

These advantages make Docker a powerful tool for accelerating research workflows and improving collaboration in AI development.

Why do I need AutoDock-AI? 🤔
===============================

In general, containers prove to be quite beneficial when used in artificial intelligence research projects. What more can AutoDock-AI offer than a from scratch implementation of a container?

Instead of creating a container from scratch, including building and running it, AutoDock-AI provides a ready-made, working solution that requires only specific user-defined changes. Primarily, by starting from a working baseline, the number of actions taken by a user is fewer, and targeted, reducing the number of possible errors, which would be also more easily detected.

Furthermore, it important to consider that relying on ready-made third-party images can be risky; the process of importing a container image does not make its content as explicit as in AutoDock-AI. This can lead to conflicts if the user proceeds by customizing it further, or unexpected behavior if the image quality is poor. 

In addition, it is quite rare to find a container image that fully meets one's needs, still leading the user to have to create a dockerfile, build it, and run it, in the case of using docker. 

This framework wants to allow the users to tailor containers on their needs in the most transparent way, while providing pre-configured dockerfiles which can be build and run just by executing a script, drammatically reducing the time consumed in getting the development environment ready.

However, the primary advantage offered by AutoDock-AI lies in its ability to facilitate the distribution of code. Through the automation provided by our framework, it is sufficient to execute just two straightforward bash scripts to exactly replicate the same development environment as used in competing methodologies, thereby significantly reducing the time and effort required by the research team.
