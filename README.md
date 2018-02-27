# docker-tak

This repo depends on the following FOUO files:

- takserver-1.3.3-4183.noarch.zip
- TAKServerReflector.zip

These are not included in this repo for obvious reasons.

# Setup

The first time you run the `takserver` container, you will want to run it without `ENABLE_SSL` defined, so that it can start up without SSL.

After doing so, you will need to run the `makeCerts.sh` script under the `certs/` folder to generate the SSL CA, Server, and client certs files.

Then you will need to copy down the `certs/` folder with:

    docker cp takserver:/opt/tak/certs/ certs/

And run the `repackagecerts.sh` script to repackage the .zip files with the certs you just generated:

    ./repackagecerts.sh

Now you can re-build the container images, and re-enable the `ENABLE_SSL` environment variable, and start the containers back up.

