#!/bin/bash -x

cd TAKServerReflector
cd PlayRecordings
chmod 755 publish_file
exec $@
# exec ./publish_file --output-address 127.0.0.1 --output-port 3080 --input-file raven1
