FROM node:22-bookworm

# Install core tools: vim, curl, git, python3, pip
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        vim \
        curl \
        git \
        python3 \
        python3-pip \
        ca-certificates \
        ssh \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Enable corepack for pnpm
RUN corepack enable

WORKDIR /app

# Allow dynamic apt packages via build arg
ARG EXTRA_APT_PACKAGES=""
RUN if [ -n "$EXTRA_APT_PACKAGES" ]; then \
      apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $EXTRA_APT_PACKAGES && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*; \
    fi

# Default command
CMD ["bash"]
