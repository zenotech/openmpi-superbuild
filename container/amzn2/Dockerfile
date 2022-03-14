# syntax=docker/dockerfile:experimental
FROM amazonlinux:latest as intelinstall

RUN --mount=type=cache,target=/var/cache/yum yum -y install tar gzip gunzip yum-utils

# When updating the intel compiler also update enable_intel and intel.repo  script
COPY intel.repo /etc/yum.repos.d/
COPY parallel_studio_xe_2020_update4_cluster_edition.tgz .
RUN yum --disablerepo=intel-local.repo -y install createrepo
# This needs to be run as a single layer otherwise createrepo fails as python cannot copy between layers
RUN tar xvzf parallel_studio_xe_2020_update4_cluster_edition.tgz && cd parallel_studio_xe_2020_update4_cluster_edition && createrepo rpm
RUN yum clean metadata && yum -y install intel-parallel-studio-xe-icc intel-parallel-studio-xe-ifort intel-parallel-studio-xe-mkl intel-parallel-studio-xe-mpi intel-clck-2019.10-20200921-2019.10-20200921
RUN --mount=type=cache,target=/var/cache/yum yum -y install patch


FROM amazonlinux:latest as gccbuild

LABEL maintainer zenotech

RUN --mount=type=cache,target=/var/cache/yum yum -y install tar gzip gunzip yum-utils cmake3 make git

# Dev dependencies
RUN --mount=type=cache,target=/var/cache/yum  yum -y install patch which centos-release-scl rdma-core-devel libtool kernel-devel kernel-headers numactl-devel wget libffi-devel bzip2 bison flex bc bind-utils file curl-devel libGLU-devel
RUN --mount=type=cache,target=/var/cache/yum yum -y update ca-certificates && yum -y reinstall ca-certificates
#RUN --mount=type=cache,target=/var/cache/yum yum -y install devtoolset-8-toolchain rh-git218 rh-nodejs10
RUN --mount=type=cache,target=/var/cache/yum yum-config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo && yum clean all && yum -y install cuda-toolkit-11-1

RUN mkdir -p /opt/nodejs12 && wget -c https://nodejs.org/download/release/v12.20.2/node-v12.20.2-linux-x64.tar.gz -O - | tar -xz --strip-components=1 -C /opt/nodejs12

# Workaround for slow Intel license checkout on centos > 7.2
RUN sed -i 's/myhostname//' /etc/nsswitch.conf

# Setup home environment
RUN useradd -m dev && echo "dev:dev" | chpasswd && mkdir -p /home/dev/BUILD && chown -R dev:dev /home/dev

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 && chmod +x /usr/local/bin/dumb-init

RUN --mount=type=cache,target=/var/cache/yum yum -y install tar gzip util-linux

RUN curl -O https://efa-installer.amazonaws.com/aws-efa-installer-1.15.0.tar.gz && tar xvf aws-efa-installer-1.15.0.tar.gz && cd aws-efa-installer && ./efa_installer.sh -y --enable-gdr --minimal 


WORKDIR /home/dev
ENV HOME /home/dev
USER dev

ENV PATH=${PATH}:/usr/local/cuda/bin

CMD ["/bin/bash"]

FROM gccbuild as intel

COPY enable_intel /usr/local/

# Make sure the above SCLs are already enabled
ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/usr/local/enable_intel"]

#Install Intel compiler
COPY --from=intelinstall /opt/intel /opt/intel

ENV INTEL_LICENSE_FILE=28000@172.17.0.1

# Install oneAPI
# COPY oneAPI.repo /etc/yum.repos.d/
# RUN --mount=type=cache,target=/var/cache/yum  yum -y install intel-basekit
FROM gccbuild as gcc

USER root
#RUN --mount=type=cache,target=/var/cache/yum yum-config-manager --add-repo https://yum.repos.intel.com/mkl/setup/intel-mkl.repo && yum clean all && yum -y install intel-mkl-gnu-rt intel-mkl-common-c
USER dev

COPY enable_gcc /usr/local/

# Make sure the above SCLs are already enabled
ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/usr/local/enable_gcc"]
USER root
# RUN --mount=type=cache,target=/var/cache/yum yum -y install openmpi3-devel
USER dev
