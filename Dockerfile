FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/agent
ENV WORKDIR=/workspace

# Dependencias necesarias para instalar code-server
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Crea un usuario no privilegiado equivalente al usuario del sandbox
RUN useradd --create-home --shell /bin/bash agent \
    && mkdir -p /workspace \
    && chown -R agent:agent /workspace /home/agent

# Instala code-server desde el instalador oficial
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Instala la extensión Claude Code como el usuario agent
USER agent

RUN code-server --install-extension anthropic.claude-code

WORKDIR /workspace

EXPOSE 8080

# Inicia VS Code web en el puerto 8080.
# ATENCIÓN: --auth none deja el servidor sin contraseña.
CMD ["sh", "-c", "code-server --bind-addr 0.0.0.0:8080 --auth none \"${WORKDIR:-/workspace}\""]
