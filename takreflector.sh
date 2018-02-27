#!/bin/bash -x

cat <<EOF > rsc/wedge.config
InputAddress=${INPUT_ADDRESS:-192.168.16.100}
InputPort=${INPUT_PORT:-3080}
PortQuantity=${PORT_QUANTITY:-10}
OutputPort=${RTMP_PORT:-1935}
ForcedWidth=${FORCED_WIDTH:-320}
ForcedHeight=${FORCED_HEIGHT:-240}
License=../rsc/afrl-marti.gv2f
MissionPackage=../rsc/wedge_server.zip
ElevationOffset=../rsc/ww15mgh.dac
ProcessKLV=true
Pad=0
EOF

exec ./bin/runserver.sh
