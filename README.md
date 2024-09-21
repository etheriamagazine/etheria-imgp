# etheria-imgp
An [imgproxy](https://docs.imgproxy.net/) +
[caddy](https://github.com/caddyserver/caddy) ready to be deployed at
[Fly.io](https://fly.io).


The [Dockerfile](./Dockerfile) includes imgproxy and a custom build of
[caddy](https://github.com/caddyserver/caddy) that features caching
functionality. The entrypoint of the container is a simple script to launch both
apps when the container starts.


## Imgproxy
For making imgproxy more resistant to DOS attacks, use [Url
Signing](https://docs.imgproxy.net/usage/signing_url) by setting the environment
variables `IMGPROXY_SALT` and `IMGPROXY_KEY`. 

Use `fly secrets set ...` to configure those env vars as secrets in the Fly.io
infrastructure.

## Caddy
To cache imgproxy's responses, [caddy](https://github.com/caddyserver/caddy) is
[configured](./Caddyfile) as a reverse caching proxy. The setup makes use of
[souin](https://github.com/darkweak/souin/), an HTTP cache system compatible
with caddy, so that imgproxy's processing is done only once for each variant of
an image.

To persist the processed images and to be able scale the service to multiple
machines, the setup uses souin's
[go-redis](https://github.com/darkweak/storages/go-redis/) storage provider to
access a Redis instance or a [Redis compatible service](https://upstash.com/).


