VSCode with containers
===========================
VSCode is a powerful code editor that supports a wide range of programming languages and extensions. It also provides built-in support for working with Docker containers, making it an excellent choice for developing and debugging containerized applications.
Thanks to a few free extensions downloadable from the marketplace, you can use VSCode to develop and debug your code directly inside a container. This allows you to leverage the benefits of containerization while maintaining a familiar development environment.

To get started with VSCode and Docker, follow these steps:

1. **Install the Containers extension**
    - ``ms-azuretools.vscode-docker``.

2. **Install the Remote - Containers extension** 
    - ``ms-vscode-remote.remote-containers``.

3. **Discovering containers in VSCode**
    - click on the Docker "whale" icon in the activity bar on the side of the window.
    - select the "Containers" view. Here all running containers are listed. Make sure your container is running.
4. **Attach a container** 
    - Right-click on the container's name which follows a "green" arrow, and click on "Attach Visual Studio Code".
    - VSCode will open a new window inside the container. You can now develop and debug your code as if you were working locally.
5. **Open project folder**
    - Click on "Open Folder" to open the workspace folder inside the container. With AutoDock-AI you have to provide the ``/home/user/src`` folder.
    - Start coding!

.. important::
    From now on, you can use VSCode to develop and debug your code inside the container. Debug sessions will run inside the container, allowing you to take full advantage of the containerized environment.
    Consider that when you close the VSCode window, the container will keep running. 
