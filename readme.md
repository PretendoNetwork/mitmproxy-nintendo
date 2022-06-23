# mitmproxy-nintedo

A package for intercepting traffic from the WiiU and 3DS

## Prerequisites

- mitmproxy (https://mitmproxy.org/)
- a *nix system (macos, linux, untested on WSL)
- SSL patches for your console ([3DS SSL Patch](https://github.com/InternalLoss/3DS-SSL-Patch), [WiiU SSL Patch](https://github.com/PretendoNetwork/Nimble/releases))
  - Alternatively, you can replace the `CACERT_NINTENDO_CA_G3.der` file with the mitmproxy CA cert.

## Usage

- Clone this repo to your computer
- Run one of the launcher scripts to launch a proxy server
- Configure your console to connect to the proxy

Running the launcher script will now automatically load the Pretendo addon script.  This will add the custom `pretendo_redirect` and `pretendo_http` options to mitmproxy.
