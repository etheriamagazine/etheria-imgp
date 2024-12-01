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


## Flush REDIS CACHE
To flush the Redis cache, you can issue various commands:

To connect to the redis instance:
```
fly redis connect
```

To see a certain key:
```cmd
127.0.0.1:16379> keys *telfair*
1) "GET-http-imgp.etheriamagazine.com-/UVkqh5a2sR64XghbBwsbj13izh_jnRa0aGQGVsHuPp0/rs:fit:1200/plain/https://fotos.etheriamagazine.com/2024/11/heritage-le-telfair-piscina-principal.jpg@avif"
2) "GET-http-imgp.etheriamagazine.com-/bTRNopc3aj3Mf4PFJYmhXUhbGJ4kNay4hXBrvay0hO4/rs:fit:1200/plain/https://fotos.etheriamagazine.com/2024/11/heritage-le-telfair-JUNIOR-SUITE.jpg@avif"
```

To remove a single key:
```
127.0.0.1:6379> del "GET-http-imgp.etheriamagazine.com-/UVkqh5a2sR64XghbBwsbj13izh_jnRa0aGQGVsHuPp0/rs:fit:1200/plain/https://fotos.etheriamagazine.com/2024/11/heritage-le-telfair-piscina-principal.jpg@avif"
(integer) 1
```

To flush some keys matching a pattern using `EVAl` lua script, to make them expire right away.
```
127.0.0.1:6379> eval 'for i, name in ipairs(redis.call("KEYS", "*telfair*")) do redis.call("EXPIRE", name, 1); end' 0
```

To flush all keys:
```
127.0.0.1:6379> flushall
```

