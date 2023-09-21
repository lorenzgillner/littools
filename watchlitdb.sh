#!/bin/bash

inotifywait -m -q -r --format '%:e "%w%f"' -e create -e moved_from -e delete $1
