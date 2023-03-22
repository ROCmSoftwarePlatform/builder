ROCM_VERSION ?= 5.4
PACKAGE_NAME ?= magma-rocm5.4
PYTORCH_ROCM_ARCH ?= gfx906

DOCKER_RUN = docker run -it \
	-v $(shell git rev-parse --show-toplevel):/builder \
	-w /builder \
	-e ROCM_VERSION=${ROCM_VERSION} \
	-e PACKAGE_NAME=${PACKAGE_NAME} \
	-e PYTORCH_ROCM_ARCH="${PYTORCH_ROCM_ARCH}" \
	"${MANYLINUX_IMAGE}" \
 	/bin/bash magma/build_magma.sh	

.PHONY: all
all: magma-rocm5.4
all: magma-rocm5.3

.PHONY:
clean:
	$(RM) -r magma-*
	$(RM) -r output

.PHONY: magma-rocm5.4
magma-rocm5.4: ROCM_VERSION := 5.4
magma-rocm5.4: PACKAGE_NAME := magma-rocm5.4
magma-rocm5.4: PYTORCH_ROCM_ARCH := gfx906
magma-rocm5.4: MANYLINUX_IMAGE := pytorch/manylinux-builder:rocm5.4.2
magma-rocm5.4:
	$(DOCKER_RUN)

.PHONY: magma-rocm5.3
magma-rocm5.3: ROCM_VERSION := 5.3
magma-rocm5.3: PACKAGE_NAME := magma-rocm5.3
magma-rocm5.3: PYTORCH_ROCM_ARCH := gfx906
magma-rocm5.3: MANYLINUX_IMAGE := pytorch/manylinux-builder:rocm5.3
magma-rocm5.3:
	$(DOCKER_RUN)
