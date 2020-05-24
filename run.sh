#! /bin/bash
set -exu

if ! command -v dockerd ; then
	command -v wget ||
	apt install wget
	wget -nc https://download.docker.com/linux/static/stable/x86_64/docker-19.03.8.tgz
	[ -d docker-19.03.8 ] ||
	tar xf docker-19.03.8.tgz
	install docker/* /usr/local/bin/
fi

docker version ||
dockerd &

sudo             -- \
nice -n +20      -- \
sudo -u `whoami` -- \
docker build -t innovanon/abaddon .

docker push innovanon/abaddon:latest || :

docker volume inspect abaddonvol ||
docker volume create  abaddonvol

xhost +local:`whoami`
sudo             -- \
nice -n -20      -- \
sudo -u `whoami` -- \
docker run   -t --net=host -e DISPLAY=${DISPLAY} --mount source=abaddonvol,target=/root/oblige --rm --name abaddon innovanon/abaddon
#docker run   -t --mount source=abaddonvol,target=/root/oblige --rm --name abaddon innovanon/abaddon

# https://www.reddit.com/r/docker/comments/9ou9wx/getting_build_artifacts_out_of_docker_image/

# Create but don't run container from resulting image
CID=$(docker create --mount source=abaddonvol,target=/root/oblige innovanon/abaddon)

# Container be gone
trap "docker rm ${CID}" 0

# Grab that artifact sweetness
docker cp ${CID}:/root/oblige/wads/latest.wad `hostname`-`date +%Y-%m-%d.%H-%M-%S.%N`.wad

