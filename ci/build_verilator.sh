#!/bin/bash
set -e

if [ -z ${NUM_JOBS} ]; then
    NUM_JOBS=1
fi

if [ -z ${VERILATOR_ROOT} ]; then
    VERILATOR_ROOT=submodules/verilator
fi

VERILATOR_REV=$(git --git-dir ${VERILATOR_ROOT}/.git rev-parse HEAD)
echo "Found Verilator rev ${VERILATOR_REV}"

CACHED_REV_FILE=${VERILATOR_CACHE}/rev.txt

# This is a little janky because if we install without VEILATOR_ROOT
# then we won't have driver.pl, etc. which VERILATOR_ROOT also points at
if [[ ! -f ${CACHED_REV_FILE} || \
      $(< ${CACHED_REV_FILE}) != ${VERILATOR_REV} ]]; then
    echo "Building Verilator"
# TODO -- cache only mode?
    cd ${VERILATOR_ROOT}
    autoconf && ./configure && make -j ${NUM_JOBS}
# Copy the Verilator build artifacts
    mkdir -p ${VERILATOR_CACHE}
    cp bin/*bin* ${VERILATOR_CACHE}
# Remember the Git revision
    echo ${VERILATOR_REV} > ${CACHED_REV_FILE}
else
    echo "Using cached Verilator"
    cd ${VERILATOR_ROOT}
# Create include/verilated_config.h and maybe other things
    autoconf && ./configure
    cp ${VERILATOR_CACHE}/* bin
fi
