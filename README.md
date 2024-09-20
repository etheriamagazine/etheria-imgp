# etheria-imgp
This is a [imgproxy](https://docs.imgproxy.net/) and
[caddy](https://github.com/caddyserver/caddy) implementation to run on the same
[Fly.io](https://fly.io) Fly Machine.

The build is done though a [Dockerfile](./Dockerfile) where we install a custom
build of caddy that includes a cache plugin and imgproxy. We use a wrapper
script to launch both apps when the container starts.

The 

## Environment and secrets

### imgproxy
For making imgproxy more resistant to DOS attacks, the url can be signed as
detailed in the [docs](https://docs.imgproxy.net/usage/signing_url) using the
environment variables `IMGPROXY_SALT` and `IMGPROXY_KEY`. 

Use `fly secrets set IMGPROXY_SALT=...` and `fly secrets set IMGPROXY_KEY=...`
to set those vars.

### caddy as reverse proxy
Our reverse proxy implementation with caddy uses the
[souin](https://github.com/darkweak/souin/) cache plugin so that once imgproxy
processes a source image it gets cached and speed up the response.

As we wan't to be able to scale to multiple machines, the cache needs to be
shared among the multiple Fly Machines so we use the
[go-redis](https://github.com/darkweak/storages/go-redis/) storage  option.

```bash
xcaddy build \
    --with github.com/darkweak/souin/plugins/caddy \
    --with github.com/darkweak/storages/go-redis/caddy
```

The redis backend could be another fly machine, but we have decided to use the
solution that Fly.io provides, Upstash Redis.
```
fly redis create etheria-imgp-cache
```
