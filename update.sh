#! /bin/bash
set -euvxo pipefail
(( ! $# ))
tor --verify-config

FLAG=0
for k in $(seq 5) ; do
  for K in $(seq $((2 ** k))) ; do
    sleep 91
  done
  #xbps-install -Suy || continue
  apt update || continue
  FLAG=1
  break
done
(( FLAG ))

FLAG=0
for k in $(seq 7) ; do
  for K in $(seq $((2 ** k))) ; do
    sleep 91
  done
#  xbps-install   -y gettext gettext-devel gettext-libs gperf pkg-config po4a texinfo zip \
#                    fontconfig-devel xorgproto libXau-devel libxcb-devel libX11-devel    \
#		    libXext-devel libXrender-devel libXft-devel libXinerama-devel        \
#		    fltk-devel xdg-utils libXfixes-devel glu-devel || continue
   apt install -y gettext gperf pkg-config po4a texinfo zip \
	          libfontconfig-dev libxau-dev libxcb1-dev libx11-dev \
		  libxext-dev libxrender-dev libxft-dev libxinerama-dev \
		  libftk1.3-dev xdg-utils libxfixes-dev libglu1-mesa-dev || continue
  FLAG=1
  break
done
(( FLAG ))

rm -v "$0"

