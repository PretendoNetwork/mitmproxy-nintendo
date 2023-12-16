#! /bin/sh

docker build . -t ghcr.io/matthewl246/mitmproxy-pretendo
docker run -it --rm -v mitmproxy-pretendo-data:/home/mitmproxy/.mitmproxy -p 8080:8080 -p 127.0.0.1:8081:8081 ghcr.io/matthewl246/mitmproxy-pretendo mitmweb --web-host 0.0.0.0
