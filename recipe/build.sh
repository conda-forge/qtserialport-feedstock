#!/bin/bash
set -ex

[[ -d build ]] || mkdir build
cd build/

test ! -f ${PREFIX}/lib/libQt5SerialPort${SHLIB_EXT} || (
   echo libQt5SerialPort already exists this package does not need to be built && exit 1
)
if [[ ${HOST} =~ .*linux.* ]]; then
  # Missing g++ workaround.
  ln -s ${GXX} g++ || true
  chmod +x g++
  export PATH=${PWD}:${PATH}
fi

# Need to specify these QMAKE variables because of build environment residue
# in qt mkspecs referencing "qt_1548879054661"
# Report: https://github.com/conda-forge/qtlocation-feedstock/pull/3#issuecomment-466278804
# Fix PR: https://github.com/conda-forge/qt-feedstock/pull/97
qmake \
    QMAKE_CC=${CC} \
    QMAKE_CXX=${CXX} \
    QMAKE_LINK=${CXX} \
    QMAKE_RANLIB=${RANLIB} \
    QMAKE_OBJDUMP=${OBJDUMP} \
    QMAKE_STRIP=${STRIP} \
    QMAKE_AR="${AR} cqs" \
    ${SRC_DIR}

make -j${CPU_COUNT}
make check
make install
