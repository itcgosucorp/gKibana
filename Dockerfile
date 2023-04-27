# ========== BUILDER IMAGE ==========
FROM ubuntu:20.04 as builder

ENV KIBANA_USER kibana
ENV KIBANA_PASSWORD=sysA@123

# Add sudoer kibana
RUN adduser ${KIBANA_USER}
RUN echo ${KIBANA_USER}:${KIBANA_PASSWORD} | chpasswd
RUN usermod -aG sudo ${KIBANA_USER}

# Install sudo cmd
RUN apt-get -y update
RUN apt-get -y install sudo

# Switch to kibana user
USER ${KIBANA_USER}

# Install necessary ubuntu's packages
RUN echo ${KIBANA_PASSWORD} | sudo -S apt-get install -y curl
RUN echo ${KIBANA_PASSWORD} | sudo -S apt-get -y install git

# Install node 16.19.1
ENV NODE_VERSION=16.19.1
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/home/${KIBANA_USER}/.nvm
RUN . "${NVM_DIR}/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "${NVM_DIR}/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "${NVM_DIR}/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN npm i -g yarn

# Copy src to image
COPY --chown=kibana:kibana . /usr/share/kibana
WORKDIR /usr/share/kibana

# Install kibana's packages
RUN yarn kbn clean && yarn kbn bootstrap

# Build kibana
RUN yarn build --skip-os-packages --skip-archives

# ========== MAIN IMAGE ==========
FROM ubuntu:20.04 as main
EXPOSE 5601

RUN for iter in {1..10}; do \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update  && \
  apt-get upgrade -y  && \
  apt-get install -y --no-install-recommends \
  fontconfig fonts-liberation libnss3 libfontconfig1 ca-certificates curl && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && exit_code=0 && break || exit_code=$? && echo "apt-get error: retry $iter in 10s" && \
  sleep 10; \
  done; \
  (exit $exit_code)

# Add an init process, check the checksum to make sure it's a match
RUN set -e ; \
  TINI_BIN="" ; \
  case "$(arch)" in \
  aarch64) \
  TINI_BIN='tini-arm64' ; \
  ;; \
  x86_64) \
  TINI_BIN='tini-amd64' ; \
  ;; \
  *) echo >&2 "Unsupported architecture $(arch)" ; exit 1 ;; \
  esac ; \
  TINI_VERSION='v0.19.0' ; \
  curl --retry 8 -S -L -O "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/${TINI_BIN}" ; \
  curl --retry 8 -S -L -O "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/${TINI_BIN}.sha256sum" ; \
  sha256sum -c "${TINI_BIN}.sha256sum" ; \
  rm "${TINI_BIN}.sha256sum" ; \
  mv "${TINI_BIN}" /bin/tini ; \
  chmod +x /bin/tini

RUN mkdir /usr/share/fonts/local
RUN curl --retry 8 -S -L -o /usr/share/fonts/local/NotoSansCJK-Regular.ttc https://github.com/googlefonts/noto-cjk/raw/NotoSansV2.001/NotoSansCJK-Regular.ttc
RUN echo "5dcd1c336cc9344cb77c03a0cd8982ca8a7dc97d620fd6c9c434e02dcb1ceeb3  /usr/share/fonts/local/NotoSansCJK-Regular.ttc" | sha256sum -c -
RUN fc-cache -v

# Bring in Kibana from the initial stage.
COPY --from=builder --chown=1000:0 /usr/share/kibana/build/default/kibana-8.7.1-SNAPSHOT-linux-x86_64 /usr/share/kibana
WORKDIR /usr/share/kibana
RUN ln -s /usr/share/kibana /opt/kibana

ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/kibana/bin:$PATH

# Set some Kibana configuration defaults.
COPY --from=builder --chown=1000:0 /usr/share/kibana/build/kibana-docker/default/config/kibana.yml /usr/share/kibana/config/kibana.yml

# Add the launcher/wrapper script. It knows how to interpret environment
# variables and translate them to Kibana CLI options.
COPY --from=builder /usr/share/kibana/build/kibana-docker/default/bin/kibana-docker /usr/local/bin/
RUN chmod +x /usr/local/bin/kibana-docker
RUN chown root:root /usr/local/bin/kibana-docker

# Ensure gid 0 write permissions for OpenShift.
RUN chmod g+ws /usr/share/kibana && \
  find /usr/share/kibana -gid 0 -and -not -perm /g+w -exec chmod g+w {} \;

# Remove the suid bit everywhere to mitigate "Stack Clash"
RUN find / -xdev -perm -4000 -exec chmod u-s {} +

# Provide a non-root user to run the process.
RUN groupadd --gid 1000 kibana && \
  useradd --uid 1000 --gid 1000 -G 0 \
  --home-dir /usr/share/kibana --no-create-home \
  kibana

LABEL org.label-schema.build-date="2022-08-18T04:31:00.159Z" \
  org.label-schema.license="Elastic License" \
  org.label-schema.name="Kibana" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://www.elastic.co/products/kibana" \
  org.label-schema.usage="https://www.elastic.co/guide/en/kibana/reference/index.html" \
  org.label-schema.vcs-ref="1a6d6cc16aa3f822d967c85ed4bbeb2223ef15b6" \
  org.label-schema.vcs-url="https://github.com/elastic/kibana" \
  org.label-schema.vendor="Elastic" \
  org.label-schema.version="8.7.1-SNAPSHOT" \
  org.opencontainers.image.created="2022-08-18T04:31:00.159Z" \
  org.opencontainers.image.documentation="https://www.elastic.co/guide/en/kibana/reference/index.html" \
  org.opencontainers.image.licenses="Elastic License" \
  org.opencontainers.image.revision="1a6d6cc16aa3f822d967c85ed4bbeb2223ef15b6" \
  org.opencontainers.image.source="https://github.com/elastic/kibana" \
  org.opencontainers.image.title="Kibana" \
  org.opencontainers.image.url="https://www.elastic.co/products/kibana" \
  org.opencontainers.image.vendor="Elastic" \
  org.opencontainers.image.version="8.7.1-SNAPSHOT"

ENTRYPOINT ["/bin/tini", "--"]

# Change CRLF to LF
RUN sed -i -e 's/\r$//' /usr/local/bin/kibana-docker
RUN sed -i -e 's/\r$//' /usr/share/kibana/bin/kibana
RUN sed -i -e 's/\r$//' config/node.options

# Chmode +x
RUN chmod +x bin/kibana

CMD ["/usr/local/bin/kibana-docker"]

USER kibana