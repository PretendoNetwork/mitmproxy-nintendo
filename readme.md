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

## Known issues

- WiiU eShop does not work (crashes on boot)
- Occasionally, a site will not work and cause a certificate warning in the mitmproxy logs. If this happens, go into the client-certificate directory of this repository and create a symbolic link to ctr-common-1.pem if you are using a 3DS or WIIU_COMMON_CERT_1.pem if you are using a Wii U named \<nintendo domain that you cannot connect to\>.pem and try again.
- It is not possible to use SSLv3 or SSLv2 using the latest version of mitmproxy with OpenSSL. This might cause problems with certain servers. There is currently no workaround for this because OpenSSL 1.1.x has completely removed support for old versions of SSL.
