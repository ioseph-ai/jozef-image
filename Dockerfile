FROM node:22-bookworm AS builder

# Install build dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        git \
        ca-certificates \
        python3 \
        make \
        g++ \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Enable corepack for pnpm
RUN corepack enable

# Clone and build OpenClaw
WORKDIR /build
RUN git clone --depth 1 https://github.com/openclaw/openclaw.git . && \
    pnpm install --frozen-lockfile && \
    OPENCLAW_A2UI_SKIP_MISSING=1 pnpm build && \
    OPENCLAW_PREFER_PNPM=1 pnpm ui:build

# Production stage
FROM node:22-bookworm

# Install runtime tools: vim, curl, git, python3, pip, ssh
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

# Install Bun (runtime)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Enable corepack for pnpm
RUN corepack enable

# Copy built OpenClaw from builder
WORKDIR /app
COPY --from=builder /build/package.json /build/pnpm-lock.yaml /build/pnpm-workspace.yaml ./
COPY --from=builder /build/node_modules ./node_modules
COPY --from=builder /build/openclaw.mjs ./
COPY --from=builder /build/dist ./dist
COPY --from=builder /build/skills ./skills
COPY --from=builder /build/assets ./assets
COPY --from=builder /build/docs ./docs
COPY --from=builder /build/extensions ./extensions

# Create workspace directory
RUN mkdir -p /home/node/.openclaw/workspace && \
    chown -R node:node /home/node/.openclaw

# Allow extra packages via build arg
ARG EXTRA_APT_PACKAGES=""
RUN if [ -n "$EXTRA_APT_PACKAGES" ]; then \
      apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $EXTRA_APT_PACKAGES && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*; \
    fi

# Security: Run as non-root
USER node

# Environment
ENV NODE_ENV=production
ENV OPENCLAW_PREFER_PNPM=1

# Default: start gateway
CMD ["node", "openclaw.mjs", "gateway", "--allow-unconfigured"]
