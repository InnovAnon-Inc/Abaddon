FROM innovanon/void-base as builder

RUN sleep 91 \
 && xbps-install -Suy
RUN sleep 91 \
 && xbps-install   -y gettext gperf po4a zip

ARG CPPFLAGS
ARG   CFLAGS
ARG CXXFLAGS
ARG  LDFLAGS

ENV CHOST=x86_64-linux-musl
ENV CC=$CHOST-gcc
ENV CXX=$CHOST-g++
ENV FC=$CHOST-gfortran
ENV NM=$CC-nm
ENV AR=$CC-ar
ENV RANLIB=$CC-ranlib
ENV STRIP=$CHOST-strip

ENV CPPFLAGS="$CPPFLAGS"
ENV   CFLAGS="$CFLAGS"
ENV CXXFLAGS="$CXXFLAGS"
ENV  LDFLAGS="$LDFLAGS"

#ENV PREFIX=/usr/local
ENV PREFIX=/opt/cpuminer
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

ENV CPPFLAGS="-DUSE_ASM $CPPFLAGS"
ENV   CFLAGS="-march=$ARCH -mtune=$ARCH $CFLAGS"

# FDO
ENV   CFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt  $CFLAGS"
ENV  LDFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt $LDFLAGS"

# Debug
ENV CPPFLAGS="-DNDEBUG $CPPFLAGS"

RUN sleep 91                          \
 && git clone --depth=1 --recursive https://github.com/madler/zlib.git
RUN cd zlib                           \
 && ./configure --prefix=$PREFIX      \
      --const --static --64           \
 && make                              \
 && make install                      \
 && git reset --hard                  \
 && git clean -fdx                    \
 && git clean -fdx                    \
 && cd ..
RUN sleep 91                          \
 && git clone --depth=1 --recursive https://github.com/glennrp/libpng.git
RUN cd libpng                         \
 && autoreconf -fi                    \
 && ./configure --prefix=$PREFIX      \
      --enable-static                 \
      --disable-shared                \
 && make                              \
 && make install                      \
 && git reset --hard                  \
 && git clean -fdx                    \
 && git clean -fdx                    \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://github.com/libjpeg-turbo/libjpeg-turbo.git
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
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://github.com/freetype/freetype.git
RUN cd freetype                          \
 && sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg \
 && sed -r  "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:"       \
         -i include/freetype/config/ftoption.h         \
 && ./autogen.sh                         \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://github.com/freedesktop/fontconfig.git
RUN cd fontconfig                        \
 && rm -f src/fcobjshash.h               \
 && ./autogen.sh --prefix=$PREFIX        \
      --enable-static                    \
      --disable-shared                   \
      --disable-docs                     \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/util/macros.git util-macros
RUN cd util-macros                       \
 && ./autogen.sh                         \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/proto/xorgproto.git
RUN cd xorgproto                         \
 && ./autogen.sh                         \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
      -Dlegacy=true                      \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXau.git
RUN cd libXau                            \
 && ./autogen.sh                         \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/proto/xcbproto.git
RUN cd xcbproto                          \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libxcb.git
RUN cd libxcb                            \
 && CFLAGS="-Wno-error=format-extra-args $CFLAGS" \
    ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
      --without-doxygen                  \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libX11.git
RUN cd libX11                            \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXext.git
RUN cd libXext                            \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXfixes.git
RUN cd libXfixes                            \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXrender.git
RUN cd libXrender                            \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXft.git
RUN cd libXft                            \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXinerama.git
RUN cd libXinerama                            \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://github.com/fltk/fltk.git
RUN cd fltk                              \
 && ./autogen.sh                         \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-shared                   \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..
RUN sleep 91                             \
 && git clone --depth=1 --recursive https://gitlab/freedesktop.org/xdg/xdg-utils.git
RUN cd xdg-utils                         \
 && autoreconf -fi                       \
 && ./configure --prefix=$PREFIX         \
      --enable-static                    \
      --disable-static                   \
 && make                                 \
 && make install                         \
 && git reset --hard                     \
 && git clean -fdx                       \
 && git clean -fdx                       \
 && cd ..

#RUN sleep 91 && git clone --depth=1 --recursive https://github.com/caligari87/Oblige.git
#RUN cd Oblige                  \
# && sed -i                     \
#      's@^find .. @find . @'   \
#      misc/normalize-source.sh \
# && make normalize             \
# && make                       \
# && make install
RUN sleep 91                   \
 && git clone --depth=1 --recursive https://github.com/InnovAnon-Inc/Oblige.git
RUN cd Oblige                  \
 && make normalize             \
 && make                       \
 && make install

RUN sleep 91                        \
 && git clone --depth=1 --recursive https://github.com/caligari87/ObAddon.git
RUN cd ObAddon/scripts              \
 && chmod -v +x normalize-source.sh \
 && make normalize                  \
 && make                            \
 && install -v build/obaddon.pk3 /usr/local/share/oblige/addons/

COPY ./CONFIG.txt ./OPTIONS.txt /usr/local/share/oblige/

FROM scratch as squash
COPY --from=builder / /
RUN chown -R tor:tor /var/lib/tor
SHELL ["/bin/bash", "-l", "-c"]

VOLUME  /root/oblige/wads
WORKDIR /root/oblige/wads
ENTRYPOINT ["/bin/bash", "-l", "-c", "/usr/local/bin/oblige", "--home", "/usr/local/share/oblige"]
CMD                                                          ["--batch", "latest.wad"]

