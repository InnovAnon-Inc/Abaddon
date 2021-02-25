FROM innovanon/void-base as bootstrap
#FROM innovanon/doom-base as bootstrap
USER root

#RUN for k in $(seq 3) ; do \
#      sleep 91             \
#   && xbps-install -Suy    \
#   || continue             \
#    ; exit 0               \
#  ; done                   \
# && exit 2
#RUN for k in $(seq 3) ; do                                                                   \
#      sleep 91                                                                               \
#   && xbps-install   -y gettext gettext-devel gettext-libs gperf pkg-config po4a texinfo zip \
#   || continue                                                                               \
#    ; exit 0                                                                                 \
#  ; done                                                                                     \
# && exit 2
COPY ./update.sh ./
RUN  ./update.sh

FROM bootstrap as builder

ARG CPPFLAGS
ARG   CFLAGS
ARG CXXFLAGS
ARG  LDFLAGS

#ENV CHOST=x86_64-linux-gnu

ENV CPPFLAGS="$CPPFLAGS"
ENV   CFLAGS="$CFLAGS"
ENV CXXFLAGS="$CXXFLAGS"
ENV  LDFLAGS="$LDFLAGS"

ENV PREFIX=/usr/local
#ENV PREFIX=/opt/cpuminer
ENV CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
ENV CPATH="$PREFIX/incude:$CPATH"
ENV    C_INCLUDE_PATH="$PREFIX/include:$C_INCLUDE_PATH"
ENV OBJC_INCLUDE_PATH="$PREFIX/include:$OBJC_INCLUDE_PATH"

ENV LDFLAGS="-L$PREFIX/lib $LDFLAGS"
ENV    LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
ENV LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
ENV     LD_RUN_PATH="$PREFIX/lib:$LD_RUN_PATH"

ENV PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PKG_CONFIG_LIBDIR"
ENV PKG_CONFIG_PATH="$PREFIX/share/pkgconfig:$PKG_CONFIG_LIBDIR:$PKG_CONFIG_PATH"

ARG ARCH=native
ENV ARCH="$ARCH"

#ENV CPPFLAGS="-DUSE_ASM $CPPFLAGS"
ENV   CFLAGS="-march=$ARCH -mtune=$ARCH $CFLAGS"

# PGO
##ENV   CFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -pg -fprofile-abs-path -fprofile-dir=/var/cpuminer  $CFLAGS"
##ENV  LDFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -pg -fprofile-abs-path -fprofile-dir=/var/cpuminer $LDFLAGS"
#ENV   CFLAGS="-pg -fprofile-abs-path -fprofile-generate=/var/cpuminer  $CFLAGS"
#ENV  LDFLAGS="-pg -fprofile-abs-path -fprofile-generate=/var/cpuminer $LDFLAGS"

# Debug
#ENV CPPFLAGS="-DNDEBUG $CPPFLAGS"
ENV   CFLAGS="-Ofast -g0 $CFLAGS"

# Static
#ENV  LDFLAGS="$LDFLAGS -static -static-libgcc -static-libstdc++"

# LTO
ENV   CFLAGS="-fuse-linker-plugin -flto $CFLAGS"
ENV  LDFLAGS="-fuse-linker-plugin -flto $LDFLAGS"
##ENV   CFLAGS="-fuse-linker-plugin -flto -ffat-lto-objects $CFLAGS"
##ENV  LDFLAGS="-fuse-linker-plugin -flto -ffat-lto-objects $LDFLAGS"

# Dead Code Strip
ENV   CFLAGS="-ffunction-sections -fdata-sections $CFLAGS"
ENV  LDFLAGS="-Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections $LDFLAGS"
##ENV  LDFLAGS="-Wl,-Bsymbolic -Wl,--gc-sections $LDFLAGS"

# Optimize
#ENV   CLANGFLAGS="-ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS"
#ENV       CFLAGS="-fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CLANGFLAGS"
ENV CFLAGS="-fmerge-all-constants $CFLAGS"

ENV CXXFLAGS="$CXXFLAGS $CFLAGS"

WORKDIR /tmp/
#RUN for k in $(seq 5) ; do                                               \
#      sleep 91                                                           \
# && git clone --depth=1 --recursive https://github.com/madler/zlib.git \
#   && break                                                              \
#   || (( k != 5 ))                                                       \
#  ; done
#RUN cd zlib                           \
# && ./configure --prefix=$PREFIX      \
#      --const --static --64           \
# && make                              \
# && make install                      \
# && git reset --hard                  \
# && git clean -fdx                    \
# && git clean -fdx                    \
# && cd ..                             \
# && ldconfig
#RUN for k in $(seq 5) ; do                                               \
#      sleep 91                                                           \
# && git clone --depth=1 --recursive https://github.com/glennrp/libpng.git \
#   && break                                                              \
#   || (( k != 5 ))                                                       \
#  ; done
#RUN cd libpng                         \
# && autoreconf -fi                    \
# && ./configure --prefix=$PREFIX      \
#      --enable-static                 \
#      --disable-shared                \
#	CPPFLAGS="$CPPFLAGS"                 \
#	CXXFLAGS="$CXXFLAGS"                 \
#	CFLAGS="$CFLAGS"                     \
#	LDFLAGS="$LDFLAGS"                   \
#        CPATH="$CPATH"                                \
#        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
#        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
#        LIBRARY_PATH="$LIBRARY_PATH"                  \
#        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
#        LD_RUN_PATH="$LD_RUN_PATH"                    \
#        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
#        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
#        CC="$CC"                             \
#        CXX="$CXX"                           \
#        FC="$FC"                             \
#        NM="$NM"                             \
#        AR="$AR"                             \
#        RANLIB="$RANLIB"                     \
#        STRIP="$STRIP"                       \
# && make                              \
# && make install                      \
# && git reset --hard                  \
# && git clean -fdx                    \
# && git clean -fdx                    \
# && cd ..                             \
# && ldconfig
#RUN for k in $(seq 5) ; do                                               \
#      sleep 91                                                           \
# && git clone --depth=1 --recursive https://github.com/libjpeg-turbo/libjpeg-turbo.git \
#   && break                                                              \
#   || (( k != 5 ))                                                       \
#  ; done
#RUN cd libjpeg-turbo                     \
# && mkdir -v build                       \
# && cd       build                       \
# && cmake -G'Unix Makefiles'             \
#      -DCMAKE_BUILD_TYPE=Release         \
#      -DCMAKE_C_FLAGS="$CFLAGS"          \
#      -DCMAKE_CXX_FLAGS="$CXXFLAGS"      \
#      -DCMAKE_FIND_ROOT_PATH=$PREFIX     \
#      -DCMAKE_INSTALL_PREFIX=$PREFIX     \
#      ..                                 \
# && make                                 \
# && make install                         \
# && cd ..                                \
# && git reset --hard                     \
# && git clean -fdx                       \
# && git clean -fdx                       \
# && cd ..                                \
# && ldconfig
#RUN for k in $(seq 5) ; do                                               \
#      sleep 91                                                           \
# && git clone --depth=1 --recursive https://github.com/libexpat/libexpat.git \
#   && break                                                              \
#   || (( k != 5 ))                                                       \
#  ; done
#RUN cd libexpat/expat                    \
# && ./buildconf.sh                       \
# && ./configure --prefix=$PREFIX         \
#      --enable-static                    \
#      --disable-shared                   \
#	CPPFLAGS="$CPPFLAGS"                 \
#	CXXFLAGS="$CXXFLAGS"                 \
#	CFLAGS="$CFLAGS"                     \
#	LDFLAGS="$LDFLAGS"                   \
#        CPATH="$CPATH"                                \
#        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
#        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
#        LIBRARY_PATH="$LIBRARY_PATH"                  \
#        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
#        LD_RUN_PATH="$LD_RUN_PATH"                    \
#        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
#        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
#        CC="$CC"                             \
#        CXX="$CXX"                           \
#        FC="$FC"                             \
#        NM="$NM"                             \
#        AR="$AR"                             \
#        RANLIB="$RANLIB"                     \
#        STRIP="$STRIP"                       \
# && make                                 \
# && make install                         \
# && cd ..                                \
# && git reset --hard                     \
# && git clean -fdx                       \
# && git clean -fdx                       \
# && cd ..                                \
# && ldconfig
#RUN for k in $(seq 5) ; do                                               \
#      sleep 91                                                           \
# && git clone --depth=1 --recursive https://github.com/freetype/freetype.git \
#   && break                                                              \
#   || (( k != 5 ))                                                       \
#  ; done
#RUN cd freetype                          \
# && sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg \
# && sed -r  "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:"       \
#         -i include/freetype/config/ftoption.h         \
# && ./autogen.sh                         \
# && ./configure --help                   \
# && ./configure --prefix=$PREFIX         \
#      --enable-static                    \
#      --disable-shared                   \
#      FREETYPE_LIBS=$PREFIX/lib          \
#	CPPFLAGS="$CPPFLAGS"                 \
#	CXXFLAGS="$CXXFLAGS"                 \
#	CFLAGS="$CFLAGS"                     \
#	LDFLAGS="$LDFLAGS"                   \
#        CPATH="$CPATH"                                \
#        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
#        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
#        LIBRARY_PATH="$LIBRARY_PATH"                  \
#        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
#        LD_RUN_PATH="$LD_RUN_PATH"                    \
#        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
#        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
#        CC="$CC"                             \
#        CXX="$CXX"                           \
#        FC="$FC"                             \
#        NM="$NM"                             \
#        AR="$AR"                             \
#        RANLIB="$RANLIB"                     \
#        STRIP="$STRIP"                       \
# && make                                 \
# && make install                         \
# && git reset --hard                     \
# && git clean -fdx                       \
# && git clean -fdx                       \
# && cd ..                                \
# && ldconfig
##RUN for k in $(seq 5) ; do                                               \
##      sleep 91                                                           \
## && git clone --depth=1 --recursive https://github.com/freedesktop/fontconfig.git \
##   && break                                                              \
##   || (( k != 5 ))                                                       \
##  ; done
##RUN cd fontconfig                        \
## && rm -f src/fcobjshash.h               \
## && ./autogen.sh --prefix=$PREFIX        \
##      --enable-static                    \
##      --disable-shared                   \
##      --disable-docs                     \
##      FREETYPE_LIBS=$PREFIX/lib          \
##	CPPFLAGS="$CPPFLAGS"                 \
##	CXXFLAGS="$CXXFLAGS"                 \
##	CFLAGS="$CFLAGS"                     \
##	LDFLAGS="$LDFLAGS"                   \
##        CPATH="$CPATH"                                \
##        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
##        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
##        LIBRARY_PATH="$LIBRARY_PATH"                  \
##        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
##        LD_RUN_PATH="$LD_RUN_PATH"                    \
##        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
##        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
##        CC="$CC"                             \
##        CXX="$CXX"                           \
##        FC="$FC"                             \
##        NM="$NM"                             \
##        AR="$AR"                             \
##        RANLIB="$RANLIB"                     \
##        STRIP="$STRIP"                       \
## && make                                 \
## && make install                         \
## && git reset --hard                     \
## && git clean -fdx                       \
## && git clean -fdx                       \
## && cd ..                                \
## && ldconfig || :
#RUN for k in $(seq 5) ; do                                               \
#      sleep 91                                                           \
# && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/util/macros.git util-macros \
#   && break                                                              \
#   || (( k != 5 ))                                                       \
#  ; done
#RUN cd util-macros                       \
# && ./autogen.sh                         \
# && ./configure --prefix=$PREFIX         \
#      --enable-static                    \
#      --disable-shared                   \
#	CPPFLAGS="$CPPFLAGS"                 \
#	CXXFLAGS="$CXXFLAGS"                 \
#	CFLAGS="$CFLAGS"                     \
#	LDFLAGS="$LDFLAGS"                   \
#        CPATH="$CPATH"                                \
#        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
#        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
#        LIBRARY_PATH="$LIBRARY_PATH"                  \
#        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
#        LD_RUN_PATH="$LD_RUN_PATH"                    \
#        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
#        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
#        CC="$CC"                             \
#        CXX="$CXX"                           \
#        FC="$FC"                             \
#        NM="$NM"                             \
#        AR="$AR"                             \
#        RANLIB="$RANLIB"                     \
#        STRIP="$STRIP"                       \
# && make install                         \
# && git reset --hard                     \
# && git clean -fdx                       \
# && git clean -fdx                       \
# && cd ..                                \
# && ldconfig
##RUN for k in $(seq 5) ; do                                               \
##      sleep 91                                                           \
## && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/proto/xorgproto.git \
##   && break                                                              \
##   || (( k != 5 ))                                                       \
##  ; done
##RUN cd xorgproto                         \
## && ./autogen.sh                         \
## && ./configure --prefix=$PREFIX         \
##      --enable-static                    \
##      --disable-shared                   \
##      -Dlegacy=true                      \
##	CPPFLAGS="$CPPFLAGS"                 \
##	CXXFLAGS="$CXXFLAGS"                 \
##	CFLAGS="$CFLAGS"                     \
##	LDFLAGS="$LDFLAGS"                   \
##        CPATH="$CPATH"                                \
##        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
##        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
##        LIBRARY_PATH="$LIBRARY_PATH"                  \
##        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
##        LD_RUN_PATH="$LD_RUN_PATH"                    \
##        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
##        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
##        CC="$CC"                             \
##        CXX="$CXX"                           \
##        FC="$FC"                             \
##        NM="$NM"                             \
##        AR="$AR"                             \
##        RANLIB="$RANLIB"                     \
##        STRIP="$STRIP"                       \
## && make install                         \
## && git reset --hard                     \
## && git clean -fdx                       \
## && git clean -fdx                       \
## && cd ..                                \
## && ldconfig || :
##RUN for k in $(seq 5) ; do                                               \
##      sleep 91                                                           \
## && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXau.git \
##   && break                                                              \
##   || (( k != 5 ))                                                       \
##  ; done
##RUN cd libXau                            \
## && ./autogen.sh                         \
## && ./configure --prefix=$PREFIX         \
##      --enable-static                    \
##      --disable-shared                   \
##	CPPFLAGS="$CPPFLAGS"                 \
##	CXXFLAGS="$CXXFLAGS"                 \
##	CFLAGS="$CFLAGS"                     \
##	LDFLAGS="$LDFLAGS"                   \
##        CPATH="$CPATH"                                \
##        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
##        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
##        LIBRARY_PATH="$LIBRARY_PATH"                  \
##        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
##        LD_RUN_PATH="$LD_RUN_PATH"                    \
##        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
##        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
##        CC="$CC"                             \
##        CXX="$CXX"                           \
##        FC="$FC"                             \
##        NM="$NM"                             \
##        AR="$AR"                             \
##        RANLIB="$RANLIB"                     \
##        STRIP="$STRIP"                       \
## && make                                 \
## && make install                         \
## && git reset --hard                     \
## && git clean -fdx                       \
## && git clean -fdx                       \
## && cd ..                                \
## && ldconfig || :
#RUN for k in $(seq 5) ; do                                               \
#      sleep 91                                                           \
# && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/proto/xcbproto.git \
#   && break                                                              \
#   || (( k != 5 ))                                                       \
#  ; done
#RUN cd xcbproto                          \
# && ls -ltra \
# && autoreconf -fi \
# && ./configure --prefix=$PREFIX         \
#      --enable-static                    \
#      --disable-shared                   \
#	CPPFLAGS="$CPPFLAGS"                 \
#	CXXFLAGS="$CXXFLAGS"                 \
#	CFLAGS="$CFLAGS"                     \
#	LDFLAGS="$LDFLAGS"                   \
#        CPATH="$CPATH"                                \
#        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
#        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
#        LIBRARY_PATH="$LIBRARY_PATH"                  \
#        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
#        LD_RUN_PATH="$LD_RUN_PATH"                    \
#        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
#        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
#        CC="$CC"                             \
#        CXX="$CXX"                           \
#        FC="$FC"                             \
#        NM="$NM"                             \
#        AR="$AR"                             \
#        RANLIB="$RANLIB"                     \
#        STRIP="$STRIP"                       \
# && make install                         \
# && git reset --hard                     \
# && git clean -fdx                       \
# && git clean -fdx                       \
# && cd ..                                \
# && ldconfig
##RUN for k in $(seq 5) ; do                                               \
##      sleep 91                                                           \
## && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libxcb.git \
##   && break                                                              \
##   || (( k != 5 ))                                                       \
##  ; done
##RUN cd libxcb                            \
## && autoreconf -fi \
## && CFLAGS="-Wno-error=format-extra-args $CFLAGS" \
##    ./configure --prefix=$PREFIX         \
##      --enable-static                    \
##      --disable-shared                   \
##      --without-doxygen                  \
##	CPPFLAGS="$CPPFLAGS"                 \
##	CXXFLAGS="$CXXFLAGS"                 \
##	CFLAGS="$CFLAGS"                     \
##	LDFLAGS="$LDFLAGS"                   \
##        CPATH="$CPATH"                                \
##        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
##        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
##        LIBRARY_PATH="$LIBRARY_PATH"                  \
##        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
##        LD_RUN_PATH="$LD_RUN_PATH"                    \
##        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
##        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
##        CC="$CC"                             \
##        CXX="$CXX"                           \
##        FC="$FC"                             \
##        NM="$NM"                             \
##        AR="$AR"                             \
##        RANLIB="$RANLIB"                     \
##        STRIP="$STRIP"                       \
## && make                                 \
## && make install                         \
## && git reset --hard                     \
## && git clean -fdx                       \
## && git clean -fdx                       \
## && cd ..                                \
## && ldconfig || :
##RUN for k in $(seq 5) ; do                                               \
##      sleep 91                                                           \
## && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libX11.git \
##   && break                                                              \
##   || (( k != 5 ))                                                       \
##  ; done
##RUN cd libX11                            \
## && autoreconf -fi \
## && ./configure --prefix=$PREFIX         \
##      --enable-static                    \
##      --disable-shared                   \
##	CPPFLAGS="$CPPFLAGS"                 \
##	CXXFLAGS="$CXXFLAGS"                 \
##	CFLAGS="$CFLAGS"                     \
##	LDFLAGS="$LDFLAGS"                   \
##        CPATH="$CPATH"                                \
##        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
##        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
##        LIBRARY_PATH="$LIBRARY_PATH"                  \
##        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
##        LD_RUN_PATH="$LD_RUN_PATH"                    \
##        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
##        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
##        CC="$CC"                             \
##        CXX="$CXX"                           \
##        FC="$FC"                             \
##        NM="$NM"                             \
##        AR="$AR"                             \
##        RANLIB="$RANLIB"                     \
##        STRIP="$STRIP"                       \
## && make                                 \
## && make install                         \
## && git reset --hard                     \
## && git clean -fdx                       \
## && git clean -fdx                       \
## && cd ..                                \
## && ldconfig || :
##RUN for k in $(seq 5) ; do                                               \
##      sleep 91                                                           \
## && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXext.git \
##   && break                                                              \
##   || (( k != 5 ))                                                       \
##  ; done
##RUN cd libXext                            \
## && autoreconf -fi \
## && ./configure --prefix=$PREFIX         \
##      --enable-static                    \
##      --disable-shared                   \
##	CPPFLAGS="$CPPFLAGS"                 \
##	CXXFLAGS="$CXXFLAGS"                 \
##	CFLAGS="$CFLAGS"                     \
##	LDFLAGS="$LDFLAGS"                   \
##        CPATH="$CPATH"                                \
##        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
##        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
##        LIBRARY_PATH="$LIBRARY_PATH"                  \
##        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
##        LD_RUN_PATH="$LD_RUN_PATH"                    \
##        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
##        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
##        CC="$CC"                             \
##        CXX="$CXX"                           \
##        FC="$FC"                             \
##        NM="$NM"                             \
##        AR="$AR"                             \
##        RANLIB="$RANLIB"                     \
##        STRIP="$STRIP"                       \
## && make                                 \
## && make install                         \
## && git reset --hard                     \
## && git clean -fdx                       \
## && git clean -fdx                       \
## && cd ..                                \
## && ldconfig || :
##RUN for k in $(seq 5) ; do                                               \
##      sleep 91                                                           \
## && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXfixes.git \
##   && break                                                              \
##   || (( k != 5 ))                                                       \
##  ; done
##RUN cd libXfixes                            \
## && autoreconf -fi \
## && ./configure --prefix=$PREFIX         \
##      --enable-static                    \
##      --disable-shared                   \
##	CPPFLAGS="$CPPFLAGS"                 \
##	CXXFLAGS="$CXXFLAGS"                 \
##	CFLAGS="$CFLAGS"                     \
##	LDFLAGS="$LDFLAGS"                   \
##        CPATH="$CPATH"                                \
##        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
##        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
##        LIBRARY_PATH="$LIBRARY_PATH"                  \
##        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
##        LD_RUN_PATH="$LD_RUN_PATH"                    \
##        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
##        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
##        CC="$CC"                             \
##        CXX="$CXX"                           \
##        FC="$FC"                             \
##        NM="$NM"                             \
##        AR="$AR"                             \
##        RANLIB="$RANLIB"                     \
##        STRIP="$STRIP"                       \
## && make                                 \
## && make install                         \
## && git reset --hard                     \
## && git clean -fdx                       \
## && git clean -fdx                       \
## && cd ..                                \
## && ldconfig || :
##RUN for k in $(seq 5) ; do                                               \
##      sleep 91                                                           \
## && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXrender.git \
##   && break                                                              \
##   || (( k != 5 ))                                                       \
##  ; done
##RUN cd libXrender                            \
## && autoreconf -fi \
## && ./configure --prefix=$PREFIX         \
##      --enable-static                    \
##      --disable-shared                   \
##	CPPFLAGS="$CPPFLAGS"                 \
##	CXXFLAGS="$CXXFLAGS"                 \
##	CFLAGS="$CFLAGS"                     \
##	LDFLAGS="$LDFLAGS"                   \
##        CPATH="$CPATH"                                \
##        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
##        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
##        LIBRARY_PATH="$LIBRARY_PATH"                  \
##        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
##        LD_RUN_PATH="$LD_RUN_PATH"                    \
##        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
##        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
##        CC="$CC"                             \
##        CXX="$CXX"                           \
##        FC="$FC"                             \
##        NM="$NM"                             \
##        AR="$AR"                             \
##        RANLIB="$RANLIB"                     \
##        STRIP="$STRIP"                       \
## && make                                 \
## && make install                         \
## && git reset --hard                     \
## && git clean -fdx                       \
## && git clean -fdx                       \
## && cd ..                                \
## && ldconfig || :
##RUN for k in $(seq 5) ; do                                               \
##      sleep 91                                                           \
## && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXft.git \
##   && break                                                              \
##   || (( k != 5 ))                                                       \
##  ; done
##RUN cd libXft                            \
## && autoreconf -fi \
## && ./configure --prefix=$PREFIX         \
##      --enable-static                    \
##      --disable-shared                   \
##	CPPFLAGS="$CPPFLAGS"                 \
##	CXXFLAGS="$CXXFLAGS"                 \
##	CFLAGS="$CFLAGS"                     \
##	LDFLAGS="$LDFLAGS"                   \
##        CPATH="$CPATH"                                \
##        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
##        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
##        LIBRARY_PATH="$LIBRARY_PATH"                  \
##        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
##        LD_RUN_PATH="$LD_RUN_PATH"                    \
##        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
##        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
##        CC="$CC"                             \
##        CXX="$CXX"                           \
##        FC="$FC"                             \
##        NM="$NM"                             \
##        AR="$AR"                             \
##        RANLIB="$RANLIB"                     \
##        STRIP="$STRIP"                       \
## && make                                 \
## && make install                         \
## && git reset --hard                     \
## && git clean -fdx                       \
## && git clean -fdx                       \
## && cd ..                                \
## && ldconfig || :
##RUN for k in $(seq 5) ; do                                               \
##      sleep 91                                                           \
## && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXinerama.git \
##   && break                                                              \
##   || (( k != 5 ))                                                       \
##  ; done
##RUN cd libXinerama                            \
## && autoreconf -fi \
## && ./configure --prefix=$PREFIX         \
##      --enable-static                    \
##      --disable-shared                   \
##	CPPFLAGS="$CPPFLAGS"                 \
##	CXXFLAGS="$CXXFLAGS"                 \
##	CFLAGS="$CFLAGS"                     \
##	LDFLAGS="$LDFLAGS"                   \
##        CPATH="$CPATH"                                \
##        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
##        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
##        LIBRARY_PATH="$LIBRARY_PATH"                  \
##        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
##        LD_RUN_PATH="$LD_RUN_PATH"                    \
##        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
##        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
##        CC="$CC"                             \
##        CXX="$CXX"                           \
##        FC="$FC"                             \
##        NM="$NM"                             \
##        AR="$AR"                             \
##        RANLIB="$RANLIB"                     \
##        STRIP="$STRIP"                       \
## && make                                 \
## && make install                         \
## && git reset --hard                     \
## && git clean -fdx                       \
## && git clean -fdx                       \
## && cd ..                                \
## && ldconfig || :
##RUN for k in $(seq 5) ; do                                               \
##      sleep 91                                                           \
## && git clone --depth=1 --recursive https://github.com/fltk/fltk.git \
##   && break                                                              \
##   || (( k != 5 ))                                                       \
##  ; done
##RUN cd fltk                              \
## && ./autogen.sh                         \
## && ./configure --prefix=$PREFIX         \
##      --enable-static                    \
##      --disable-shared                   \
##	CPPFLAGS="$CPPFLAGS"                 \
##	CXXFLAGS="$CXXFLAGS"                 \
##	CFLAGS="$CFLAGS"                     \
##	LDFLAGS="$LDFLAGS"                   \
##        CPATH="$CPATH"                                \
##        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
##        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
##        LIBRARY_PATH="$LIBRARY_PATH"                  \
##        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
##        LD_RUN_PATH="$LD_RUN_PATH"                    \
##        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
##        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
##        CC="$CC"                             \
##        CXX="$CXX"                           \
##        FC="$FC"                             \
##        NM="$NM"                             \
##        AR="$AR"                             \
##        RANLIB="$RANLIB"                     \
##        STRIP="$STRIP"                       \
## && make                                 \
## && make install                         \
## && git reset --hard                     \
## && git clean -fdx                       \
## && git clean -fdx                       \
## && cd ..                                \
## && ldconfig || :
##RUN for k in $(seq 5) ; do                                               \
##      sleep 91                                                           \
## && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xdg/xdg-utils.git \
##   && break                                                              \
##   || (( k != 5 ))                                                       \
##  ; done
##RUN cd xdg-utils                         \
## && autoreconf -fi                       \
## && ./configure --prefix=$PREFIX         \
##      --enable-static                    \
##      --disable-static                   \
##	CPPFLAGS="$CPPFLAGS"                 \
##	CXXFLAGS="$CXXFLAGS"                 \
##	CFLAGS="$CFLAGS"                     \
##	LDFLAGS="$LDFLAGS"                   \
##        CPATH="$CPATH"                                \
##        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
##        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
##        LIBRARY_PATH="$LIBRARY_PATH"                  \
##        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
##        LD_RUN_PATH="$LD_RUN_PATH"                    \
##        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
##        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
##        CC="$CC"                             \
##        CXX="$CXX"                           \
##        FC="$FC"                             \
##        NM="$NM"                             \
##        AR="$AR"                             \
##        RANLIB="$RANLIB"                     \
##        STRIP="$STRIP"                       \
## && make                                 \
## && make install                         \
## && git reset --hard                     \
## && git clean -fdx                       \
## && git clean -fdx                       \
## && cd ..                                \
## && ldconfig || :
##
###RUN sleep 91 && git clone --depth=1 --recursive https://github.com/caligari87/Oblige.git
###RUN cd Oblige                  \
### && sed -i                     \
###      's@^find .. @find . @'   \
###      misc/normalize-source.sh \
### && make normalize             \
### && make                       \
### && make install
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://github.com/InnovAnon-Inc/Oblige.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd Oblige                  \
 && make normalize             \
 && make                       \
 && make install               \
 && git reset --hard           \
 && git clean -fdx             \
 && git clean -fdx

RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://github.com/caligari87/ObAddon.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd ObAddon/scripts              \
 && chmod -v +x normalize-source.sh \
 && make normalize                  \
 && make                            \
 && install -v build/obaddon.pk3 /usr/local/share/oblige/addons/ \
 && cd ..                           \
 && git reset --hard                \
 && git clean -fdx                  \
 && git clean -fdx

COPY ./CONFIG.txt ./OPTIONS.txt /usr/local/share/oblige/
RUN           tar  cf /tmp/squash.tar    \
        $(command -v oblige)             \
 && ldd $(command -v oblige)             \
  | sed -n 's@^ *.*=> \(.*\) (.*)$@\1@p' \
  | xargs -n1 tar  uf /tmp/squash.tar    \
 && mkdir          -v /tmp/squash        \
 &&           tar vxf /tmp/squash.tar    \
                   -C /tmp/squash        \
 && xbps-remove -y            \
      autoconf                \
      automake                \
      binutils                \
      clang                   \
      cmake                   \
      curl                    \
      elfutils-devel          \
      gcc                     \
      git                     \
      gmp-devel               \
      isl-devel               \
      libmpc-devel            \
      libtool                 \
      llvm                    \
      make                    \
      m4                      \
      mpfr-devel              \
      ninja                   \
      perf                    \
      polygen                 \
      upx                     \
      gettext-devel           \
      gperf                   \
      pkg-config              \
      po4a texinfo            \
      zip                     \
      fontconfig-devel        \
      xorgproto               \
      libXau-devel            \
      libxcb-devel            \
      libX11-devel            \
      libXext-devel           \
      libXrender-devel        \
      libXft-devel            \
      libXinerama-devel       \
      fltk-devel              \
      xdg-utils               \
      libXfixes-devel         \
      glu-devel               \
      MesaLib-devel           \
      libXdamage-devel        \
      libXdmcp-devel          \
      libXxf86vm-devel        \
      libglvnd-devel

FROM scratch as squash
COPY --from=builder / /
RUN tar xf /tmp/squash.tar -C / \
 && rm -v  /tmp/squash.tar      \
 && chown -R tor:tor /var/lib/tor
SHELL ["/bin/bash", "-l", "-c"]
WORKDIR /opt/wads

#FROM squash as test
RUN tor --verify-config              \
 && cd /opt/wads                     \
 && oblige                           \
      --home /usr/local/share/oblige \
      --batch /opt/wads/latest.wad   \
 && test -f   /opt/wads/latest.wad
#
#FROM squash as final
VOLUME  /opt/wads
ENTRYPOINT ["/bin/bash", "-l", "-c", \
            "sleep", "127", "&&",    \
            "oblige", "--home", "/usr/local/share/oblige"]
CMD        [          "--batch", "/opt/wads/latest.wad"]

