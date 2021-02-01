#! /bin/bash
set -euvxo pipefail
(( ! $# ))
tor --verify-config

FLAG=0
for k in $(seq 5) ; do
  for K in $(seq $((2 ** k))) ; do
    sleep 91
  done
  xbps-install -Suy || continue
  FLAG=1
  break
done
(( FLAG ))

FLAG=0
for k in $(seq 7) ; do
  for K in $(seq $((2 ** k))) ; do
    sleep 91
  done
  xbps-install   -y gettext gettext-devel gettext-libs gperf pkg-config po4a texinfo zip \
                    fontconfig || continue
  FLAG=1
  break
done
(( FLAG ))

rm -v "$0"

