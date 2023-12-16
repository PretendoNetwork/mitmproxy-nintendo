# Mitmproxy configuration for Pretendo

This repo contains configurations, scripts, and certificates for using
`mitmproxy`/`mitmweb`/`mitmdump` to intercept traffic from Nintendo consoles,
including the Wii U and the 3DS. This fork is designed to work with a local
Pretendo Network server.

## Usage

### All setups

1. Choose a method below to run mitmproxy ([Docker](#running-with-docker) or
   [local install](#running-locally)).
2. Set up your console to connect the the proxy ([see below](#console-setup)).

### Running with Docker

This is the recommended way to run mitmproxy-pretendo because it always uses the
latest image and is already set up with OpenSSL 1.1.1.

1. Install Docker using the
   [official instructions](https://docs.docker.com/get-docker/).
2. Run a new Docker container using the `ghcr.io/matthewl246/mitmproxy-pretendo`
   image.
    - If you're not familiar with Docker, copy the `docker run ...` command from
      [this script](./start-docker.sh) to get started. Then, open
      <http://127.0.0.1:8081/> in your browser to access the `mitmweb` web
      interface for mitmproxy.
    - Note that if you delete the `mitmproxy-pretendo-data` volume, the
      mitmproxy server certificates will be regenerated and you will need to set
      up the SSL patches with your custom certificates again.

#### Rebuilding the Docker image

If you want to make modifications to the image, you need to rebuild it locally.

1. Clone this repository to your computer
   (`git clone https://github.com/MatthewL246/mitmproxy-pretendo.git`).
2. Use the `./start-docker.sh` script to build and run the container. This build
   overwrites the version you downloaded from the container registry. This will
   take a few minutes the first time, but it will be cached for future builds.
    - You need to rebuild the container every time you change something here.

If you want to revert your local image to the published version, run
`docker pull ghcr.io/matthewl246/mitmproxy-pretendo`.

### Running locally

This method can be used if you don't want to install Docker or just generally
perfer not using Docker.

Note you may run into some issues depending your OpenSSL version. Many current
Linux distributions now use OpenSSL 3.0.0 instead of 1.1.1. OpenSSL 3.0.0
disables protocols TLSv1.1 and earlier by default, but the console does not
support TLSv1.2 or later. Because of this, HTTPS connections to the proxy will
fail if mitmproxy is using OpenSSL 3.0.0.

1. Install Python 3 and pip.
2. Clone this repository to your computer
   (`git clone https://github.com/MatthewL246/mitmproxy-pretendo.git`).
3. Create a virtual environment with `python3 -m venv venv`.
4. Activate the virtual environment with `. ./venv/bin/activate`.
5. Install [mitmproxy](https://mitmproxy.org/) with `pip install mitmproxy`.
    - Test that mitmproxy is working by running `mitmproxy --version`.
    - If the OpenSSL version is above 3.0.0, the console will fail to connect
      via HTTPS. Consider using the Docker container instead, or compile a
      custom version of OpenSSL and Python cryptography
      ([see below](#using-a-custom-version-of-openssl-with-mitmproxy)).
6. Run one of the launcher scripts (i.e. `./mitmproxy`) to launch the mitmproxy
   server.

Running the launcher script will now automatically load the Pretendo addon
script. This will add the custom `pretendo_redirect` and `pretendo_http` options
to mitmproxy.

## Console setup

1. Install Pretendo Network patches on your console using
   [the official guide](https://pretendo.network/docs/install):
    - Download the patches for
      [Wii U](https://github.com/PretendoNetwork/Inkay/releases) or
      [3DS](https://github.com/PretendoNetwork/nimbus/releases).
    - Skip creating a PNID on the official Pretendo server if you will be
      hosting your own server.
    - You'll now need to recompile the patches with your custom certificate
      ([see below](#compiling-custom-pretendo-patches)).
2. Configure your console to connect to the proxy using its system settings. Set
   the console's proxy server to your computer's IP address and the port
   to 8080.

## Modifications

### Compiling custom Pretendo patches

The Pretendo patches normally use a Let's Encrypt certificate for HTTPS
connections, but you can modify them to use your mitmproxy certificate instead.
Fortunately, it's pretty easy if you use Docker to compile the patches.

#### Wii U

1. Clone the Inkay patcher
   (`git clone https://github.com/PretendoNetwork/Inkay.git`)
2. Copy your mitmproxy certificate.
    - If you're using the Docker container, run
      `docker run -it -v mitmproxy-pretendo-data:/mnt busybox cat /mnt/mitmproxy-ca-cert.pem`.
    - If you're running mitmproxy locally, run
      `cat .mitmproxy/mitmproxy-ca-cert.pem`.
3. Replace the contents of `./Inkay/data/ca.pem` with your mitmproxy
   certificate.
4. Run `docker build Inkay -t inkay-build` to build the Inkay build environment.
5. Run `docker run -it --rm -v $(pwd)/Inkay:/app -w /app inkay-build` to compile
   the patches.
6. The compiled patch will be in `./Inkay/Inkay-pretendo.wps`. Copy this patch
   to your SD card at `sd:/wiiu/environments/aroma/plugins`, replacing the
   Pretendo patch that is already there.

Due to Inkay's dependencies, it would be quite difficult to compile the patches
without using Docker. If you don't want to install Docker, you could try forking
the Inkay repository on GitHub, editing the `data/ca.pem` file in your fork, and
building it with GitHub Actions.

#### 3DS

I don't think that the 3DS patches support custom certificates because they just
disable all certificate checks, but I haven't tested this.

### Using a custom version of OpenSSL with mitmproxy

See the [Dockerfile](./Dockerfile) for the necessary build steps. If you are
doing this on your primary system, be very careful to not mess with your system
package manager's OpenSSL installation, as this would break everything that
relies on OpenSSL. Make sure you use a custom prefix like `/opt/openssl` when
compiling OpenSSL 1.1.1. Use the steps to install a custom build of Python
cryptography in your mitmproxy virtual environment.

### Permanently replacing server certificates

If you want to intercept your console's HTTPS traffic with mitmproxy all the
time without using the Pretendo patches, you will need to replace your console's
server certificate with the mitmproxy certificate. Note that this is somewhat
dangerous, as a corrupted certificate can brick your Home Menu. This should be
safe using a coldboot CFW like CHBC, Tiramisu, or Aroma, but be aware of the
risk.

1. Back up all of your Wii U's certificates from
   `/storage_mlc/sys/title/0005001b/10054000/content`. This backup will be
   necessary to undo any modifications.
2. Convert your mitmproxy certificate to the right format by running the command
   `openssl x509 -in ./configuration/mitmproxy-ca-cert.pem -outform der -out CACERT_NINTENDO_CA_G3.der`.
3. Upload the created `CACERT_NINTENDO_CA_G3.der` file to
   `/storage_mlc/sys/title/0005001b/10054000/content/scerts`, replacing the
   original file.

To undo this modification, upload the backup files back to the `content` folder.
