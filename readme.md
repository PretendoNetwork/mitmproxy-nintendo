# mitmproxy-nintedo

a package for intercepting traffic from nintendo consoles (currently only the 3ds)

## prerequisites

- a working mitmproxy install
- the nintendo console to intercept traffic from
- a *nix computer (macos, linux, maybe bsd)

## usage

- clone (or download) this repo to your computer
- run one of the launcher scripts to launch a proxy server
- configure your console to connect to the proxy
- hope that it works

## troubleshooting

### my console says that it cannot do x!

check the logs. does the proxy say that it is having a certificate issue?
if so, go into the `client-certificate` directory of this repository and
create a symbolic link to the `ctr-common-1.pem` file named
`<nintendo domain that it cannot connect to>.pem` and try again. if this
does not work, file an issue
