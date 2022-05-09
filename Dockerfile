FROM ubuntu:16.04

#basic containert
ADD . /
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y
RUN apt-get install wget -y
RUN apt-get install build-essential -y
RUN apt-get install git -y
RUN apt-get install python -y


###build gcc 
WORKDIR /
RUN wget https://ftp.gnu.org/gnu/gcc/gcc-7.3.0/gcc-7.3.0.tar.gz
RUN tar -xvf gcc-7.3.0.tar.gz
WORKDIR /gcc-7.3.0
RUN mkdir bin
RUN ./contrib/download_prerequisites
RUN ./configure --enable-languages=c,c++,fortran,objc,obj-c++ --prefix=/gcc_compiled/bin --disable-multilib
RUN make -j18
RUN make install 
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/gcc_compiled/bin/lib64 #needs atention
ENV PATH=$PATH:/gcc_compiled/bin/lib64


#valgrind part
WORKDIR /
RUN wget ftp://sourceware.org/pub/valgrind/valgrind-3.13.0.tar.bz2
RUN tar -xvf valgrind-3.13.0.tar.bz2
WORKDIR /valgrind-3.13.0
RUN mkdir bin
RUN ./configure CC=/gcc_compiled/bin/bin/gcc FC=/gcc_compiled/bin/bin/gfortran --prefix=/valgrind/bin
RUN make -j18
RUN make install



###openMPI part
WORKDIR /
RUN wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.2.tar.gz
RUN tar -xvf openmpi-3.1.2.tar.gz
WORKDIR /openmpi-3.1.2
RUN mkdir bin
RUN ./configure CC=/gcc_compiled/bin/bin/gcc FC=/gcc_compiled/bin/bin/gfortran --prefix=/mpi_compiled/openmpi-3.1.2/bin
RUN make -j18
RUN make install


###openBLAS part
WORKDIR /
RUN wget https://github.com/xianyi/OpenBLAS/archive/refs/tags/v0.3.10.tar.gz
RUN tar -xvf v0.3.10.tar.gz
WORKDIR /OpenBLAS-0.3.10
RUN make CC=/mpi_compiled/openmpi-3.1.2/bin/mpicc  FC=/mpi_compiled/openmpi-3.1.2/bin/mpif90      NO_LAPACKE=1 PREFIX=/open_blas/bin  HOSTCC=gcc  NO_STATIC=1 DYNAMIC_ARCH=1 NO_AFFINITY=1 USE_OPENMP=1
RUN make PREFIX=/open_blas/ install

###petsc part
WORKDIR /
RUN wget https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-3.4.4.tar.gz
RUN tar -xvf petsc-lite-3.4.4.tar.gz
WORKDIR /petsc-3.4.4
RUN ./configure --with-x=0 --with-mpi-dir=/mpi_compiled/openmpi-3.1.2 --with-mpiexec=/mpi_compiled/openmpi-3.1.2/bin/mpirun --with-blas-lib=/open_blas/lib/libopenblas.a --with-lapack-lib=/open_blas/lib/libopenblas.a --known-mpi-shared-libraries=0 --with-shared-libraries=0 --with-valgrind=yes –with-valgrind-dir=/valgrind/bin/bin/
RUN make PETSC_DIR=/petsc-3.4.4 PETSC_ARCH=arch-linux2-c-debug all
ENV PETSC_DIR=/petsc-3.4.4
ENV LBM_DIR=/taxila_folder/taxila-font-Mar14

###taxila part
WORKDIR /
WORKDIR /taxila_folder/taxila-font-Mar14/src/lbm
RUN make

###set envs
#ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH
#ENV PATH $PATH
#ENV PETSC_DIR $PETSC_DIR
#ENV LBM_DIR $LBM_DIR


WORKDIR /
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:mypassword' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
EXPOSE 6666
CMD ["/usr/sbin/sshd", "-D"]


