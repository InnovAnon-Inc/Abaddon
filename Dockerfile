# TODO oblige fails to compile on modern systems;
#      gives an error about trying to assign a packed structure to a short...
#      is this 32-bit code?
FROM innovanon/poobuntu:latest
#FROM innovanon/poobuntu-18.04:latest
#FROM innovanon/poobuntu-17.04:latest
#FROM innovanon/poobuntu-16.04:latest
#FROM innovanon/poobuntu:18.04
#FROM ubuntu:18.04
MAINTAINER Innovations Anonymous <InnovAnon-Inc@protonmail.com>

LABEL version="1.0"
LABEL maintainer="Innovations Anonymous <InnovAnon-Inc@protonmail.com>"
LABEL about="Compile/Install Oblige/ObAddon on Linux"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.license="PDL (Public Domain License)"
LABEL org.label-schema.name="Compile/Install Oblige/ObAddon"
LABEL org.label-schema.url="InnovAnon-Inc.github.io/Abaddon"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vcs-type="Git"
LABEL org.label-schema.vcs-url="https://github.com/InnovAnon-Inc/Abaddon"

COPY dpkg.list .
RUN apt-fast install `grep -v '^[\^#]' dpkg.list`

ENV B /usr
RUN mkdir -pv ${B}/src
WORKDIR ${B}/src

#RUN git clone --depth=1 https://github.com/caligari87/Oblige.git
#RUN git clone --depth=1 https://github.com/GTD-Carthage/Oblige.git
#RUN git clone --depth=1 https://github.com/simon-v/Oblige.git
#WORKDIR ${B}/src/Oblige
#RUN find . -iname \*.h -exec sed -i 's/#define *PACKEDATTR *__attribute__ *(( *packed *))/#define PACKEDATTR/' {} \;
#RUN mkdir -v obj_linux

#RUN git clone --depth=1 https://git.code.sf.net/p/oblige/code2 Oblige
#WORKDIR ${B}/src/Oblige
#RUN mkdir -v obj_linux
#RUN mkdir -v obj_linux/lua obj_linux/glbsp obj_linux/physfs obj_linux/ajpoly

#RUN wget http://sourceforge.net/projects/oblige/files/Oblige/7.70/oblige-770-source.zip
#RUN apt-fast install unzip
#RUN unzip oblige-770-source.zip
#RUN mv -v Oblige-7.70-source Oblige
#WORKDIR ${B}/src/Oblige

#RUN sed -i -e 's/-Wall/-w/g' -e '/xdg-desktop-menu/d' -e '/xdg-icon-resource/d' Makefile

RUN git clone --depth=1 https://github.com/InnovAnon-Inc/Oblige.git
WORKDIR ${B}/src/Oblige
RUN make normalize

RUN make
RUN make install
WORKDIR ${B}/src
RUN rm -rf Oblige

RUN git clone --depth=1 https://github.com/caligari87/ObAddon.git
WORKDIR ${B}/src/ObAddon/scripts
RUN chmod -v +x normalize-source.sh
RUN make normalize
RUN make
WORKDIR build
RUN install obaddon.pk3 /usr/local/share/oblige/addons/
WORKDIR ${B}/src
RUN rm -rf ObAddon



WORKDIR /
COPY manual.list .
RUN apt-mark manual `grep -v '^[\^#]' manual.list`
RUN rm -v manual.list
RUN apt-fast purge  `grep -v '^[\^#]' dpkg.list`
# for sf src pkg
#RUN apt-fast purge unzip
RUN ./poobuntu-clean.sh
RUN rm -v dpkg.list

COPY CONFIG.txt  /usr/local/share/oblige
COPY OPTIONS.txt /usr/local/share/oblige

WORKDIR /root/oblige/wads
CMD        ["--home", "/usr/local/share/oblige"]
ENTRYPOINT ["/usr/local/bin/oblige"]
#, "--home", "/usr/local/share/oblige"]
