#!/bin/bash

set -e

# Install conda - remove once have conda manylinux images instead
bash common/install_conda.sh
export PATH=/opt/conda/bin:$PATH

# Create the folder to be packaged
PACKAGE_DIR=magma/${PACKAGE_NAME}
PACKAGE_FILES=magma/package_files
mkdir ${PACKAGE_DIR}
cp ${PACKAGE_FILES}/build.sh ${PACKAGE_DIR}/build.sh
cp ${PACKAGE_FILES}/meta.yaml ${PACKAGE_DIR}/meta.yaml

# Conda prerequisites
conda install -yq conda-build conda-verify

# Conda build
(
    set -x
    conda build --output-folder magma/output "${PACKAGE_DIR}"
)
