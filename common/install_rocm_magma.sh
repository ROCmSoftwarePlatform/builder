#!/bin/bash

set -ex

function install_magma_source() {
    # TODO upstream differences from this file is into the (eventual) one in pytorch
    # - (1) check for static lib mkl
    # - (2) MKLROOT as env var

    # TODO (2)
    MKLROOT=${MKLROOT:-/opt/intel}

    # "install" hipMAGMA into /opt/rocm/magma by copying after build
    git clone https://bitbucket.org/icl/magma.git
    pushd magma
    # fix for magma_queue memory leak issue
    git checkout c62d700d880c7283b33fb1d615d62fc9c7f7ca21
    cp make.inc-examples/make.inc.hip-gcc-mkl make.inc
    echo 'LIBDIR += -L$(MKLROOT)/lib' >> make.inc
    # TODO (1)
    if [[ -f "${MKLROOT}/lib/libmkl_core.a" ]]; then
        echo 'LIB = -Wl,--start-group -lmkl_gf_lp64 -lmkl_gnu_thread -lmkl_core -Wl,--end-group -lpthread -lstdc++ -lm -lgomp -lhipblas -lhipsparse' >> make.inc
    fi
    echo 'LIB += -Wl,--enable-new-dtags -Wl,--rpath,/opt/rocm/lib -Wl,--rpath,$(MKLROOT)/lib -Wl,--rpath,/opt/rocm/magma/lib -ldl' >> make.inc
    echo 'DEVCCFLAGS += --gpu-max-threads-per-block=256' >> make.inc
    export PATH="${PATH}:/opt/rocm/bin"
    if [[ -n "$PYTORCH_ROCM_ARCH" ]]; then
    amdgpu_targets=`echo $PYTORCH_ROCM_ARCH | sed 's/;/ /g'`
    else
    amdgpu_targets=`rocm_agent_enumerator | grep -v gfx000 | sort -u | xargs`
    fi
    for arch in $amdgpu_targets; do
    echo "DEVCCFLAGS += --amdgpu-target=$arch" >> make.inc
    done
    # hipcc with openmp flag may cause isnan() on __device__ not to be found; depending on context, compiler may attempt to match with host definition
    sed -i 's/^FOPENMP/#FOPENMP/g' make.inc
    make -f make.gen.hipMAGMA -j $(nproc)
    LANG=C.UTF-8 make lib/libmagma.so -j $(nproc) MKLROOT="${MKLROOT}"
    make testing/testing_dgemm -j $(nproc) MKLROOT="${MKLROOT}"
    popd
    mkdir -p /opt/rocm/magma
    mv magma/include /opt/rocm/magma
    mv magma/lib /opt/rocm/magma
    rm -rf magma
}

function install_magma_package() {

    MAGMA_VERSION="2.6.2"
    rocm_path="/opt/rocm"
    tmp_dir=$(mktemp -d)
    pushd ${tmp_dir}
    wget --no-check-certificate -q $MAGMA_PACKAGE_SOURCE
    tar -xf *.tar*
    mkdir -p "${rocm_path}/magma"

    if [ -e "$tmp_dir/magma/include" ]; then
        mv "$tmp_dir/magma/include" "${rocm_path}/magma/include"
        echo "Successfully installed MAGMA include files to ${rocm_path}/magma/include"
    else
        echo "Error: MAGMA include files not found in $tmp_dir/magma/include"
    fi

    if [ -e "$tmp_dir/magma/lib/" ]; then
        mv "$tmp_dir/magma/lib/" "${rocm_path}/magma/lib"
        echo "Successfully installed MAGMA library files to ${rocm_path}/magma/lib"
    else
        echo "Error: MAGMA library file not found in $tmp_dir/magma/lib"
    fi

    if [ ! -d "${rocm_path}/magma" ]; then
        echo "Error: MAGMA installation failed"
        exit 1
    fi

    popd
    rm -rf $tmp_dir
}

if [ -z "$MAGMA_PACKAGE_SOURCE" ]; then
    echo "MAGMA_PACKAGE_SOURCE is not set, building magma from source"
    install_magma_source
else
    echo "MAGMA_PACKAGE_SOURCE is set, installing magma from source"
    install_magma_package
fi
