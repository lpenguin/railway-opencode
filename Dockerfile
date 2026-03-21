FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV MISE_YES=1
ENV MISE_DATA_DIR=/home/opencode/.local/share/mise
ENV MISE_CONFIG_DIR=/home/opencode/.config/mise

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    chromium \
    chromium-sandbox \
    fonts-liberation \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libcairo2 \
    libcups2 \
    libxkbcommon0 \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Entrypoint (copy while still root)
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Non-root user
RUN useradd -m -s /bin/bash opencode
USER opencode
WORKDIR /home/opencode

# Install mise
RUN curl https://mise.run | sh
ENV PATH="/home/opencode/.local/bin:${PATH}"
SHELL ["/bin/bash", "-c"]

# Copy tool config and install runtimes
COPY --chown=opencode:opencode .mise.toml .mise.toml
RUN mise install && mise reshim

# Install opencode and agent-browser via npm
# agent-browser uses system chromium (set via CHROME_PATH), no need for agent-browser install
RUN eval "$(mise activate bash)" && \
    npm install -g opencode-ai agent-browser

# Copy custom skills source
COPY --chown=opencode:opencode skills/ skills/

# Install all skills (opencode agent only)
RUN eval "$(mise activate bash)" && \
    npx skills add railwayapp/railway-skills -a opencode -y && \
    npx skills add ./skills -a opencode -y
RUN rm -rf skills/ skills-lock.json

ENV CHROME_PATH=/usr/bin/chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV CHROMIUM_PATH=/usr/bin/chromium

EXPOSE 4096
ENTRYPOINT ["entrypoint.sh"]
