# etheria-imgp
An [imgproxy](https://docs.imgproxy.net/) + reverse caching proxy ready to be
deployed at [Fly.io](https://fly.io).


The [Dockerfile](./Dockerfile) includes imgproxy and a custom build of
[caddy](https://github.com/caddyserver/caddy) that features caching
functionality. The entrypoint of the container is a simple script to launch both
apps when the container starts.


## Environment and secrets

### Imgproxy
For making imgproxy more resistant to DOS attacks, this setup uses [Url
Signing](https://docs.imgproxy.net/usage/signing_url) by setting the environment
variables `IMGPROXY_SALT` and `IMGPROXY_KEY`. 

Use `fly secrets set ...` to configure those env vars as secrets in the Fly.io
infrastructure.

### Caddy as caching reverse proxy
The reverse proxy functionality is provided by
[caddy](https://github.com/caddyserver/caddy) and the
[souin](https://github.com/darkweak/souin/) cache plugin so that imgproxy's processing is done
only once for each variant of an image.

To scale the app so that every instance access a shared cache, this setup uses souin's [go-redis](https://github.com/darkweak/storages/go-redis/) storage provider to access a Redis instance or a [Redis compatible service](https://upstash.com/).


