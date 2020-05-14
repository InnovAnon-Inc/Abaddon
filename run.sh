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
nice -n -20      -- \
sudo -u `whoami` -- \
docker build -t abaddon .
#xhost +local:`whoami`
docker volume inspect abaddonvol ||
docker volume create  abaddonvol
docker run   -t --net=host -e DISPLAY=${DISPLAY} --mount source=abaddonvol,target=/root/oblige --rm --name abaddon abaddon

