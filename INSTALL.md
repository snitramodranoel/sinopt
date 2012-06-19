# Installing IPOPT on Gentoo Linux with MATLAB support
This document will guide you through the installation and configuration of IPOPT with MATLAB support on computers running Gentoo Linux. Other Linux flavors are also supported. However, you will have to adapt the instructions to fit your Linux distribution.

## 1) Pre-requisites
This document assumes that you have the following software package versions installed on your computer:

* GCC 4.3.4;
* MATLAB R2011a.

If your software versions are different, please refer to Mathworks documentation on [supported compiler and linker versions](http://www.mathworks.com/support/compilers/R2011a/glnxa64.html) for your MATLAB version.

## 2) Installing ATLAS

In order to provide more efficient linear algebra computations to IPOPT, it is highly recommended that you install optimized BLAS/LAPACK software. To install ATLAS, issue the following command as *root*:

``# emerge lapack-atlas``

## 3) Installing IPOPT

To install IPOPT, you must first configure and compile its supporting libraries and MATLAB interface. This document assumes that you are about to install IPOPT under `/opt/ipopt` and have MATLAB installed under `/opt/matlab`. If you are planning to install IPOPT system-wide, run the following commands as *root*:

``# cd $SINOPT_PATH/lib/vendor/ipopt-3.10.2``

where `$SINOPT_PATH` points to the base directory where SINopt source code is located. To configure the *Makefile*:

``./configure \
 --prefix=$IPOPT_INSTALL_PATH \
 --enable-static \
 --with-matlab-home=$MATLAB_PATH \
 CC=gcc-4.3.4 \
 CXX=g++-4.3.4 \
 F77=gfortran-4.3.4 \
 ADD_CFLAGS="-fPIC –fexceptions" \
 ADD_CXXFLAGS="-fPIC" \
 ADD_FFLAGS="-fPIC –fexceptions"``

After the `Makefile` is configured, build and install IPOPT:

``# make``

``# make install``

