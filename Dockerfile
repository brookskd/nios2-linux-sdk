FROM centos:6
MAINTAINER Kyle Brooks <brookskd@gmail.com>

ENV CODESOURCERY_VERSION_MAJOR 2016.05
ENV CODESOURCERY_VERSION_MINOR 10
ENV CODESOURCERY_VERSION ${CODESOURCERY_VERSION_MAJOR}-${CODESOURCERY_VERSION_MINOR}
ENV BUILDROOT_VERSION 2016.05

ENV KERNEL_MAJOR 4
ENV KERNEL_MINOR 6
ENV KERNEL_PATCH 2
ENV KERNEL_VERSION ${KERNEL_MAJOR}.${KERNEL_MINOR}.${KERNEL_PATCH}

ENV UBOOT_SOCFPGA_VERSION 2016.05
ENV SOPC_TO_DTS_VERSION 13.1

WORKDIR /buildroot

RUN   yum update -y &&\
      yum groupinstall -y "Development Tools" &&\
      yum install -y ncurses-devel hmaccalc zlib-devel binutils-devel elfutils-libelf-devel java-1.8.0-openjdk-devel wget bc &&\
      mkdir -p /opt/nios2 &&\
      curl -SL "https://sourcery.mentor.com/GNUToolchain/package14496/public/nios2-linux-gnu/sourceryg++-${CODESOURCERY_VERSION}-nios2-linux-gnu-i686-pc-linux-gnu.tar.bz2" \
      | tar -xj -C /opt/nios2 &&\
      curl -SL "https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.bz2" \
      | tar -xj &&\
      pushd buildroot-${BUILDROOT_VERSION} &&\
      curl -SL -o configs/nios2_defconfig "https://rocketboards.org/foswiki/pub/Documentation/NiosIILinuxUserManual/nios2_defconfig?t=1466337990" &&\
      make nios2_defconfig &&\
      make -j$(nproc) &&\
      popd &&\
      curl -SL "https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_MAJOR}.x/linux-${KERNEL_VERSION}.tar.xz" \
      | tar -xJ &&\
      curl -SL "https://github.com/altera-opensource/u-boot-socfpga/archive/v${UBOOT_SOCFPGA_VERSION}.tar.gz" \
      | tar -xz &&\
      curl -SL "https://github.com/altera-opensource/sopc2dts/archive/rel_${SOPC_TO_DTS_VERSION}.tar.gz" \
      | tar -xz &&\
      pushd sopc2dts-rel_${SOPC_TO_DTS_VERSION} &&\
      pushd sopc2dts &&\
      make &&\
      popd &&\
      popd

COPY sopc2dts /usr/local/bin/

ENV PATH /opt/nios2/sourceryg++-${CODESOURCERY_VERSION_MAJOR}/bin:${PATH}

ENV ARCH nios2
ENV CROSS_COMPILE=nios2-linux-gnu-