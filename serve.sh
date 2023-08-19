#!/bin/bash
set -e

podman run -it -v $PWD:/src -p 127.0.0.1:1313:1313 klakegg/hugo:latest serve
