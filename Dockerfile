FROM sirboops/nodejs:8.15.0-alpine as node
FROM alpine:3.8

# Update the container
RUN apk upgrade

# Install NodeJS
COPY --from=node /opt/node /opt/node
RUN apk add libstdc++

# Set the net path with node
ENV PATH="${PATH}:/opt/node/bin"

# Build Pinafore
ENV PINA_HASH="58b0c56ad88129e7de69d8efda6820f9da1d6ab0"
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
