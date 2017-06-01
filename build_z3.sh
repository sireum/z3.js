#!/bin/bash -e

if [ ! -e emsdk-portable ]; then
    rm -f emsdk-portable.tar.gz
    curl -O https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz
    tar xzf emsdk-portable.tar.gz
    rm -f emsdk-portable.tar.gz
    cd emsdk-portable
    ./emsdk update
    ./emsdk install latest
    ./emsdk activate latest
else
    cd emsdk-portable
    printf "Should I update the emsdk? (y/N): "
    answer=$(read)
    if [ "$answer" == "y" -o "$answer" == "Y" ]; then
	./emsdk update
	./emsdk install latest
	./emsdk activate latest
    fi
fi
source ./emsdk_env.sh

if [ ! -e z3 ]; then
    git clone https://github.com/Z3Prover/z3.git
fi
cd z3
git pull
if [ -e build ]; then
    mv build build-$(stat -f "%Sm" -t "%Y%m%dT%H%M%S" build | sed 's/[ :]/_/g' - | sed 's/\..*/ /g')
fi
alias c++=em++
alias g++=em++
alias ar=emar
alias cc=emcc
alias gcc=emcc
alias cmake=emcmake
alias configure=emconfigure
alias ranlib=emranlib
export CC=emcc
export CXX=em++
python scripts/mk_make.py --x86 --githash=$(git rev-parse HEAD) --staticlib
cd build
sed -i '.old' 's/AR=ar/AR=emar/g' config.mk
sed -i '.old' 's/EXE_EXT=/EXE_EXT=.emscripten.js/g' config.mk
sed -i '.old' 's/^\(LINK_EXTRA_FLAGS=.*\)/\1 -Oz -s DISABLE_EXCEPTION_CATCHING=0/g' config.mk
emmake make
#cp z3.emscripten.js* ../../../compiled/
