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

### Replacing server certificates

1. Back up all of your Wii U's certificates from `/storage_mlc/sys/title/0005001b/10054000/content`. This backup will be necessary to undo any modifications.
2. Convert your mitmproxy certificate to the right format by running the command `openssl x509 -in mitmproxy-ca-cert.pem -outform der -out CACERT_NINTENDO_CA_G3.der` in the `configuration` folder.
3. Upload the created `CACERT_NINTENDO_CA_G3.der` file to `/storage_mlc/sys/title/0005001b/10054000/content/scerts`, replacing the original file.

To undo this modification, just upload the backup files back to the `content` folder.

### Using a custom version of OpenSSL with mitmproxy

1. Install mitmproxy normally with `pip install mitmproxy`.
2. Get the [latest version](https://www.openssl.org/source/) of **OpenSSL 1.1.1** and download it with `curl https://www.openssl.org/source/openssl-1.1.1(version).tar.gz | tar xz; cd openssl-1.1.1(version)`
3. Compile OpenSSL and Python cryptography according to the  [Python cryptography module documentation](https://cryptography.io/en/latest/installation/#build-on-linux):
```
sudo apt-get install build-essential libffi-dev python3-dev cargo -y
sudo apt-get remove libssl-dev -y
./config -Wl,-Bsymbolic-functions -fPIC shared
sudo make -j8
sudo make install_sw
openssl version
hash -r
pip install cryptography --no-binary cryptography --force
```
Running `mitmproxy --version` should now show the custom version of OpenSSL.
