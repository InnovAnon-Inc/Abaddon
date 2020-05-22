# TODO oblige fails to compile on modern systems;
#      gives an error about trying to assign a packed structure to a short...
#      is this 32-bit code?
FROM innovanon/poobuntu-18.04:latest
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

RUN git clone --depth=1 https://github.com/caligari87/Oblige.git
#RUN git clone --depth=1 https://git.code.sf.net/p/oblige/code2 Oblige
#RUN wget http://sourceforge.net/projects/oblige/files/Oblige/7.70/oblige-770-source.zip
#RUN unzip oblige-770-source.zip
#RUN mv -v Oblige-7.70-source Oblige
WORKDIR ${B}/src/Oblige
RUN mkdir -v obj_linux
RUN make
# fails to install icons in menu
RUN make install || :
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
RUN apt-mark manual libfltk1.3 libfltk-images1.3 libxft2 libxinerama1 libjpeg8 libpng16-16 zlib1g
RUN apt-fast purge --autoremove -y `cat dpkg.list`
RUN ./poobuntu-clean.sh
RUN rm -v dpkg.list

COPY CONFIG.txt  /usr/local/share/oblige
COPY OPTIONS.txt /usr/local/share/oblige

WORKDIR /root/oblige/wads
CMD        ["--home", "/usr/local/share/oblige"]
ENTRYPOINT ["/usr/local/bin/oblige"]
#, "--home", "/usr/local/share/oblige"]
