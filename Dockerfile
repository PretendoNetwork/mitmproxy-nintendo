# The official mitmproxy image uses OpenSSL 3.0.x, which has older versions of
# the SSL and TLS protocols disabled. Unfortunately, the Wii U does not support
# the newer protocols, so we need to compile a custom version of OpenSSL that
# has the older protocols enabled and link it to the Python cryptography
# package. Then, we copy our build of OpenSSL and cryptography to the mitmproxy
# container. This is definitely a hack, but it seems to work.
FROM debian:bookworm AS openssl-build
ARG openssl_version="1.1.1w" openssl_prefix="/opt/openssl" openssl_dir="/usr/lib/ssl"

# Install build dependencies
RUN apt update
RUN apt install -y curl build-essential python3 python3-dev python3-pip python3-venv libffi-dev cargo pkg-config

# Download and compile OpenSSL
RUN curl https://www.openssl.org/source/openssl-${openssl_version}.tar.gz | tar -xvz -C /tmp
WORKDIR /tmp/openssl-${openssl_version}
RUN ./config --prefix=${openssl_prefix} --openssldir=${openssl_dir} -Wl,-Bsymbolic-functions -fPIC shared
RUN make -j $(nproc)
RUN make install_sw

# Create Python cryptography environment
WORKDIR /opt
ENV OPENSSL_DIR=${openssl_prefix}
RUN python3 -m venv cryptography
RUN . ./cryptography/bin/activate && python3 -m pip install cryptography --no-binary cryptography

# This is the main mitmproxy image that will be run
FROM mitmproxy/mitmproxy:latest AS mitmproxy
ARG openssl_prefix="/opt/openssl"
COPY --from=openssl-build ${openssl_prefix} ${openssl_prefix}
COPY --from=openssl-build /opt/cryptography/lib /usr/local/lib
