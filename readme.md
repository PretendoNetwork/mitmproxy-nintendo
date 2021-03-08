# mitmproxy-nintedo

A package for intercepting traffic from the WiiU and 3DS

## Prerequisites

- mitmproxy (https://mitmproxy.org/)
- a *nix system (macos, linux, untested on WSL)
- SSL patches for your console ([3DS SSL Patch](https://github.com/InternalLoss/3DS-SSL-Patch), [WiiU SSL Patch](https://github.com/PretendoNetwork/network-installer/tree/nossl-5.5.5))

## Usage

- Clone this repo to your computer
- Run one of the launcher scripts to launch a proxy server
- Configure your console to connect to the proxy

For use with Pretendo run with the option `--scripts ./pretendo_addon.py`. This will add the custom `pretendo_redirect` and `pretendo_http` options

## Known issues

- WiiU eShop does not work (crashes on boot)