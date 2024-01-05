# Mitmproxy configuration for Pretendo

This repo contains configurations, scripts, and certificates for using
`mitmproxy`/`mitmweb`/`mitmdump` to intercept traffic from Nintendo consoles,
including the Wii U and the 3DS. It supports multiple operation modes, including
redirecting requests to a local Pretendo Network server and collecting Wii U and
3DS network dumps.

## Collecting network dumps

1. Download and install Docker using the
   [official guide](https://docs.docker.com/get-docker/).
2. First, make sure to **disable** Inkay or Nimbus to ensure that you are
   connected to the official Nintendo Network servers. Then, download the right
   NoSSL patches for your console.
   <!-- TODO: Where are the patches? Link them here. -->
3. Configure your console to connect to the proxy server.
   - Wii U:
     1. Open System Settings => Internet => Connect to the Internet =>
        Connections => (Your current internet connection) => Change Settings.
     2. Go to Proxy Settings => Set => OK => (Set the proxy server to your
        computer's IP address and the port to 8082) => Confirm => Don't Use
        Authentication.
   - 3DS:
     1. Open System Settings => Internet Settings => Connection Settings =>
        (Your current connection) => Change Settings.
     2. Go to Proxy Settings => Yes => Detailed Setup => (Set the proxy server
        to your computer's IP address and the port to 8083) => OK => Don't Use
        Authentication.
4. Copy the command that matches your console and paste it inside a terminal
   window to start the proxy server inside a Docker container.
   - Wii U:
     `docker run -it --rm -p 8082:8082 -v ./dumps:/home/mitmproxy/dumps ghcr.io/pretendonetwork/mitmproxy-nintendo:wiiu mitmdump`
   - 3DS:
     `docker run -it --rm -p 8083:8083 -v ./dumps:/home/mitmproxy/dumps ghcr.io/pretendonetwork/mitmproxy-nintendo:3ds mitmdump`
5. Check your terminal window to make sure that your console is connecting to
   the proxy server. You should see some "client connect" and "client disonnect"
   messages.
6. Do whatever activity you want to have in the network dump.
7. Press `Control` and `c` in the terminal window to stop the proxy and create
   the dump HAR file in the `dumps` folder.
8. Rename the HAR file (`wiiu-latest.har` or `3ds-latest.har`) in the `dumps`
   folder to something descriptive.
   - **Warning: If you don't rename the dump before restarting the proxy
     container, it will be overwritten!**
9. Go back to step 4 for your next network dump.
10. Upload your HAR files to the Pretendo Network Discord server to share them
    with the developers.
    - **Note: Make sure to upload the HAR files directly so they can be
      automatically processed to scrub personal information. Don't zip them.**

When you are finished with collecting network dumps, go back into your console's
Internet settings and disable the proxy server. For security reasons, please
also delete the NoSSL patch you downloaded in step 2.

## Local server redirection

### Steps

1. Choose a method below to run mitmproxy ([Docker](#running-with-docker) or
   [local install](#running-locally)).
2. Set up your console to connect the the proxy ([see below](#console-setup)).

### Running with Docker

This is the recommended way to run mitmproxy-nintendo because it always uses the
latest image and is already set up with OpenSSL 1.1.1.

1. Install Docker using the
   [official instructions](https://docs.docker.com/get-docker/).
2. Run a new Docker container using the
   `ghcr.io/pretendonetwork/mitmproxy-nintendo` image.
   - If you're not familiar with Docker, copy the `docker run ...` command from
     [this script](./start-docker.sh) to get started. Then, open
     <http://127.0.0.1:8081/> in your browser to access the `mitmweb` web
     interface for mitmproxy.
   - Note that if you delete the `mitmproxy-pretendo-data` volume, the mitmproxy
     server certificates will be regenerated and you will need to set up the SSL
     patches with your custom certificates again.

#### Rebuilding the Docker image

If you want to make modifications to the image, you need to rebuild it locally.

1. Clone this repository to your computer
   (`git clone https://github.com/PretendoNetwork/mitmproxy-nintendo.git`).
2. Use the `./start-docker.sh` script to build and run the container. This build
   overwrites the version you downloaded from the container registry. This will
   take a few minutes the first time, but it will be cached for future builds.
   - You need to rebuild the container every time you change something here.

If you want to revert your local image to the published version, run
`docker pull ghcr.io/pretendonetwork/mitmproxy-nintendo`.

### Running locally

This method can be used if you don't want to install Docker or just generally
prefer not to use Docker.

Note you may run into some issues depending your OpenSSL version. Many current
Linux distributions now use OpenSSL 3.0.0 instead of 1.1.1. OpenSSL 3.0.0
disables protocols TLSv1.1 and earlier by default, but the console does not
support TLSv1.2 or later. Because of this, HTTPS connections to the proxy will
fail if mitmproxy is using OpenSSL 3.0.0.

1. Install Python 3 and pip.
2. Clone this repository to your computer
   (`git clone https://github.com/PretendoNetwork/mitmproxy-nintendo.git`).
3. Create a virtual environment with `python3 -m venv venv`.
4. Activate the virtual environment with `. ./venv/bin/activate`.
5. Install [mitmproxy](https://mitmproxy.org/) with `pip install mitmproxy`.
   - Test that mitmproxy is working by running `mitmproxy --version`.
   - If the OpenSSL version is above 3.0.0, the console will fail to connect via
     HTTPS. Consider using the Docker container instead, or compile a custom
     version of OpenSSL and Python cryptography
     ([see below](#using-a-custom-version-of-openssl-with-mitmproxy)).
6. Run one of the launcher scripts (i.e. `./mitmproxy`) to launch the mitmproxy
   server.

Running the launcher script will automatically load the Pretendo addon script.
This will add the custom `pretendo_*` options to mitmproxy that allow you to
redirect HTTP requests to your local server.

## Console setup

1. Install Pretendo Network patches on your console using
   [the official guide](https://pretendo.network/docs/install):
   - Download the patches for
     [Wii U](https://github.com/PretendoNetwork/Inkay/releases) or
     [3DS](https://github.com/PretendoNetwork/nimbus/releases).
   - Skip creating a PNID on the official Pretendo server if you will be hosting
     your own server.
   - If you want to use Juxtaposition, you'll now need to recompile the patches
     with your custom certificate
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
     `docker run -it --rm -v mitmproxy-pretendo-data:/mnt busybox cat /mnt/mitmproxy-ca-cert.pem`.
   - If you're running mitmproxy locally, run
     `cat .mitmproxy/mitmproxy-ca-cert.pem`.
3. Replace the contents of `./Inkay/data/ca.pem` with your mitmproxy
   certificate.
4. Run `docker build Inkay -t inkay-build` to build the Inkay build environment.
5. Run `docker run -it --rm -v $(pwd)/Inkay:/app -w /app inkay-build` to compile
   the patches.
6. The compiled patch will be in `./Inkay/Inkay-pretendo.wps`. Copy this patch
   to your SD card over FTPiiU by running
   `ftp -u ftp://a:a@WIIU_IP/fs/vol/external01/wiiu/environments/aroma/plugins/Inkay-pretendo.wps ./Inkay/Inkay-pretendo.wps`,
   replacing the `WIIU_IP` with your Wii U's IP address. This will replace the
   Pretendo patch with your version with custom certificates.
7. Reboot your Wii U.

Due to Inkay's dependencies, it would be quite difficult to compile the patches
without using Docker. If you don't want to install Docker, you could try forking
the Inkay repository on GitHub, editing the `data/ca.pem` file in your fork, and
building it with GitHub Actions.

If you want to revert back to the regular Pretendo Network patches, re-download
them from the Inkay repository and upload them back to your Wii U.

#### 3DS

Copy the `mitmproxy-ca-cert.pem` file to your microSD card as
`sd:/3ds/juxt-prod.pem`.

### Using a custom version of OpenSSL with mitmproxy

See the [Dockerfile](./Dockerfile) for the necessary build steps. If you are
doing this on your primary system, be very careful to not mess with your system
package manager's OpenSSL installation, as this would break everything that
relies on OpenSSL. Make sure you use a custom prefix like `/opt/openssl` when
compiling OpenSSL 1.1.1. Use the steps to install a custom build of Python
cryptography in your mitmproxy virtual environment.

### Permanently replacing server certificates

#### **_Notice: This method is deprecated and unsafe. Use a NoSSL patch instead._**

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
