#!/bin/bash

set -e

cp -R ~/.ssh .ssh

docker build -t zplug -f Dockerfile .

rm -rf .ssh
