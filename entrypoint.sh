#!/bin/bash

# wrapper script to start both imgproxy and caddy on the same container

# start imgproxy in background
imgproxy &

# start caddy
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
