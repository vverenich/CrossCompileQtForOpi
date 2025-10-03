# Cross compilation of Qt6.8.0 for Orange Pi 3B v2.1
This page shows steps to compile Qt6.8.0 for Orange Pi 3B v2.1 and shows how to run simple application on it. 

<img width="562" height="465" alt="image" src="https://github.com/user-attachments/assets/ebbcda19-a1bb-4fef-88ea-9f7cd5c64c6c" />


# Prerequisites

* virtual machine or laptop or PC running Ubuntu 22.04(or Ubuntu-based distributive) or newer. The host.
* Oragepi 3B v2.1, running "Orangepi3b_1.0.6_ubuntu_jammy_server_linux5.10.160"(you can download the tarball with the image from here: https://drive.google.com/drive/folders/1ZqiTNgbq2ezCTv_r0PT5wqFoSxN39zsr). The target.

NOTE!!! I've been trying to run Linux6.6-based images, but it did not work(my single board computer did not boot). According to the official docs(user manual: https://drive.google.com/drive/folders/18YyPnq_f0gbdNlbsNmzouFPxin08C_gf ) at the moment of writing this page only Linux5.10 system is well adapted to work with all the peripherals of the Orange Pi 3B v2.1. 

NOTE!!! The server version of the ubuntu for Orange Pi 3B is used for this tutorial. Because it is more stable, consumes less RAM and CPU, requires less space comparing to the desktop version. But you can use desktop versio too, e.g. "Orangepi3b_1.0.6_ubuntu_jammy_desktop_linux5.10.160".

# Prepare the target(Orange Pi 3B v2.1)

Connect your SBC to WiFi using the following command:

```
nmcli dev wifi connect <wifi_name> password <wifi_passwd>
```

Make sure you have connected successfully using the following command:

```
ping google.com
```

Get the IP address of the SBC:

```
ip addr show wlan0
```

Get back to your development laptop/PC and connect to the SBC remotely using the following command(the default root password is orangepi):

```
ssh orangepi@<ip_address>
```

Now you need to install all the necessary packages.

Update APT cache:

```
sudo apt update
```

Install all the necessary libs and packages:

```
sudo apt-get install libboost-all-dev libudev-dev libinput-dev libts-dev libmtdev-dev libjpeg-dev libfontconfig1-dev libssl-dev libdbus-1-dev libglib2.0-dev libxkbcommon-dev libegl1-mesa-dev libgbm-dev libgles2-mesa-dev mesa-common-dev libasound2-dev libpulse-dev gstreamer1.0-omx libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev  gstreamer1.0-alsa libvpx-dev libsrtp2-dev libsnappy-dev libnss3-dev "^libxcb.*" flex bison libxslt-dev ruby gperf libbz2-dev libcups2-dev libatkmm-1.6-dev libxi6 libxcomposite1 libfreetype6-dev libicu-dev libsqlite3-dev libxslt1-dev ffmpeg
```

```
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libx11-dev freetds-dev libsqlite3-dev libpq-dev libiodbc2-dev firebird-dev libxext-dev libxcb1 libxcb1-dev libx11-xcb1 libx11-xcb-dev libxcb-keysyms1 libxcb-keysyms1-dev libxcb-image0 libxcb-image0-dev libxcb-shm0 libxcb-shm0-dev libxcb-icccm4 libxcb-icccm4-dev libxcb-sync1 libxcb-sync-dev libxcb-render-util0 libxcb-render-util0-dev libxcb-xfixes0-dev libxrender-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-glx0-dev libxi-dev libdrm-dev libxcb-xinerama0 libxcb-xinerama0-dev libatspi2.0-dev libxcursor-dev libxcomposite-dev libxdamage-dev libxss-dev libxtst-dev libpci-dev libcap-dev libxrandr-dev libdirectfb-dev libaudio-dev libxkbcommon-x11-dev gdbserver
```

Make a folder for qt6 installation.

```
sudo mkdir /usr/local/qt6
```

Grant full access to the fold used for the deployment from Qt Creator.

```
sudo chmod 777 /usr/local/bin
```
Remember versions of gcc(11.4.0), ld(2.38) and ldd(2.35). Source code of the same version should be downloaded to build cross compiler later.

<img width="718" height="310" alt="image" src="https://github.com/user-attachments/assets/5bda4666-f7e3-4bb8-91bf-d9431bc42258" />


Append following piece of code to the end of ~/.bashrc.

```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/qt6/lib/
```

Update the changes.

```
source ~/.bashrc
```

# Prepare host

Update the system:

```
sudo apt update
```

Install necessary packages.

```
sudo apt-get install make build-essential libclang-dev ninja-build gcc git bison python3 gperf pkg-config libfontconfig1-dev libfreetype6-dev libx11-dev libx11-xcb-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libxcb-glx0-dev libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-util-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev libatspi2.0-dev libgl1-mesa-dev libglu1-mesa-dev freeglut3-dev build-essential gawk git texinfo bison file wget libssl-dev gdbserver gdb-multiarch libxcb-cursor-dev gcc-aarch64-linux-gnu flex libtool gettext cmake 
```


## Build gcc as a cross compiler

Execute the following command:

```
cd $HOME
mkdir qt-cross-compilation-for-opi && cd qt-cross-compilation-for-opi
mkdir gcc_all && cd gcc_all
```

Download necessary source code. You should modify the following commands to your needs. For the time I make this page, they are:

* gcc 11.4.0
* binutils 2.38(ld version)
* glibc 2.35(ldd version)

Visit the following links to download it(to the gcc_all folder):

* https://ftpmirror.gnu.org/binutils/binutils-2.38.tar.bz
* https://ftpmirror.gnu.org/glibc/glibc-2.35.tar.bz2
* https://ftpmirror.gnu.org/gcc/gcc-11.4.0/gcc-11.4.0.tar.gz

Then do the following:

```
git clone --depth=1 https://github.com/orangepi-xunlong/linux-orangepi
tar xf binutils-2.38.tar.bz2
tar xf glibc-2.35.tar.bz2
tar xf gcc-11.4.0.tar.gz
rm *.tar.*
cd gcc-11.4.0
contrib/download_prerequisites
```

Make a folder for the compiler installation.

```
sudo mkdir -p /opt/cross-pi-gcc
sudo chown $USER /opt/cross-pi-gcc
export PATH=/opt/cross-pi-gcc/bin:$PATH
```

Copy the kernel headers in the above folder.

```
cd $HOME
cd qt-cross-compilation-for-opi/gcc_all
cd linux-orangepi
KERNEL=kernel7
make ARCH=arm64 INSTALL_HDR_PATH=/opt/cross-pi-gcc/aarch64-linux-gnu headers_install
```

Build Binutils. You should modify the following commands to your needs. If you got an error you will likely need to execute the following commands: "make distclean", then "rm -f config.cache", then reconfigure, then run just "make" without -j flag to see the more descriptive error.

```
cd ~/qt-cross-compilation-for-opi/gcc_all
mkdir build-binutils && cd build-binutils
../binutils-2.38/configure --prefix=/opt/cross-pi-gcc --target=aarch64-linux-gnu --with-arch=armv8 --disable-multilib
make -j 8
make install
```

Edit gcc-11.4.0/libsanitizer/asan/asan_linux.cpp. Add following piece of code.

```
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif
```

Do a partial build of gcc. You should modify the following commands to your needs. Remember that you can run just "make" instead of "make -j8 all-gcc" in order to get more descriptive error. During the execution of the following commands I got an error "error: passing argument 1 of ‘set_32’ from incompatible pointer type" that's why I manually fixed it in source code(casted to teh appropriate pointer type).

```
cd ~/qt-cross-compilation-for-opi/gcc_all
mkdir build-gcc && cd build-gcc
../gcc-11.4.0/configure --prefix=opt/cross-pi-gcc --target=aarch64-linux-gnu --enable-languages=c,c++ --disable-multilib
make -j8 all-gcc
make install-gcc
```


Partially build Glibc. You should modify the following commands to your needs.

```
cd ~/qt-cross-compilation-for-opi/gcc_all
mkdir build-glibc && cd build-glibc
../glibc-2.35/configure --prefix=/opt/cross-pi-gcc/aarch64-linux-gnu --build=$MACHTYPE --host=aarch64-linux-gnu --target=aarch64-linux-gnu --with-headers=/opt/cross-pi-gcc/aarch64-linux-gnu/include --disable-multilib libc_cv_forced_unwind=yes --disable-werror CFLAGS="-O2 -fno-builtin-modff64"
make install-bootstrap-headers=yes install-headers
make -j8 csu/subdir_lib
install csu/crt1.o csu/crti.o csu/crtn.o /opt/cross-pi-gcc/aarch64-linux-gnu/lib
aarch64-linux-gnu-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/cross-pi-gcc/aarch64-linux-gnu/lib/libc.so
touch /opt/cross-pi-gcc/aarch64-linux-gnu/include/gnu/stubs.h
```

Back to gcc.

```
cd ~/qt-cross-compilation-for-opi/gcc_all/build-gcc
make -j8 all-target-libgcc
make install-target-libgcc
```

Finish building glibc.

```
cd ~/qt-cross-compilation-for-opi/gcc_all/build-glibc
make -j8
make install
```

Finish building gcc.

```
cd ~/qt-cross-compilation-for-opi/gcc_all/build-gcc
make -j8
make install
```

At this point, we have a full cross compiler toolchain with gcc. Folder gcc_all is not need any more. You can delete it.

### Building Qt6

Make folders for sysroot and qt6.

```
cd $HOME
cd qt-cross-compilation-for-opi
mkdir opi-sysroot opi-sysroot/usr opi-sysroot/opt
mkdir qt6 qt6/host qt6/pi qt6/host-build qt6/pi-build qt6/src
```

Download QtBase source code. 
Use the mirror(https://mirrors.dotsrc.org/qtproject/official_releases/qt/6.8/6.8.0/single/qt-everywhere-src-6.8.0.tar.xz) in case of the restricted access to the https://download.qt.io .

```
cd qt6/src
wget https://download.qt.io/official_releases/qt/6.8/6.8.0/single/qt-everywhere-src-6.8.0.tar.xz
tar xf qt-everywhere-src-6.8.3.tar.xz
```

#### Build Qt6 for host

Fix the following command according to your needs.

```
cd $HOME/qt-cross-compilation-for-opi/qt6/host-build/
../src/qt-everywhere-src-6.8.0/configure \
    -opensource \
    -confirm-license \
    -release \
    -strip \
    -feature-relocatable \
    -rpath \
    -nomake examples \
    -nomake tests \
    -skip qtgamepad \
    -skip qtlottie  \
    -skip qtspeech \
    -skip qtlocation \
    -skip qtpurchasing \
    -skip virtualkeyboard \
    -skip qtwebengine \
    -skip qtwebchannel \
    -skip qtwebglplugin \
    -skip qtwebsockets \
    -skip qtwebview \
    -skip qt3d \
    -skip qtgraphs \
    -skip qtdoc \
    -skip qtquick3d \
    -skip qtquick3dphysics \
    -- \
    -DCMAKE_BUILD_TYPE=Release \
    -DQT_BUILD_EXAMPLES=OFF \
    -DQT_BUILD_TESTS=OFF \
    -DCMAKE_INSTALL_PREFIX=$HOME/qt-cross-compilation-for-opi/qt6/host
cmake --build . --parallel 4
cmake --install .
```


#### Build Qt6 for target

Copy and paste a few folders from opi using rsync through SSH. You should modify the following commands to your needs.

```
cd $HOME/qt-cross-compilation-for-opi
rsync -avz orangepi@192.168.100.83:/usr/include opi-sysroot/usr
rsync -avz orangepi@192.168.100.83:/lib opi-sysroot
rsync -avz orangepi@192.168.100.83:/usr/lib opi-sysroot/usr 
rsync -avz orangepi@192.168.100.83:/opt/vc opi-sysroot/opt
```

Create a file named toolchain.cmake in $HOME/qt-cross-compilation-for-opi/qt6 folder. 
!!! DO NOT FORGET !!! to change the path to the sysroot.

```
cmake_minimum_required(VERSION 3.18)
include_guard(GLOBAL)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# You should change location of sysroot to your needs.
set(TARGET_SYSROOT /home/verchik/qt-cross-compilation-for-opi/opi-sysroot)
set(TARGET_ARCHITECTURE aarch64-linux-gnu)
set(CMAKE_SYSROOT ${TARGET_SYSROOT})

set(ENV{PKG_CONFIG_PATH} $PKG_CONFIG_PATH:${CMAKE_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/pkgconfig)
set(ENV{PKG_CONFIG_LIBDIR} /usr/lib/pkgconfig:/usr/share/pkgconfig/:${TARGET_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/pkgconfig:${TARGET_SYSROOT}/usr/lib/pkgconfig)
set(ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_SYSROOT})

set(CMAKE_C_COMPILER /opt/cross-pi-gcc/bin/${TARGET_ARCHITECTURE}-gcc)
set(CMAKE_CXX_COMPILER /opt/cross-pi-gcc/bin/${TARGET_ARCHITECTURE}-g++)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -isystem=/usr/include -isystem=/usr/local/include -isystem=/usr/include/${TARGET_ARCHITECTURE}")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}")

set(QT_COMPILER_FLAGS "-march=armv8-a")
set(QT_COMPILER_FLAGS_RELEASE "-O2 -pipe")
set(QT_LINKER_FLAGS "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed -Wl,-rpath-link=${TARGET_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE} -Wl,-rpath-link=$HOME/qt6/pi/lib")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(CMAKE_BUILD_RPATH ${TARGET_SYSROOT})

include(CMakeInitializeConfigs)

function(cmake_initialize_per_config_variable _PREFIX _DOCSTRING)
  if (_PREFIX MATCHES "CMAKE_(C|CXX|ASM)_FLAGS")
    set(CMAKE_${CMAKE_MATCH_1}_FLAGS_INIT "${QT_COMPILER_FLAGS}")
        
    foreach (config DEBUG RELEASE MINSIZEREL RELWITHDEBINFO)
      if (DEFINED QT_COMPILER_FLAGS_${config})
        set(CMAKE_${CMAKE_MATCH_1}_FLAGS_${config}_INIT "${QT_COMPILER_FLAGS_${config}}")
      endif()
    endforeach()
  endif()


  if (_PREFIX MATCHES "CMAKE_(SHARED|MODULE|EXE)_LINKER_FLAGS")
    foreach (config SHARED MODULE EXE)
      set(CMAKE_${config}_LINKER_FLAGS_INIT "${QT_LINKER_FLAGS}")
    endforeach()
  endif()

  _cmake_initialize_per_config_variable(${ARGV})
endfunction()

set(XCB_PATH_VARIABLE ${TARGET_SYSROOT})

set(GL_INC_DIR ${TARGET_SYSROOT}/usr/include)
set(GL_LIB_DIR ${TARGET_SYSROOT}:${TARGET_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/:${TARGET_SYSROOT}/usr:${TARGET_SYSROOT}/usr/lib)

set(EGL_INCLUDE_DIR ${GL_INC_DIR})
set(EGL_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/${TARGET_ARCHITECTURE}/libEGL.so)

set(OPENGL_INCLUDE_DIR ${GL_INC_DIR})
set(OPENGL_opengl_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/${TARGET_ARCHITECTURE}/libOpenGL.so)

set(GLESv2_INCLUDE_DIR ${GL_INC_DIR})
set(GLIB_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/${TARGET_ARCHITECTURE}/libGLESv2.so)

set(GLESv2_INCLUDE_DIR ${GL_INC_DIR})
set(GLESv2_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/${TARGET_ARCHITECTURE}/libGLESv2.so)

set(gbm_INCLUDE_DIR ${GL_INC_DIR})
set(gbm_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/${TARGET_ARCHITECTURE}/libgbm.so)

set(Libdrm_INCLUDE_DIR ${GL_INC_DIR})
set(Libdrm_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/${TARGET_ARCHITECTURE}/libdrm.so)

set(XCB_XCB_INCLUDE_DIR ${GL_INC_DIR})
set(XCB_XCB_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/${TARGET_ARCHITECTURE}/libxcb.so)

list(APPEND CMAKE_LIBRARY_PATH ${CMAKE_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE})
list(APPEND CMAKE_PREFIX_PATH "/usr/lib/${TARGET_ARCHITECTURE}/cmake")
```

Fix absolute symbolic links

```
cd $HOME/qt-cross-compilation-for-opi
wget https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py
chmod +x sysroot-relativelinks.py 
python3 sysroot-relativelinks.py opi-sysroot
```

Compile source code for opi.

```
cd $HOME/qt-cross-compilation-for-opi/qt6/pi-build
../src/qt-everywhere-src-6.8.0/configure \
    -opensource \
    -confirm-license \
    -release \
    -strip \
    -feature-relocatable \
    -rpath \
    -nomake examples \
    -nomake tests \
    -skip qtgamepad \
    -skip qtlottie  \
    -skip qtspeech \
    -skip qtlocation \
    -skip qtpurchasing \
    -skip virtualkeyboard \
    -skip qtwebengine \
    -skip qtwebchannel \
    -skip qtwebglplugin \
    -skip qtwebsockets \
    -skip qtwebview \
    -skip qt3d \
    -skip qtgraphs \
    -skip qtdoc \
    -skip qtquick3d \
    -skip qtquick3dphysics \
    -- \
    -DCMAKE_BUILD_TYPE=Release \
    -DINPUT_opengl=es2 \
    -DQT_BUILD_EXAMPLES=OFF \
    -DQT_BUILD_TESTS=OFF \
    -DQT_HOST_PATH=$HOME/qt-cross-compilation-for-opi/qt6/host \
    -DCMAKE_STAGING_PREFIX=$HOME/qt-cross-compilation-for-opi/qt6/pi \
    -DCMAKE_INSTALL_PREFIX=/usr/local/qt6 \
    -DCMAKE_TOOLCHAIN_FILE=$HOME/qt-cross-compilation-for-opi/qt6/toolchain.cmake \
    -DQT_QMAKE_TARGET_MKSPEC=devices/linux-rasp-pi4-aarch64 \
    -DQT_FEATURE_xcb=ON \
    -DFEATURE_xcb_xlib=ON \
    -DQT_FEATURE_xlib=ON
cmake --build . --parallel 4
cmake --install .
```

Back to the target create the corresponding Qt folder and grant full access:

```
cd /usr/local/
sudo mkdir qt6
sudo chmod -R 777 qt6
sudo chown orangepi:orangepi qt6
```


Send the binaries to opi. You should modify the following commands to your needs.

```
rsync -avz  $HOME/qt-cross-compilation-for-opi/qt6/pi/* orangepi@192.168.100.83:/usr/local/qt6

```

# Qt Creator configuration

Open QtCreator. Go to "Tools" -> "External" -> "Configure...".
Go to "Devices" -> "Devices" tab. Click on "Add" -> "Remote Linux Device". Provide all the necessary info:

<img width="540" height="384" alt="image" src="https://github.com/user-attachments/assets/13bbe115-8a7e-4dee-a5a9-390212894840" />

Click on "Next", then click on "Create New Key Pair".

<img width="720" height="376" alt="image" src="https://github.com/user-attachments/assets/1b802f96-f601-4ea3-8e3d-d940ef1cfca6" />

<img width="377" height="253" alt="image" src="https://github.com/user-attachments/assets/dda3a0a5-10af-4095-9884-d9573f7e7b5b" />

Then click on "Browse", choose the private key you've created. and click on "Deploy public key":

<img width="714" height="376" alt="image" src="https://github.com/user-attachments/assets/2ead6ef2-1f0a-4fed-9958-edc08d49677a" />

<img width="719" height="379" alt="image" src="https://github.com/user-attachments/assets/ca2e0f10-3d2a-4241-9e14-57a94be1ee12" />

Next click on "Next", then "Finish".

<img width="720" height="379" alt="image" src="https://github.com/user-attachments/assets/1d067eae-dec6-430d-8b39-dbed23c2ec11" />

After that the device test will be performed:

<img width="605" height="600" alt="image" src="https://github.com/user-attachments/assets/27f74a7a-580d-41ce-9514-ae949c185986" />

Finally you will see something like this:

<img width="841" height="602" alt="image" src="https://github.com/user-attachments/assets/f0857161-56b6-4bb5-adea-e7b0065dff11" />

Next select "Kits" -> "Qt versions" tab. Click on "Add" button and choose the qmake binary.

<img width="1227" height="792" alt="image" src="https://github.com/user-attachments/assets/eb7163b0-fbe6-4aa3-a17e-81ed2505e2b0" />


Next go to the "Compilers" tab, click on "Add"->"GCC" and choose the gcc cross-compiler.

<img width="1240" height="795" alt="image" src="https://github.com/user-attachments/assets/11c7a576-2582-4348-a666-2ed4a28abe7e" />


Next go to the "Kits" tab, click on "Add" button and fill the fields. 
1) Provide the name for the kit, e.g. "Orange Pi 3B Qt-6.8.0"
2) Set "Build Device" as "Desktop".
3) Set "Run Device" as "Remote Linux Device", "Device" as "Orange Pi 3B"
4) Set "Compiler" as "GCC-opi3b"
5) Set "Debugger" as system GDB on your host.
6) Provide the path to the sysroot.
7) Select "Qt Version" as "Qt 6.8.0 (Orange Pi 3B)"
8) Choose the CMake tool(you can choose the one that is already installed on your machine)
9) Change CMake configuration, add the following row:

```
-DCMAKE_TOOLCHAIN_FILE:UNINITIALIZED=/home/verchik/qt-cross-compilation-for-opi/qt6/pi/lib/cmake/Qt6/qt.toolchain.cmake
```

<img width="819" height="359" alt="image" src="https://github.com/user-attachments/assets/43fa07a5-2c7d-4c57-884c-f58f46821e90" />


You should get something like this:

<img width="1226" height="619" alt="image" src="https://github.com/user-attachments/assets/51f0bff5-6c37-4a7f-9e0f-6bebbba7da84" />

# Running test application

Clone this repo:

```
git clone https://github.com/vverenich/CrossCompileQtForOpi.git
```

Open the project from the repository using the QtCreator.

Open the project and choose the kit we've just created. 

<img width="1543" height="511" alt="image" src="https://github.com/user-attachments/assets/7520494a-48c1-447a-aebd-f5c0eb227fe8" />


Go to "Projects" -> "Orange Pi 3B Qt-6.8.0" -> "Run". 

1) Under "Alternate executable on device" make sure "Use this command" is checked. Provide the path to the executable on remote linux device.
2) Provide command line arguments, at least "--platform eglfs".

<img width="1829" height="294" alt="image" src="https://github.com/user-attachments/assets/d9b939df-b2d5-4deb-a263-46007c275eda" />

3) Under "Environment" section add the variable LD_LIBRARY_PATH=:/usr/local/qt6/lib/

<img width="1904" height="444" alt="image" src="https://github.com/user-attachments/assets/d3f1258e-21fa-40a6-a763-28f74c0502a4" />

This is the time to run the project. Right-click on project root folder -> "Run CMake", then "Build", then "Run".

<img width="1280" height="964" alt="image" src="https://github.com/user-attachments/assets/5dade4c9-0781-4050-b3cb-b24200bd6470" />



After that you can safely delete $HOME/qt-cross-compilation-for-opi/qt6/host-build/ and  $HOME/qt-cross-compilation-for-opi/qt6/pi-build/ folders.

