# syntax=docker/dockerfile:1

# The official mitmproxy image uses OpenSSL 3.0.x, which has older versions of
# the SSL and TLS protocols disabled. Unfortunately, the Wii U does not support
# newer protocols, so we need to compile a custom version of OpenSSL that has
# the older protocols enabled and link it to the Python cryptography package.
# Then, we copy our build of OpenSSL and cryptography to the final mitmproxy
# container. This is definitely a hack, but it seems to work fine in a container.

ARG openssl_version="1.1.1w" openssl_dir="/opt/openssl" \
    openssl_config_dir="/usr/lib/ssl" cryptography_dir="/opt/cryptography"

# We use the mitmproxy image for the build stage to ensure that all dependencies
# are at the right versions, even though mitmproxy itself is not used here.
FROM mitmproxy/mitmproxy:latest AS openssl-build
ARG openssl_version openssl_dir openssl_config_dir cryptography_dir

# Install build dependencies
RUN apt update && \
    apt install -y \
    curl build-essential libffi-dev pkg-config
RUN curl https://sh.rustup.rs | sh -s -- -y

# Download and compile OpenSSL
RUN curl https://www.openssl.org/source/openssl-${openssl_version}.tar.gz | tar -xvz -C /tmp
WORKDIR /tmp/openssl-${openssl_version}
RUN ./config --prefix=${openssl_dir} --openssldir=${openssl_config_dir} -Wl,-Bsymbolic-functions -fPIC shared
RUN make -j $(nproc)
RUN make install_sw

# Create Python cryptography environment
WORKDIR ${cryptography_dir}
ENV PATH="/root/.cargo/bin:${PATH}"
ENV OPENSSL_DIR=${openssl_dir}
RUN python3 -m venv venv
RUN . ${cryptography_dir}/venv/bin/activate && \
    python3 -m pip install cryptography --no-binary cryptography -v

# This is the main mitmproxy container that will be run. We use a new image so
# the build tools are not left over in the final image.
FROM mitmproxy/mitmproxy:latest AS mitmproxy
ARG openssl_dir cryptography_dir
COPY --from=openssl-build ${openssl_dir} ${openssl_dir}
COPY --from=openssl-build ${cryptography_dir}/venv/lib /usr/local/lib
WORKDIR /home/mitmproxy
COPY . .
EXPOSE 8080 8081
