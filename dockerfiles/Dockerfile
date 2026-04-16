# OS SETTINGS
# Here you can choose the OS and the CUDA version you want to mount 

FROM nvidia/cuda:12.0.1-devel-ubuntu22.04

# install uv package manager for python (https://astral.sh/uv/)
# faster than anaconda, safer than pip
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# you can find more versions here:
# https://hub.docker.com/r/nvidia/cuda/
# https://hub.docker.com/r/nvidia/cuda/tags?page=1&name=base-ubuntu


# -----------------------------------------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT SETTINGS
# In this section we want to specify which softwares we want to pre-install within the docker

# to be sure we set non interactive bash also here
# we also set the PATH and LD_LIBRARY_PATH for the nvidia drivers
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

# install some basic tools and libraries for development, visualization, and machine learning
# you can add/remove any package you want here, but be careful with the size of the docker image
RUN apt-get update && apt-get install -y -q \
    sudo git tmux nano curl wget bash bash-completion build-essential \
    ffmpeg pkg-config \
    x11-apps mesa-utils libgtk2.0-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev \
    libfreetype6-dev libportmidi-dev libjpeg-dev libturbojpeg0-dev \
    libpng-dev libtiff-dev \
    libopenmpi-dev libopenblas-dev libhdf5-dev hdf5-tools \
    libprotobuf-dev protobuf-compiler \
    gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi \
    libusb-1.0-0-dev libhidapi-dev libtool autoconf automake texinfo make \
    libopencv-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# remove python2
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# -----------------------------------------------------------------------------------------------------------------------------------------------------
# USER SETTINGS

# the docker's user will be $USER and its home will be '/$USER/home'
ARG UID=1000
ARG GID=1000
ARG USER_NAME=user
ARG USER_HOME=/home/$USER_NAME

# create a user with the same UID and GID as the host user, 
# and add it to the sudoers file to allow it to run sudo commands without a password
RUN groupadd -g $GID -o $USER_NAME \
    && useradd -m -u $UID -g $GID -o -s /bin/bash $USER_NAME \
    && echo "$USER_NAME:Docker!" | chpasswd \
    && mkdir -p /src && chown -R $USER_NAME:$USER_NAME /src \
    && mkdir -p /etc/sudoers.d \
    && usermod -aG video,dialout,plugdev,tty $USER_NAME \
    && echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME

# -----------------------------------------------------------------------------------------------------------------------------------------------------
# FINAL SETUPS

# switch to the created user and set the working directory to its home
USER $USER_NAME

ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

ENV VIRTUAL_ENV=$USER_HOME/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
# this variable is used by torch to determine which cuda architectures to build for
ENV TORCH_CUDA_ARCH_LIST="8.9;8.6"
ENV _GLIBCXX_USE_CXX11_ABI=0

WORKDIR $USER_HOME/build_deps

COPY --chown=$USER_NAME:$USER_NAME ./src/requirements/pyproject.toml ./
COPY --chown=$USER_NAME:$USER_NAME ./src/requirements/. ./
RUN chown -R $USER_NAME:$USER_NAME $USER_HOME/build_deps

# create virtual env with uv and upgrade base packages
RUN uv venv $VIRTUAL_ENV --python 3.11 
RUN uv pip install pip setuptools wheel packaging ninja Cython --upgrade

# install the desktop version of autodock
RUN uv pip install ".[desktop]" --no-build-isolation 

RUN rm -rf $USER_HOME/app
RUN uv cache clean
RUN echo "source ${VIRTUAL_ENV}/bin/activate" >> ~/.bashrc

WORKDIR $USER_HOME

# when the container is launched it will start a bash session
CMD ["/bin/bash"]
