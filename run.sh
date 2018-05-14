#!/bin/bash

set -e

zshrc_path=${1:-${PWD}/.zshrc}

docker run --rm -v $zshrc_path:/home/zplug/.zshrc -it zplug
