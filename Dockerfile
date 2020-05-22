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

ENV B /usr

COPY dpkg.list .
RUN apt-fast install `grep -v '^[\^#]' dpkg.list` \
 && mkdir -pv ${B}/src

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

#RUN git clone --depth=1 https://github.com/InnovAnon-Inc/Oblige.git
#WORKDIR ${B}/src/Oblige
#RUN make normalize \
# && make           \
# && make install

RUN wget -qO- https://github.com/InnovAnon-Inc/Oblige/archive/master.zip \
  | busybox unzip -
WORKDIR Oblige-master
RUN chmod -v +x misc/normalize-source.sh \
 && make normalize \
 && make \
 && make install
#RUN find . -iname \*.lua -exec chmod -v +x {} + \

WORKDIR ${B}/src
#RUN rm -rf Oblige \
# && git clone --depth=1 https://github.com/caligari87/ObAddon.git
#WORKDIR ${B}/src/ObAddon/scripts
RUN rm -rf Oblige-master \
 && wget -qO- https://github.com/caligari87/ObAddon/archive/master.zip \
  | busybox unzip -
WORKDIR ObAddon-master/scripts
RUN sed -i 's/zip -vr/zip -Z bzip2 -9 -r/' makefile \
 && chmod -v +x normalize-source.sh \
 && make normalize \
 && make           \
 && install build/obaddon.pk3 /usr/local/share/oblige/addons/
# && mkdir -v obaddon
#WORKDIR obaddon
#RUN busybox unzip ../build/obaddon.pk3          \
# && zip -Z bzip2 -9 -r /usr/local/share/oblige/addons/obaddon.pk3 .
##RUN busybox unzip ../build/obaddon.pk3          \
## && zip -Z bzip2 -9 -r /usr/local/share/oblige/addons/obaddon.pk3 .
## && install build/obaddon.pk3 /usr/local/share/oblige/addons/
##RUN make normalize
##RUN make
##WORKDIR build
##RUN install obaddon.pk3 /usr/local/share/oblige/addons/
##WORKDIR ${B}/src
##RUN rm -rf ObAddon



WORKDIR /
COPY manual.list .
RUN rm -rf ${B}/src/ObAddon-master                 \
 && apt-mark manual `grep -v '^[\^#]' manual.list` \
 && apt-fast purge  `grep -v '^[\^#]' dpkg.list`   \
 && ./poobuntu-clean.sh                            \
 && rm -v manual.list dpkg.list

#RUN rm -v manual.list
#RUN apt-fast purge  `grep -v '^[\^#]' dpkg.list`
# for sf src pkg
#RUN apt-fast purge unzip
#RUN ./poobuntu-clean.sh
#RUN rm -v dpkg.list

#COPY CONFIG.txt  /usr/local/share/oblige
#COPY OPTIONS.txt /usr/local/share/oblige
COPY CONFIG.txt OPTIONS.txt /usr/local/share/oblige/

WORKDIR /root/oblige/wads
CMD        ["--home", "/usr/local/share/oblige"]
#CMD        ["--home", "/usr/local/share/oblige", "--batch", "latest.wad"]
ENTRYPOINT ["/usr/local/bin/oblige"]
#, "--home", "/usr/local/share/oblige"]

