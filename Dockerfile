ARG VARNISH_VERSION="6.0.12"  # stable
ARG VARNISH_MODULES_BRANCH="6.0"

FROM varnish:$VARNISH_VERSION as modules
ARG VARNISH_MODULES_BRANCH
RUN set -e; \
    export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    apt-get update; \
    apt-get install -y make automake autoconf git python3 python3-docutils pkg-config libtool; \
    dpkg -i /pkgs/varnish-dev*.deb;  \
    echo ""

RUN cd /tmp \
  && git clone --branch $VARNISH_MODULES_BRANCH --single-branch https://github.com/varnish/varnish-modules.git \
  && cd varnish-modules \
  && ./bootstrap \
  && ./configure \
  && make -j $(nproc) \
  && make install

FROM varnish:$VARNISH_VERSION
COPY --from=modules /usr/lib/varnish/vmods/* /usr/lib/varnish/vmods/
