# AutoDock-AI
![Designer](https://github.com/user-attachments/assets/1bb22c91-bfa7-451f-ba5b-165ef103b889)

# 🚀 New Documentation is Here! 🚀

We are excited to announce that our **new documentation** is now available!

🎉 **Check it out** for detailed guides, tutorials, and much more! 🎉

👉 [Visit the New Documentation](https://danielrossi1.github.io/AutoDock/)

Don't miss out on all the amazing content we've prepared for you!

---

## Introduction 📖
This Docker-based framework is designed to facilitate research by enabling projects to run seamlessly across different machines while ensuring optimal sharing and reproducibility.

Its primary objective is to minimize the setup and execution times of AI projects by providing a streamlined and standardized environment. By leveraging containerization, the framework eliminates compatibility issues, reduces dependency conflicts, and ensures a reproducible execution across different machines. This not only accelerates the deployment process but also enhances collaboration by allowing researchers to share their work more efficiently. Ultimately, it enables faster experimentation, facilitating innovation and reducing the overhead associated with configuring and managing computational environments.

### **Advantages of Using Docker** 💥

Docker offers several advantages over traditional environment management methods, including virtual machines, Anaconda environments, and "requirements.txt" files. By providing a lightweight, portable, and reproducible solution, Docker enhances efficiency in AI research and development. The key benefits include:

- **Lightweight and Efficient** – Uses fewer system resources compared to virtual machines by sharing the host OS kernel.  
- **Fast Deployment** – Enables quick setup and execution, reducing time spent on environment configuration.  
- **Full Reproducibility** – Ensures consistency across different machines by encapsulating the entire software environment.  
- **Comprehensive Dependency Management** – Handles system-level dependencies, including CUDA and GPU drivers, unlike Anaconda.  
- **Cross-Platform Compatibility** – Allows projects to run seamlessly on different operating systems without modification.  
- **Scalability and Automation** – Facilitates easy replication and deployment across multiple environments with Dockerfiles.  

These advantages make Docker a powerful tool for accelerating research workflows and improving collaboration in AI development.


### Why do I need a Docker? 🤔
Currently, there are various methods for sharing the setup of an Artificial Intelligence research project. Many researchers share only a requirements file, while others provide a configuration file for an environment managed by Anaconda. However, a significant challenge in research projects is the considerable amount of time spent on setup tasks, such as installing Python, configuring GPU drivers, setting up CUDA, installing Anaconda, and resolving errors and dependency conflicts.

Despite its advantages, Docker has not yet become the de facto standard in the research community. However, broader adoption could significantly reduce setup time and improve reproducibility, ultimately enhancing efficiency in AI research.

Docker enables the creation of an isolated environment similar to a virtual machine, where any action performed within it — such as installing an Ubuntu package or a Python library — is discarded once the container is closed. To ensure that changes made within a Docker container are persistent, they must be explicitly defined in the Dockerfile.

In addition to presenting this tool, which I believe is highly effective for better managing one’s environment, it is also a skill in high demand within the industry (making it worthwhile to learn). Furthermore, I propose that it can be used to better organize research projects in the following way:
- **`project-directory`**: a folder with the name of your research project.
  - **`AutoDock`**: import here the *AutoDock* as submodule.
  - **`src`**: the main directory where you implement the project.
    - **`project files and dirs ...`**: your stuff
    - **`requirements`**: the directory where you specify all the requirements files
        - **`workstation.txt`**: for your development workstation
        - **`jetsonNano.txt`**: specific for jetson nano
        - **`jetsonOrin.txt`**: specific for jetson orin
        - **`raspberryPi.txt`**: specific for raspberry pi
        - **`and so on ...`**: in each dockerfile an Env variable is set to refer to the requirements file that needs to be installed

## Docker setup 🐳
1. Install Docker Engine:
    https://docs.docker.com/engine/install/

    or install Docker with:
    ```bash
    curl -fsSL https://get.docker.com | sh
    ```

2. (Optional, NVIDIA GPUs) Install NVIDIA Container Toolkit for GPU support (or follow [this](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) procedure (Recommended) ):
    ```bash
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    ```

    update and install the nvidia container tool
    ```bash
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    ```

    configure nvidia container tool
    ```bash
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
    ```

3. Add required permissions to your user in order to perform actions with docker on containers
    ```bash
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    ```

4. Import AutoDock and build the image (you will download Ubuntu + CUDA + dependencies, so it may take several minutes)

    - Importing AutoDock as submodule (to use it as it is)
        ```bash
        git submodule add https://github.com/DanielRossi1/AutoDock
        git submodule update --init --recursive
        ```
    - Cloning
        ```bash
        git clone https://github.com/DanielRossi1/AutoDock
        ```

    then go to the `AutoDock` directory and build explicitly:
    ```bash
    cd AutoDock
    ./build.sh
    ```

    Notes:
    - `./run.sh` will automatically build the image if it does not exist.
    - Use `./build.sh` when you want to build explicitly (e.g., CI or pre-building on a remote machine).

5. Run the container (from the `AutoDock` directory):
    ```bash
    ./run.sh [options] [-- <command> [args...]]
    ```

    Common options:
    - `--rebuild`: force rebuild of the image before running
    - `--no-build`: do not auto-build (error if the image is missing)
    - `--no-rm`: keep the container after exit (disables `--rm`)
    - `--detach`: run container in background (no TTY)

    - `--image NAME`, `--tag TAG`: override image name/tag
    - `--name NAME`: override container name
    - `--user USER[:GROUP]`: override docker `--user`
    - `--workdir DIR`: override docker `--workdir`
    - `--shm-size SIZE`: override `--shm-size`
    - `--network MODE`: override network mode (default: `host`)

    - `-d /path/to/folder` / `--dir /path/to/folder`: mount a host folder under `/home/user/<folder_name>` (repeatable)
    - `--data /path/to/folder`: mount a host folder under `/home/user/data`
    - `--mount HOST:CONTAINER[:ro]`: raw bind mount spec (repeatable)
    - `--ssh`: mount `~/.ssh` to `/home/user/.ssh` (read-only)
    - `--ssh-agent`: forward `SSH_AUTH_SOCK` (if available)
    - `--gitconfig`: mount `~/.gitconfig` to `/home/user/.gitconfig` (read-only)
    - `--cache`: mount common AI caches under `/home/user` (`pip`, `huggingface`, `torch`, `uv`)

    - `-w` / `--webcam`: mount `/dev/video*` devices
    - `-a` / `--audio`: mount audio devices (`/dev/snd`) and forward PulseAudio when available
    - `-p` / `--peripherals`: enable embedded peripherals (gpio/i2c/spi)
    - `-i` / `--hid`: enable HID devices (`/dev/hidraw*`)
    - `--no-gpu`: disable GPU runtime options even if detected

    - `-e KEY=VALUE` / `--env KEY=VALUE`: add environment variable (repeatable)
    - `-E KEY` / `--env-pass KEY`: pass-through host env var (repeatable)
    - `--env-file FILE`: read env vars from file (repeatable)

    - `-P HOST:CONTAINER` / `--port HOST:CONTAINER`: publish a port (repeatable)

    - `-- <command> [args...]`: run a specific command instead of the default container command

    Tip:
    - Run `./run.sh --help` to see the full option list.

## Structured config (`autodock.config.json`)

AutoDock supports an always-checked structured config file at `AutoDock/autodock.config.json`.

- If top-level `"ENABLED"` is `false` (default), the file is ignored (besides the enable check).
- If `"ENABLED"` is `true`, AutoDock applies:
    - Top-level `AUTODOCK_*_DEFAULT` keys as defaults (affects both `./build.sh` and `./run.sh`).
    - The `RUN` block as additional `./run.sh` arguments (including repeatable mounts like `RUN.dirs`).
    - `RUN.command` as a default container command, only when you don’t pass your own command after `--`.

You can override the config path with `AUTODOCK_CONFIG_FILE=/abs/path/to/config.json`.

Precedence (highest wins):

- `./run.sh` CLI options
- Environment variables
- `autodock.config.json` defaults (`ENABLED=true`)
- Hard-coded defaults in AutoDock

### Example

Enable the config and mount multiple `-d` directories:

```json
{
  "ENABLED": true,
  "AUTODOCK_IMAGE_NAME_DEFAULT": "autodock",
  "AUTODOCK_IMAGE_TAG_DEFAULT": "latest",
  "AUTODOCK_CONTAINER_NAME_DEFAULT": "AutoDock",

  "RUN": {
    "dirs": [
      "../datasets",
      "/mnt/ssd/experiments"
    ],
    "ssh": true,
    "command": ["bash"]
  }
}
```

Notes:

- Relative paths inside `RUN.dirs`, `RUN.data`, `RUN.mounts`, and `RUN.env.files` are resolved relative to the config file location.
- `RUN.mounts` entries must be of the form `HOST:CONTAINER[:ro]`.

## Conda environment helper (`generate_conda_env.sh`) (optional)

Generate `src/environment.yml` from your `src/requirements/*` files:

```bash
cd AutoDock
bash ./generate_conda_env.sh
```

## Coding with VSCode 🧑🏼‍💻
To be able to program and execute the code inside the docker at the same time (permanent programming, the files will remain even when the docker is closed) I recommend using [VSCode](https://code.visualstudio.com/).

As extensions to do this I use the following. Go to the VSCode marketplace (CTRL+SHIFT+X) and search for:
- ```ms-azuretools.vscode-docker```
- ```ms-vscode-remote.remote-containers```

once the extensions have been installed and after launching the docker *run* script, in the menu on the left of VSCode you must select the whale icon (docker), and under the "individual containers" item you will find the container you have just launched with a green arrow next to it. By clicking with the right mouse button on it you will find "attach with VSCode", and this will open a new window for programming inside the docker.

It's not over here, one last step is missing! Go to File>Open Folder -> enter `/home/user` as the path

## Remote Host Connection 🛜
The script `remote.sh` configurest the local host and the remote host in order to run the docker remotely but develop through VSCode on the local machine. It creates a local SSH key to be used later to attach docker to the remote container, and adds that key into the remote host `~/.ssh/authorized_keys`. Then it creates a local `~/.ssh/config` pointing to that remote host, with the generated key. Finally it updates a docker context on the local machine in order to connect and list the containers running on the remote machine.

The difference between using a basic SSH connection on VSCode to connect to the host machine and establishing a remote container connection (still over SSH) is that, in the second case, it enables VSCode to discover running container on the remote machine and attach to them. This means that you can launch debug sessions.
```bash
chmod +x remote.sh
./remote.sh <remote_connection_name> <remote_username> <remote_host_address>

# example:
# ./remote.sh edge01 ubuntu 192.168.1.10
```

## Support & solutions ✅
Here is listed what AutoDock is currently able to install and run:
 - CUDA & cudnn
 - ubuntu packages (apt install)
 - Python, pip and multiple requirements.txt install
 - Python .whl install
 - Anaconda 
 - Remote Host Connection
 - ROS Noetic automatic installation within Dockerfile
 - Pre-configured containers for: Raspbery Pi, NVIDIA Jetson Orin Nano, NVIDIA Jetson Nano
 - Automatic device detection for container build an run
 - Microphone and speakers
 - Videocameras
 - XBOX 360 Kinect RGB and Depth Camera

 More customization and examples are available in the online docs: https://danielrossi1.github.io/AutoDock/

## License 📜

This project is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/).

### Summary of Terms
- **Attribution (BY)**: You must give appropriate credit to the original author(s), provide a link to the license, and indicate if changes were made.
- **NonCommercial (NC)**: This work may not be used for commercial purposes.
- **ShareAlike (SA)**: If you remix, transform, or build upon this work, you must distribute your contributions under the same license as the original.

For the full legal text of the license, please refer to [https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode).

### Commercial Use
If you are interested in using this work for commercial purposes, please contact me.

## Citation 📝

If you find this code useful for your research, please consider citing:

```bibtex
@misc{Rossi2023AutoDock,
  author = {Rossi, Daniel},
  title = {AutoDock: a docker-based framework accelerating Artificial Intelligence research},
  year = {2025},
  publisher = {GitHub},
  journal = {GitHub repository},
  howpublished = {\url{https://github.com/DanielRossi1/AutoDock}}
}
```

## Contributions 💻
If you find errors or have suggestions for improving this project, feel free to open an issue or send a pull request.

tested with docker version: 24.5.0
