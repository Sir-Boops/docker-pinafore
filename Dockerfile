FROM alpine:3.8

# Build NodeJS
ENV NODE_VER="8.14.0"
RUN apk update && \
	apk upgrade && \
	apk --virtual deps add \
		build-base python linux-headers && \
	apk add libgcc libstdc++ && \
	cd ~ && \
	wget https://nodejs.org/dist/v$NODE_VER/node-v$NODE_VER.tar.xz && \
	tar xf node-v$NODE_VER.tar.xz && \
	cd node-v$NODE_VER && \
	./configure --prefix=/opt/node && \
	make -j$(nproc) > /dev/null && \
	make install && \
	rm -rf ~/*

# Set the net path with node
ENV PATH="${PATH}:/opt/node/bin"

# Build Pinafore
ENV PINA_HASH="049bbba63920bb99d5a1be52d192266785663616"
RUN apk --virtual deps add \
		git && \
	cd /opt && \
	git clone https://github.com/nolanlawson/pinafore && \
	cd pinafore && \
	git checkout $PINA_HASH && \
	npm install && \
	npm run build && \
	rm -rf .git

# Final Cleanup
RUN apk del --purge deps && \
	npm cache clean --force

# Final container settings
ENV PORT="4002"

EXPOSE 4002
WORKDIR /opt/pinafore
CMD npm start
