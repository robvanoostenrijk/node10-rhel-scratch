FROM	registry.access.redhat.com/rhoar-nodejs/nodejs-10 AS build

USER	root

# Overwrite /etc/passwd and /etc/group in order to copy them later
RUN	echo "node:x:1001:1001:NodeJS:/usr/src/app:/bin/false" > /etc/passwd && \
	echo "node:x:1001:x" > /etc/group && \
	mkdir -p /usr/src/app

FROM 	scratch

ENV	NODEJS_VERSION=10 \
	NODE_EXTRA_CA_CERTS=/var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt

LABEL	name="Node.js $NODEJS_VERSION" \
	summary="Node.js $NODEJS_VERSION" \
	description="Node.js $NODEJS_VERSION base application image" \
	version="$NODEJS_VERSION" \
	io.k8s.display-name="Node.js $NODEJS_VERSION" \
	io.k8s.description="Node.js $NODEJS_VERSION base application image" \
	io.openshift.expose-services="5000:http" \
	io.openshift.tags="nodejs,nodejs-10" \
	io.openshift.wants="rhel,rhel7,rhel7.6"

COPY	--from=build ["/lib64/libdl.so.2", "/lib64/librt.so.1", "/lib64/libstdc++.so.6", "/lib64/libm.so.6", "/lib64/libgcc_s.so.1", "/lib64/libpthread.so.0", "/lib64/libc.so.6", "/lib64/ld-linux-x86-64.so.2", "/lib64/"]

# Additional libraries for /bin/bash and /bin/ls (enable if required)
COPY	--from=build ["/lib64/libtinfo.so.5", "/lib64/libselinux.so.1", "/lib64/libcap.so.2", "/lib64/libacl.so.1", "/lib64/libpcre.so.1", "/lib64/libattr.so.1", "/lib64/"]

# User definitions (containing only node:node)
COPY	--from=build ["/etc/passwd", "/etc/group", "/etc/"]

# node & node_modules (/usr/bin/env is needed for npm to function)
COPY	--from=build ["/usr/lib/node_modules", "/usr/lib/node_modules"]
COPY	--from=build ["/usr/bin/node", "/usr/bin/env", "/usr/bin/"]
COPY	--from=build ["/usr/src/app", "/usr/src/app"]

COPY	--from=build ["/bin/false", "/bin/ln", "/bin/"]

# /bin/sh and /bin/ls executables (enable if required)
COPY	--from=build ["/bin/sh", "/bin/ls", "/bin/"]

# Enable npm to be ran
RUN	ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm

EXPOSE	5000

WORKDIR	/usr/src/app

USER	node

ENTRYPOINT ["/usr/bin/npm"]
CMD        ["start"]
