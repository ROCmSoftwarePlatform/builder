# Magma

## Building

Look in the `Makefile` for available targets to build. To build any target, for example `magma-rocm5.4`, run

```
make magma-rocm5.4
```

This should spawn a manylinux docker image. Within the docker image, it should run `build_magma.sh` with the correct environment variables set, which should package the necessary files with `conda build`.

More specifically, `build_magma.sh` copies over the relevant files from the `package_files` directory depending on the CUDA version. More information on conda-build can be found [here](https://docs.conda.io/projects/conda-build/en/latest/concepts/recipe.html).

Outputted binaries should be in the `output` folder.

## Pushing

Once you have built the binaries push them with:

```
anaconda upload -u pytorch --force output/*/magma-rocm*.bz2
```

If you do not have upload permissions, please ping @jithunair or @jataylo to gain access

## New versions

New ROCm versions can be added by creating a new make target with the next desired version. For ROCm version n.n.n, the target should be named `magma-rocmn.n`.

Make sure to edit the appropriate environment variables (e.g., ROCM_VERSION, PYTORCH_ROCM_ARCH) in the `Makefile` accordingly. Remember also to check `build_magma.sh` to ensure the logic for copying over the files remains correct.

New patches can be added by editing `Makefile`, `build_magma.sh`, and `package_files/meta.yaml`.
