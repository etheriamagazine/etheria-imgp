# ==================================================================================================
# imgproxy build

FROM darthsim/imgproxy-base:latest

RUN git clone https://github.com/imgproxy/imgproxy.git .

RUN bash -c 'go build -v -ldflags "-s -w" -o /opt/imgproxy/bin/imgproxy'

# ==================================================================================================
# custom caddy build

FROM caddy:2.8.4-builder-alpine

RUN xcaddy build \
    --with github.com/darkweak/souin/plugins/caddy \
    --with github.com/darkweak/storages/go-redis/caddy

# ==================================================================================================
# Final image

FROM ubuntu:noble

# install required imgproxy dependencies
RUN apt-get update \
  && apt-get upgrade -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    libstdc++6 \
    fontconfig-config \
    fonts-dejavu-core \
    media-types \
    libjemalloc2 \
    libtcmalloc-minimal4 \
    vim \       
  && ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so \
  && ln -s /usr/lib/$(uname -m)-linux-gnu/libtcmalloc_minimal.so.4 /usr/local/lib/libtcmalloc_minimal.so \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /etc/fonts/conf.d/10-sub-pixel-rgb.conf /etc/fonts/conf.d/11-lcdfilter-default.conf


# copy imgproxy binaries
COPY --from=0 /opt/imgproxy/bin/imgproxy /opt/imgproxy/bin/
COPY --from=0 /opt/imgproxy/lib /opt/imgproxy/lib
RUN ln -s /opt/imgproxy/bin/imgproxy /usr/local/bin/imgproxy

# copy caddy binary and config file
COPY --from=1 /usr/bin/caddy /usr/local/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile

# wrapper script to launch two processes
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 8081