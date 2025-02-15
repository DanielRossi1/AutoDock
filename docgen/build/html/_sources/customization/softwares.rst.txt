Softwares
=========

Anaconda (Python virtual environments manger)
---------------------------------------------

Anaconda is a free and open-source distribution of the Python and R programming languages for scientific computing, that aims to simplify package management and deployment. Package versions are managed by the package management system conda. To install Anaconda, you can use the following command:

.. code-block:: bash
    
    ENV CONDA_DIR /opt/conda
    RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && /bin/bash ~/miniconda.sh -b -p /opt/conda
    ENV PATH=$CONDA_DIR/bin:$PATH

    COPY ../src/environment.yml ./tmp/environment.yml
    RUN conda env create -f tmp/environment.yml
    RUN /bin/bash -c "conda init bash"
    RUN echo "source /opt/conda/bin/activate your_environment_name" >> /home/${USER_NAME}/.bashrc