#!/bin/bash

if [ ! -f TAKServerReflector.zip ] ; then
  echo The TAKServerReflector.zip file is FOUO and is intentionally not packaged as part of this git repo.
fi  

if [ ! -f takserver-1.3.3-4183.noarch.zip ]; then
  echo The takserver-1.3.3-4183.noarch.zip file is FOUO and is intentionally not package as part of this git repo.
fi

if [ ! -d TAKServerReflector ] ; then
  unzip TAKServerReflector.zip
fi

if [ ! -d mjpegserver-linux-x86_64-2017_11_16 ] ; then
  mkdir -p mjpegserver-linux-x86_64-2017_11_16
  tar xvzf ./TAKServerReflector/mjpegserver-linux-x86_64-2017_11_16.tar.gz -C mjpegserver-linux-x86_64-2017_11_16
fi

if [ ! -d wedge_server ] ; then
  mkdir -p wedge_server
  cd wedge_server
  unzip ../mjpegserver-linux-x86_64-2017_11_16/rsc/wedge_server.zip
  cd ..
fi

if [ -f ./TAKServerReflector/mjpegserver-linux-x86_64-2017_11_16/rsc/wedge_server.zip ]; then
  rm -f ./TAKServerReflector/mjpegserver-linux-x86_64-2017_11_16/rsc/wedge_server.zip
fi

cp ./certs/atak_1.p12 wedge_server/wowza_1.p12
cp ./certs/truststore.p12 wedge_server/truststore.p12

cd wedge_server
zip -r ../mjpegserver-linux-x86_64-2017_11_16/rsc/wedge_server.zip .
cd ..

if [ -f ./TAKServerReflector/mjpegserver-linux-x86_64-2017_11_16.tar.gz ] ; then
  rm -f ./TAKServerReflector/mjpegserver-linux-x86_64-2017_11_16.tar.gz
fi
	
tar czf ./TAKServerReflector/mjpegserver-linux-x86_64-2017_11_16.tar.gz -C mjpegserver-linux-x86_64-2017_11_16 .

if [ -f TAKServerReflector.zip ]; then
  rm -f TAKServerReflector.zip
fi

zip -r TAKServerReflector.zip TAKServerReflector/
