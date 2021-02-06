#FROM innovanon/void-base as builder
FROM innovanon/doom-base as bootstrap
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
#ENV   CFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -pg -fprofile-abs-path -fprofile-dir=/var/cpuminer  $CFLAGS"
#ENV  LDFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -pg -fprofile-abs-path -fprofile-dir=/var/cpuminer $LDFLAGS"
ENV   CFLAGS="-pg -fprofile-abs-path -fprofile-generate=/var/cpuminer  $CFLAGS"
ENV  LDFLAGS="-pg -fprofile-abs-path -fprofile-generate=/var/cpuminer $LDFLAGS"

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
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://github.com/madler/zlib.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd zlib                           \
 && ./configure --prefix=$PREFIX      \
      --const --static --64           \
 && make                              \
 && make install                      \
 && git reset --hard                  \
 && git clean -fdx                    \
 && git clean -fdx                    \
 && cd ..                             \
 && ldconfig
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://github.com/glennrp/libpng.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd libpng                         \
 && autoreconf -fi                    \
 && ./configure --prefix=$PREFIX      \
      --enable-static                 \
      --disable-shared                \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                              \
 && make install                      \
 && git reset --hard                  \
 && git clean -fdx                    \
 && git clean -fdx                    \
 && cd ..                             \
 && ldconfig
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://github.com/libjpeg-turbo/libjpeg-turbo.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd libjpeg-turbo                     \
 && mkdir -v build                       \
 && cd       build                       \
 && cmake -G'Unix Makefiles'             \
      -DCMAKE_BUILD_TYPE=Release         \
      -DCMAKE_C_FLAGS="$CFLAGS"          \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS"      \
      -DCMAKE_FIND_ROOT_PATH=$PREFIX     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX     \
      ..                                 \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://github.com/libexpat/libexpat.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd libexpat/expat                    \
 && ./buildconf.sh                       \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://github.com/freetype/freetype.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd freetype                          \
 && sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg \
 && sed -r  "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:"       \
         -i include/freetype/config/ftoption.h         \
 && ./autogen.sh                         \
 && ./configure --help                   \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
      FREETYPE_LIBS=$PREFIX/lib          \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://github.com/freedesktop/fontconfig.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd fontconfig                        \
 && rm -f src/fcobjshash.h               \
 && ./autogen.sh --prefix=$PREFIX        \
      --enable-static                    \
      --disable-shared                   \
      --disable-docs                     \
      FREETYPE_LIBS=$PREFIX/lib          \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig || :
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/util/macros.git util-macros \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd util-macros                       \
 && ./autogen.sh                         \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/proto/xorgproto.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd xorgproto                         \
 && ./autogen.sh                         \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
      -Dlegacy=true                      \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig || :
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXau.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd libXau                            \
 && ./autogen.sh                         \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig || :
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/proto/xcbproto.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd xcbproto                          \
 && ls -ltra \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libxcb.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd libxcb                            \
 && autoreconf -fi \
 && CFLAGS="-Wno-error=format-extra-args $CFLAGS" \
    ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
      --without-doxygen                  \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig || :
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libX11.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd libX11                            \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig || :
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXext.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd libXext                            \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig || :
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXfixes.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd libXfixes                            \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig || :
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXrender.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd libXrender                            \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig || :
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXft.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd libXft                            \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig || :
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXinerama.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd libXinerama                            \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig || :
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://github.com/fltk/fltk.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd fltk                              \
 && ./autogen.sh                         \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig || :
RUN for k in $(seq 5) ; do                                               \
      sleep 91                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xdg/xdg-utils.git \
   && break                                                              \
   || (( k != 5 ))                                                       \
  ; done
RUN cd xdg-utils                         \
 && autoreconf -fi                       \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-static                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..                                \
 && ldconfig || :

#RUN sleep 91 && git clone --depth=1 --recursive https://github.com/caligari87/Oblige.git
#RUN cd Oblige                  \
# && sed -i                     \
#      's@^find .. @find . @'   \
#      misc/normalize-source.sh \
# && make normalize             \
# && make                       \
# && make install
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

# old entrypoint (PGO)
WORKDIR /root/oblige/wads
RUN oblige --home /usr/local/share/oblige --batch latest.wad

#FROM scratch as reset
#FROM innovanon/doom-base as builder-2
FROM bootstrap as builder-2
COPY --from=builder /tmp/ /tmp/
COPY --from=builder /var/cpuminer /var/cpuminer

COPY ./update.sh ./
RUN  ./update.sh

ARG CPPFLAGS
ARG   CFLAGS
ARG CXXFLAGS
ARG  LDFLAGS

ENV CPPFLAGS="$CPPFLAGS"
ENV   CFLAGS="$CFLAGS"
ENV CXXFLAGS="$CXXFLAGS"
ENV  LDFLAGS="$LDFLAGS"

ENV PREFIX=/usr/local
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

ENV   CFLAGS="-march=$ARCH -mtune=$ARCH $CFLAGS"

# PGO
ENV   CFLAGS="-fprofile-abs-path -fprofile-use=/var/cpuminer  $CFLAGS"
ENV  LDFLAGS="-fprofile-abs-path -fprofile-use=/var/cpuminer $LDFLAGS"

# Debug
ENV   CFLAGS="-Ofast -g0 $CFLAGS"

# LTO
ENV   CFLAGS="-fuse-linker-plugin -flto $CFLAGS"
ENV  LDFLAGS="-fuse-linker-plugin -flto $LDFLAGS"

# Dead Code Strip
ENV   CFLAGS="-ffunction-sections -fdata-sections $CFLAGS"
ENV  LDFLAGS="-Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections $LDFLAGS"

# Optimize
ENV CFLAGS="-fmerge-all-constants $CFLAGS"

ENV CXXFLAGS="$CXXFLAGS $CFLAGS"

WORKDIR /tmp/
RUN cd zlib                           \
 && ./configure --prefix=$PREFIX      \
      --const --static --64           \
 && make                              \
 && make install                      \
 && cd ..                             \
 && rm -rf zlib                       \
 && ldconfig
RUN cd libpng                         \
 && autoreconf -fi                    \
 && ./configure --prefix=$PREFIX      \
      --enable-static                 \
      --disable-shared                \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                              \
 && make install                      \
 && cd ..                             \
 && rm -rf libpng                     \
 && ldconfig
RUN cd libjpeg-turbo                     \
 && mkdir -v build                       \
 && cd       build                       \
 && cmake -G'Unix Makefiles'             \
      -DCMAKE_BUILD_TYPE=Release         \
      -DCMAKE_C_FLAGS="$CFLAGS"          \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS"      \
      -DCMAKE_FIND_ROOT_PATH=$PREFIX     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX     \
      ..                                 \
 && make                                 \
 && make install                         \
 && cd ../..                             \
 && rm -rf libjpeg-turbo                 \
 && ldconfig
RUN cd libexpat/expat                    \
 && ./buildconf.sh                       \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ../..                             \
 && rm -rf libexpat                      \
 && ldconfig
RUN cd freetype                          \
 && sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg \
 && sed -r  "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:"       \
         -i include/freetype/config/ftoption.h         \
 && ./autogen.sh                         \
 && ./configure --help                   \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
      FREETYPE_LIBS=$PREFIX/lib          \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && rm -rf freetype                      \
 && ldconfig
RUN cd fontconfig                        \
 && rm -f src/fcobjshash.h               \
 && ./autogen.sh --prefix=$PREFIX        \
      --enable-static                    \
      --disable-shared                   \
      --disable-docs                     \
      FREETYPE_LIBS=$PREFIX/lib          \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && rm -rf fontconfig                    \
 && ldconfig || :
RUN cd util-macros                       \
 && ./autogen.sh                         \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make install                         \
 && cd ..                                \
 && rm -rf util-macros                   \
 && ldconfig
RUN cd xorgproto                         \
 && ./autogen.sh                         \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
      -Dlegacy=true                      \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make install                         \
 && cd ..                                \
 && rm -rf xorgproto                     \
 && ldconfig || :
RUN cd libXau                            \
 && ./autogen.sh                         \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && rm -rf libXau                        \
 && ldconfig || :
RUN cd xcbproto                          \
 && ls -ltra \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make install                         \
 && cd ..                                \
 && rm -rf xcbproto                      \
 && ldconfig
RUN cd libxcb                            \
 && autoreconf -fi \
 && CFLAGS="-Wno-error=format-extra-args $CFLAGS" \
    ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
      --without-doxygen                  \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && rm -rf libxcb                        \
 && ldconfig || :
RUN cd libX11                            \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && rm -rf libX11                        \
 && ldconfig || :
RUN cd libXext                            \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && rm -rf libXext                       \
 && ldconfig || :
RUN cd libXfixes                            \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && rm -rf libXfixes                     \
 && ldconfig || :
RUN cd libXrender                            \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && rm -rf libXrender                    \
 && ldconfig || :
RUN cd libXft                            \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && rm -rf libXft                        \
 && ldconfig || :
RUN cd libXinerama                            \
 && autoreconf -fi \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && rm -rf libXinerama                   \
 && ldconfig || :
RUN cd fltk                              \
 && ./autogen.sh                         \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && rm -rf fltk                          \
 && ldconfig || :
RUN cd xdg-utils                         \
 && autoreconf -fi                       \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-static                   \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        CC="$CC"                             \
        CXX="$CXX"                           \
        FC="$FC"                             \
        NM="$NM"                             \
        AR="$AR"                             \
        RANLIB="$RANLIB"                     \
        STRIP="$STRIP"                       \
 && make                                 \
 && make install                         \
 && cd ..                                \
 && rm -rf xdg-utils                     \
 && ldconfig || :

#RUN sleep 91 && git clone --depth=1 --recursive https://github.com/caligari87/Oblige.git
#RUN cd Oblige                  \
# && sed -i                     \
#      's@^find .. @find . @'   \
#      misc/normalize-source.sh \
# && make normalize             \
# && make                       \
# && make install
RUN cd Oblige                  \
 && make normalize             \
 && make                       \
 && make install               \
 && cd ..                      \
 && rm -rf Oblige

RUN cd ObAddon/scripts              \
 && chmod -v +x normalize-source.sh \
 && make normalize                  \
 && make                            \
 && install -v build/obaddon.pk3 /usr/local/share/oblige/addons/ \
 && cd ../..                        \
 && rm -rf ObAddon

COPY ./CONFIG.txt ./OPTIONS.txt /usr/local/share/oblige/

FROM scratch as squash
COPY --from=builder-2 / /
RUN chown -R tor:tor /var/lib/tor
SHELL ["/bin/bash", "-l", "-c"]

FROM squash as test
WORKDIR /root/oblige/wads
 #&& xbps-install -S                 \
RUN sleep 91                        \
 && tor --verify-config             \
 && oblige --home /usr/local/share/oblige --batch latest.wad

RUN ls -ltra /etc
RUN ls -ltra /usr/local/bin
RUN ls -ltra /usr/local

FROM scratch as squash-2
COPY --from=squash               \
  /lib/ld-musl-x86_64.so.1       \
  /lib/libz.so.1                 \
  /lib/libevent-2.1.so.7         \
  /lib/libssl.so.48              \
  /lib/libcrypto.so.46           \
  /lib/liblzma.so.5              \
  /lib/libzstd.so.1              \
  /lib/libscrypt.so.0            \
  /lib/libseccomp.so.2           \
  /lib/libcap.so.2               \
  /lib/
COPY --from=squash               \
  /usr/lib/libz.so.1             \
  /usr/lib/libfltk_images.so.1.3 \
  /usr/lib/libfltk.so.1.3        \
  /usr/lib/libstdc++.so.6        \
  /usr/lib/libgcc_s.so.1         \
  /usr/lib/libXrender.so.1       \
  /usr/lib/libXfixes.so.3        \
  /usr/lib/libXext.so.6          \
  /usr/lib/libXft.so.2           \
  /usr/lib/libfontconfig.so.1    \
  /usr/lib/libXinerama.so.1      \
  /usr/lib/libX11.so.6           \
  /usr/lib/libpng16.so.16        \
  /usr/lib/libjpeg.so.8          \
  /usr/lib/libfreetype.so.6      \
  /usr/lib/libexpat.so.1         \
  /usr/lib/libuuid.so.1          \
  /usr/lib/libxcb.so.1           \
  /usr/lib/libbz2.so.1           \
  /usr/lib/libXau.so.6           \
  /usr/lib/libXdmcp.so.6         \
  /usr/lib/
COPY --from=squash               \
  /usr/local/bin/oblige          \
  /usr/local/bin/
COPY --from=squash               \
  /usr/local/share/oblige/       \
  /usr/local/share/oblige
COPY --from=squash               \
  /etc/passwd                    \
  /etc/
COPY --from=squash               \
  /etc/profile.d/support.sh      \
  /etc/profile.d
COPY --from=squash               \
     --chown=tor:tor             \
  /usr/bin/tor                   \
  /usr/bin/
COPY --from=squash               \
  /var/lib/tor/                  \
  /var/lib/tor
#RUN chown -R tor:tor /var/lib/tor
SHELL ["/bin/bash", "-l", "-c"]

FROM squash-2 as test-2
WORKDIR /root/oblige/wads
RUN sleep 91                        \
 && tor --verify-config             \
 && oblige --home /usr/local/share/oblige --batch latest.wad

FROM scratch as squash-3
COPY --from=squash-2 / /
RUN chown -R tor:tor /var/lib/tor
SHELL ["/bin/bash", "-l", "-c"]

FROM squash-3 as test-3
WORKDIR /root/oblige/wads
RUN sleep 91                        \
 && tor --verify-config             \
 && oblige --home /usr/local/share/oblige --batch latest.wad

FROM squash-3 as final
VOLUME  /root/oblige/wads
WORKDIR /root/oblige/wads
RUN sleep 91                        \
 && oblige --home /usr/local/share/oblige --batch latest.wad
#ENTRYPOINT ["/bin/bash", "-l", "-c", "/usr/local/bin/oblige", "--home", "/usr/local/share/oblige"]
ENTRYPOINT ["/bin/bash", "-l", "-c", "oblige", "--home", "/usr/local/share/oblige"]
CMD                                           ["--batch", "latest.wad"]

