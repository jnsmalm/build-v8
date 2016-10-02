#!/bin/bash

lowercase() {
  echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

OS=`lowercase \`uname\``
V8VERSION="4.9.385.33"
BUILD="1"
ARCH=`getconf LONG_BIT`

git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
PATH=`pwd`/depot_tools:"$PATH"

gclient && fetch v8 && cd v8
git checkout tags/$V8VERSION
gclient sync --with_branch_heads

sed -i '' "s/'CLANG_CXX_LANGUAGE_STANDARD': 'gnu++0x'/& ,'CLANG_CXX_LIBRARY': 'libc++'/" build/standalone.gypi
sed -i '' "/cctest.gyp/d" build/all.gyp
sed -i '' "/unittests.gyp/d" build/all.gyp

make i18nsupport=off native && cd ..

if [[ ! -d dist ]]; then
  mkdir dist
fi
cp v8/out/native/*.a ./dist
cd dist && tar -zcvf ../libv8-$V8VERSION.$BUILD-$OS-${ARCH}bit.tar.gz . && cd ..