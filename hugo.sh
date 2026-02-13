#!/bin/bash

podman run -it -v $PWD:/src klakegg/hugo:latest $@
