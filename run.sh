#! /usr/bin/env bash
set -exu
(( $# == 0 ))
cd "`dirname "$(readlink -f "$0")"`"

command -v docker ||
curl https://raw.githubusercontent.com/InnovAnon-Inc/repo/master/get-docker.sh | bash

docker volume inspect abaddonvol ||
docker volume create  abaddonvol

trap 'docker-compose down' 0

xhost +local:`whoami`
sudo             -- \
nice -n +20      -- \
sudo -u `whoami` -- \
docker-compose up --build --force-recreate
#docker-compose up -d --build

#docker run   -t --net=host -e DISPLAY=${DISPLAY} --mount source=abaddonvol,target=/root/oblige --rm --name abaddon innovanon/abaddon --help

WAD=`hostname`-`date +%Y-%m-%d.%H-%M-%S.%N`.wad
( # Create but don't run container from resulting image
  CID=$(docker create --mount source=abaddonvol,target=/root/oblige innovanon/abaddon)

  # Container be gone
  trap "docker rm ${CID}" 0

  docker cp ${CID}:/root/oblige/wads/latest.wad $WAD )

# Grab that artifact sweetness
for k in *.wad ; do
[[ $k != $WAD ]]          || continue
[[ ! `diff -q $k $WAD` ]] || continue
rm -v $WAD
break
done

docker-compose push
( #git pull
git add .
git commit -m "auto commit by $0"
git push ) || :

