FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/agent
ENV WORKDIR=/workspace

# Instala dependencias necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Crea el usuario no privilegiado.
# No se fija UID=1000 porque Ubuntu ya puede tenerlo ocupado.
RUN useradd --create-home --shell /bin/bash agent \
    && mkdir -p /workspace \
    && chown -R agent:agent /workspace /home/agent

# Instala code-server mediante el script oficial
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Instala la extensión de Claude Code para code-server
USER agent

RUN code-server --install-extension anthropic.claude-code

WORKDIR /workspace

EXPOSE 8080

# Inicia VS Code web en el puerto 8080
CMD ["sh", "-c", "code-server --bind-addr 0.0.0.0:8080 --auth none \"${WORKDIR:-/workspace}\""]
