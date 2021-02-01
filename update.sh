#! /bin/bash
set -euvxo pipefail
(( ! $# ))
FLAG=0
for k in $(seq 5) ; do
  sleep $((91 * 2 ** k))
  xbps-install -Suy || continue
  FLAG=1
  break
done
(( FLAG ))

FLAG=0
for k in $(seq 7) ; do
  sleep $((91 * 2 ** k))
  xbps-install   -y gettext gettext-devel gettext-libs gperf pkg-config po4a texinfo zip || continue
  FLAG=1
  break
done
(( FLAG ))

rm -v "$0"

