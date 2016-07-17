FROM centos:6
MAINTAINER Kyle Brooks <brookskd@gmail.com>

ENV CODESOURCERY_VERSION_MAJOR 2016.05
ENV CODESOURCERY_VERSION_MINOR 10
ENV CODESOURCERY_VERSION ${CODESOURCERY_VERSION_MAJOR}-${CODESOURCERY_VERSION_MINOR}
ENV BUILDROOT_VERSION 2016.05

ENV KERNEL_URL https://github.com/brookskd/linux-nios2.git
ENV KERNEL_BRANCH linux-4.6.y

ENV UBOOT_SOCFPGA_VERSION 2016.05
ENV SOPC_TO_DTS_VERSION 13.1

ENV PATH /opt/nios2/sourceryg++-${CODESOURCERY_VERSION_MAJOR}/bin:${PATH}

ENV ARCH nios2
ENV CROSS_COMPILE nios2-linux-gnu-

WORKDIR /buildroot

COPY configs configs/
COPY sopc2dts /usr/local/bin/

RUN   yum update -y &&\
      yum groupinstall -y "Development Tools" &&\
      yum install -y glibc.i686 ncurses-devel hmaccalc zlib-devel binutils-devel elfutils-libelf-devel java-1.8.0-openjdk-devel wget bc epel-release &&\
      yum install -y uboot-tools &&\
      mkdir -p /opt/nios2 &&\
      curl -SL "https://sourcery.mentor.com/GNUToolchain/package14496/public/nios2-linux-gnu/sourceryg++-${CODESOURCERY_VERSION}-nios2-linux-gnu-i686-pc-linux-gnu.tar.bz2" \
      | tar -xj -C /opt/nios2 &&\
      curl -SL "https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.bz2" \
      | tar -xj &&\
      pushd buildroot-${BUILDROOT_VERSION} &&\
      ln -s ../../configs/buildroot/nios2_defconfig configs/nios2_defconfig &&\
      make -s nios2_defconfig &&\
      make -s -j$(nproc) &&\
      popd &&\
      curl -SL "https://github.com/altera-opensource/sopc2dts/archive/rel_${SOPC_TO_DTS_VERSION}.tar.gz" \
      | tar -xz &&\
      pushd sopc2dts-rel_${SOPC_TO_DTS_VERSION} &&\
      pushd sopc2dts &&\
      make -s &&\
      popd &&\
      popd &&\
      sopc2dts -i configs/qsys/nios_system.sopcinfo -o nios_system.dts &&\
      git clone --depth 1 --branch "${KERNEL_BRANCH}" "${KERNEL_URL}" linux &&\
      pushd linux &&\
      cp ../configs/linux/nios2_defconfig .config &&\
      make olddefconfig &&\
      make -j$(nproc) &&\
      popd &&\
      curl -SL "https://github.com/altera-opensource/u-boot-socfpga/archive/v${UBOOT_SOCFPGA_VERSION}.tar.gz" \
      | tar -xz

