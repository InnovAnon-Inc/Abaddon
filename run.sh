#! /bin/bash
set -exu
[[ $# -eq 0 ]]

cat > /dev/null << "EOF"
sudo             -- \
nice -n +20      -- \
sudo -u `whoami` -- \
docker-compose build

docker push innovanon/abaddon:latest || :

trap 'docker-compose down' 0

xhost +local:`whoami`
sudo             -- \
nice -n +20      -- \
sudo -u `whoami` -- \
docker-compose up --force-recreate
EOF

docker version ||
dockerd &

docker volume inspect abaddonvol ||
docker volume create  abaddonvol

xhost +local:`whoami`
sudo             -- \
nice -n +20      -- \
sudo -u `whoami` -- \
docker-compose up --build
#docker-compose up -d --build

#docker run   -t --net=host -e DISPLAY=${DISPLAY} --mount source=abaddonvol,target=/root/oblige --rm --name abaddon innovanon/abaddon --help

# Create but don't run container from resulting image
CID=$(docker create --mount source=abaddonvol,target=/root/oblige innovanon/abaddon)

# Container be gone
trap "docker rm ${CID}" 0

# Grab that artifact sweetness
docker cp ${CID}:/root/oblige/wads/latest.wad `hostname`-`date +%Y-%m-%d.%H-%M-%S.%N`.wad

