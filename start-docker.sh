#! /bin/sh

docker build . -t ghcr.io/pretendonetwork/mitmproxy-nintendo
docker run -it --rm --name mitmproxy-pretendo -v mitmproxy-pretendo-data:/home/mitmproxy/.mitmproxy -p 8080:8080 -p 127.0.0.1:8081:8081 ghcr.io/pretendonetwork/mitmproxy-nintendo mitmweb --web-host 0.0.0.0
