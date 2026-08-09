FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install core dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install nvm + Node.js LTS
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=20
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install "$NODE_VERSION" \
    && nvm alias default "$NODE_VERSION"

ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin:${PATH}"

WORKDIR /test

COPY install.sh /test/install.sh
COPY tests/test-install.sh /test/test-install.sh

RUN chmod +x /test/install.sh /test/test-install.sh

ENTRYPOINT ["/bin/bash", "/test/test-install.sh"]
