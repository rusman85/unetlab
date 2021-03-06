#!/bin/bash
CONTROL="/usr/src/unetlab/debian/qemu_control.template"
SRC_DIR="/usr/src/unetlab"
ARCH=$(cat ${CONTROL} | grep Architecture | cut -d: -f2 | sed 's/ //')
BUILD_DIR="/build"
CONTROL_DIR="$(mktemp -dt)"
DATA_DIR="$(mktemp -dt)"
VERSION="$(cat ${SRC_DIR}/VERSION | cut -d- -f1)"
RELEASE="$(cat ${SRC_DIR}/VERSION | cut -d- -f2)"

cat ${CONTROL} | sed "s/%VERSION%/${VERSION}/" | sed "s/%RELEASE%/${RELEASE}/" > ${CONTROL_DIR}/control

# QEMU
mkdir -p ${DATA_DIR}/opt
cp -a /opt/qemu ${DATA_DIR}/opt
cp -a /opt/qemu-1.3.1 ${DATA_DIR}/opt
cp -a /opt/qemu-2.0.2 ${DATA_DIR}/opt
cp -a /opt/qemu-2.1.2-esxi ${DATA_DIR}/opt

# Building the package
cd ${DATA_DIR}
tar czf data.tar.gz *
find -type f -exec md5sum {} \; >> ${CONTROL_DIR}/md5sums
echo 2.0 > ${CONTROL_DIR}/debian-binary
cd ${CONTROL_DIR}
tar czf control.tar.gz md5sums control
cd ${SRC_DIR}
mkdir -p ${BUILD_DIR}/apt/pool/trusty/u/unetlab-qemu
ar -cr ${BUILD_DIR}/apt/pool/trusty/u/unetlab-qemu/unetlab-qemu_${VERSION}-${RELEASE}_${ARCH}.deb ${CONTROL_DIR}/debian-binary ${CONTROL_DIR}/control.tar.gz ${DATA_DIR}/data.tar.gz
rm -rf ${CONTROL_DIR} ${DATA_DIR}
