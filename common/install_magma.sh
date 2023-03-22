#!/usr/bin/env bash

#!/bin/bash

set -ex

function do_install() {
    magma_archive_path=$1
    magma_archive="$(basename "$magma_archive_path")"
    rocm_path="/opt/rocm/"
    tmp_dir=$(mktemp -d)
    cp $magma_archive_path $tmp_dir
    pushd ${tmp_dir}
    tar -xvf "${magma_archive}" $tmp_dir
    mkdir -p "${rocm_path}/magma"
    mv $tmp_dir/include "${rocm_path}/magma/include"
    mv $tmp_dir/lib "${rocm_path}/magma/lib"
    popd
}

do_install $1
