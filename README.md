# NodeJS 10.x image built using docker FROM scratch

This repository contains a Dockerfile which builds a minimal NodeJS 10.x application base image using docker `FROM scratch`.
The target environment for this application base image is Redhat OpenShift.

Currently the NodeJS static binary is not built from source code, but rather taken from the existing Redhat OpenShift S2I image (`registry.access.redhat.com/rhoar-nodejs/nodejs-10`)

