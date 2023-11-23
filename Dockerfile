FROM golang:1.21-alpine AS build
WORKDIR /app
ENV CGO_ENABLED=0
ADD . /build
WORKDIR /build
RUN \
    if [ -z "$CI" ] ; then \
    echo "runs outside of CI" && version=$(git rev-parse --abbrev-ref HEAD)-$(git log -1 --format=%h)-$(date +%Y%m%dT%H:%M:%S); \
    else version=${GIT_BRANCH}-${GITHUB_SHA:0:7}-$(date +%Y%m%dT%H:%M:%S); fi && \
    echo "version=$version" && \
    cd app && go build -o /build/docker-logger -ldflags "-X main.revision=${version} -s -w"

FROM alpine
COPY --from=build /build/docker-logger /srv/docker-logger
USER 1000
ENTRYPOINT ["/srv/docker-logger"]