# docker build for distributing a base fs 7.1.1 container
# DOCKER_BUILDKIT=0 docker build -t freesurfer-dev .
# docker run -v /tmp/.X11-unix:/tmp/.X11-unix -v /mnt/wslg:/mnt/wslg -it freesurfer-dev

FROM ubuntu:focal
SHELL ["/bin/bash", "-c"]

# shell settings
WORKDIR /root
COPY . .

# Update Sources
RUN apt -y update
RUN apt install -y curl gnupg2 software-properties-common

# Add WSL CUDA Driver
RUN curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
RUN curl -s -L https://nvidia.github.io/nvidia-docker/$(. /etc/os-release;echo $ID$VERSION_ID)/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list
RUN curl -s -L https://nvidia.github.io/libnvidia-container/experimental/$(. /etc/os-release;echo $ID$VERSION_ID)/libnvidia-container-experimental.list | tee /etc/apt/sources.list.d/libnvidia-container-experimental.list
RUN apt -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nvidia-docker2

# install fs
# RUN wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.1.1/freesurfer-linux-centos7_x86_64-7.1.1.tar.gz -O fs.tar.gz && \
#     tar --no-same-owner -xzvf fs.tar.gz && \
#     mv freesurfer /usr/local && \
#     rm fs.tar.gz

# setup fs env
ENV OS Linux
ENV FS_LICENSE /root/license.txt
ENV PATH /usr/local/freesurfer/bin:/usr/local/freesurfer/fsfast/bin:/usr/local/freesurfer/tktools:/usr/local/freesurfer/mni/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV FREESURFER_HOME /usr/local/freesurfer/7-dev
ENV FREESURFER /usr/local/freesurfer
ENV SUBJECTS_DIR /usr/local/freesurfer/subjects
ENV LOCAL_DIR /usr/local/freesurfer/local
ENV FSFAST_HOME /usr/local/freesurfer/fsfast
ENV FMRI_ANALYSIS_DIR /usr/local/freesurfer/fsfast
ENV FUNCTIONALS_DIR /usr/local/freesurfer/sessions

# set default fs options
ENV FS_OVERRIDE 0
ENV FIX_VERTEX_AREA ""
ENV FSF_OUTPUT_FORMAT nii.gz

# mni env requirements
ENV MINC_BIN_DIR /usr/local/freesurfer/mni/bin
ENV MINC_LIB_DIR /usr/local/freesurfer/mni/lib
ENV MNI_DIR /usr/local/freesurfer/mni
ENV MNI_DATAPATH /usr/local/freesurfer/mni/data
ENV MNI_PERL5LIB /usr/local/freesurfer/mni/share/perl5
ENV PERL5LIB /usr/local/freesurfer/mni/share/perl5

# Force version of gcc
## gcc 4.8 is not available in focal
RUN add-apt-repository 'deb http://dk.archive.ubuntu.com/ubuntu/ xenial main'
RUN add-apt-repository 'deb http://dk.archive.ubuntu.com/ubuntu/ xenial universe'
RUN apt -y update

RUN apt -y install gcc-4.8 g++-4.8 gfortran-4.8

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 48 --slave /usr/bin/g++ g++ /usr/bin/g++-4.8 --slave /usr/bin/gcov gcov /usr/bin/gcov-4.8 --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-4.8
RUN update-alternatives --set gcc "/usr/bin/gcc-4.8"
# RUN update-alternatives --set g++ "/usr/bin/g++-4.8"
# RUN ln -s /usr/bin/cpp-4.8 /usr/bin/cpp
# RUN ln -s /usr/bin/gcc-4.8 /usr/bin/gcc
# RUN ln -s /usr/bin/g++-4.8 /usr/bin/g++

## Remove temporary sources after use
RUN add-apt-repository --remove 'deb http://dk.archive.ubuntu.com/ubuntu/ xenial main'
RUN add-apt-repository --remove 'deb http://dk.archive.ubuntu.com/ubuntu/ xenial universe'
RUN apt -y update

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bc build-essential git git-annex libarmadillo-dev libatlas-base-dev libatlas3-base libblas-dev libglu1-mesa-dev liblapack-dev libomp-dev libopenblas-base libqt5x11extras5-dev libquadmath0 libsm-dev libx11-dev libxext-dev libxi-dev libxmu-dev libxmu-headers libxrender-dev libxt-dev perl petsc-dev python3-dev python3-pip python3-venv qt5-default tar tcsh vim-common wget xxd zlib1g-dev

# Setup python dev environment
RUN pip3 install --upgrade pip
RUN python3 -m pip install --upgrade setuptools
RUN pip3 install scipy
RUN pip3 install tensorflow tensorflow-gpu
RUN pip3 install tables nibabel scikit-image

# Should be downloading here
# RUN wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/dev/freesurfer_7-dev_amd64.deb
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ./freesurfer_7-dev_amd64.deb
RUN rm ./freesurfer_7-dev_amd64.deb
# RUN echo "export XDG_RUNTIME_DIR=$HOME/.xdg" >> $HOME/.bashrc
# RUN echo "export DISPLAY=:0" >> $HOME/.bashrc
# RUN echo "export FREESURFER_HOME=/usr/local/freesurfer/7-dev" >> $HOME/.bashrc
# RUN echo "export FS_LICENSE=$HOME/license.txt" >> $HOME/.bashrc


# COPY /usr/local/freesurfer/7-dev/FreeSurferEnv.sh /usr/local/freesurfer/FreeSurferEnv.sh
# RUN echo "source /usr/local/freesurfer/7-dev/SetUpFreeSurfer.sh" >> /root/.bashrc
CMD source ~/.bashrc && /usr/local/freesurfer/7-dev/SetUpFreeSurfer.sh

# WSLg
CMD export DISPLAY="$(grep nameserver /etc/resolv.conf | sed 's/nameserver //'):0"
ENV WAYLAND_DISPLAY=wayland-0
ENV XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir
ENV PULSE_SERVER=/mnt/wslg/PulseServer

VOLUME /tmp/.X11-unix
VOLUME /mnt/wslg
