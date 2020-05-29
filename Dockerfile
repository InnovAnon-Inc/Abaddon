FROM innovanon/poobuntu:latest
MAINTAINER Innovations Anonymous <InnovAnon-Inc@protonmail.com>

LABEL version="1.0"                                                     \
      maintainer="Innovations Anonymous <InnovAnon-Inc@protonmail.com>" \
      about="Compile/Install Oblige/ObAddon on Linux"                   \
      org.label-schema.build-date=$BUILD_DATE                           \
      org.label-schema.license="PDL (Public Domain License)"            \
      org.label-schema.name="Compile/Install Oblige/ObAddon"            \
      org.label-schema.url="InnovAnon-Inc.github.io/Abaddon"            \
      org.label-schema.vcs-ref=$VCS_REF                                 \
      org.label-schema.vcs-type="Git"                                   \
      org.label-schema.vcs-url="https://github.com/InnovAnon-Inc/Abaddon"

ENV B /usr

COPY dpkg.list manual.list ./
RUN apt-fast update \
 && apt-fast install `grep -v '^[\^#]' dpkg.list` \
 && mkdir -pv ${B}/src

# sanity check
RUN command -v busybox

WORKDIR ${B}/src

#RUN apt-fast update 
#RUN pcurl https://github.com/InnovAnon-Inc/Oblige/archive/master.zip \
#  | busybox unzip -q -                                               \
# && pcurl https://github.com/caligari87/ObAddon/archive/master.zip   \
RUN curl -qL https://github.com/InnovAnon-Inc/Oblige/archive/master.zip \
  | busybox unzip -q -                                               \
 && curl -qL https://github.com/caligari87/ObAddon/archive/master.zip   \
  | busybox unzip -q -
#RUN pcurl https://github.com/InnovAnon-Inc/Oblige/archive/master.zip \
#  | busybox unzip -q -                                               \
# && pcurl https://github.com/caligari87/ObAddon/archive/master.zip   \
#  | busybox unzip -q -

WORKDIR ${B}/src/Oblige-master
RUN chmod -v +x misc/normalize-source.sh \
 && make normalize                       \
 && make                                 \
 && make install
#RUN find . -iname \*.lua -exec chmod -v +x {} + \

WORKDIR ${B}/src/ObAddon-master/scripts
#RUN rm -rf Oblige \
# && git clone --depth=1 https://github.com/caligari87/ObAddon.git
#WORKDIR ${B}/src/ObAddon/scripts
#RUN rm -rf Oblige-master \
# && wget -qO- https://github.com/caligari87/ObAddon/archive/master.zip \
#  | busybox unzip -q -
#WORKDIR ObAddon-master/scripts
#RUN sed -i 's/zip -vr/zip -q -Z bzip2 -9 -r/' makefile \
RUN sed -i 's/zip -vr/zip -q -9 -r/' makefile \
 && chmod -v +x normalize-source.sh           \
 && make normalize                            \
 && make                                      \
 && install build/obaddon.pk3 /usr/local/share/oblige/addons/

WORKDIR /
RUN rm -rf ${B}/src/Oblige-master ${B}/src/ObAddon-master \
 && apt-mark manual `grep -v '^[\^#]' manual.list`        \
 && apt-fast purge  `grep -v '^[\^#]' dpkg.list`          \
 && ./poobuntu-clean.sh                                   \
 && rm -v manual.list dpkg.list

#COPY CONFIG.txt OPTIONS.txt /usr/local/share/oblige/

WORKDIR /root/oblige/wads
# TODO figure out a way to have DockerHub mount these as vols with rw perms
COPY CONFIG.txt OPTIONS.txt /usr/local/share/oblige/

WORKDIR /root/oblige/wads

#CMD        ["--batch", "latest.wad"]
ENTRYPOINT ["/usr/local/bin/oblige", "--home", "/usr/local/share/oblige"]

