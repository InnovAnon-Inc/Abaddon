#! /bin/bash
set -exu

#[ "$(ls -A /root/oblige)" ] ||
#oblige --install /root/oblige

for k in addons wads ; do
   [ -d /root/oblige/$k ] ||
   mkdir -v /root/oblige/$k
done

for k in no_hang_lamp obaddon ; do
   [ -s /root/oblige/addons/$k.pk3 ] ||
   ln -sv /usr/local/share/oblige/addons/$k.pk3 /root/oblige/addons
done

[ -e /root/oblige/CONFIG.txt ] ||
mv -v /root/CONFIG.txt /root/oblige/

oblige --home /root/oblige \
       --addon /root/oblige/addons/{no_hang_lamp,obaddon}.pk3
