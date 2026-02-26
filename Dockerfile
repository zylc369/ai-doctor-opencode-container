FROM ubuntu:22.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    sudo \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Install OpenCode
RUN curl -fsSL https://opencode.ai/install | bash

# Create user 'aiuser' with password (for sudo access)
RUN useradd -m -s /bin/bash aiuser && \
    echo "aiuser:Lcnihao2010" | chpasswd && \
    echo "aiuser ALL=(ALL) ALL" >> /etc/sudoers

# Copy opencode and bun to aiuser's home
RUN mkdir -p /home/aiuser/.opencode && \
    cp -r /root/.opencode/* /home/aiuser/.opencode/ && \
    mkdir -p /home/aiuser/.bun && \
    cp -r /root/.bun/* /home/aiuser/.bun/

# Copy opencode config
RUN mkdir -p /home/aiuser/.config/opencode

# Switch to user directory
WORKDIR /home/aiuser

# Create Codes directory
RUN mkdir -p /home/aiuser/Codes

# Clone ai-doctor-opencode repository to ~/Codes/ai-doctor-opencode
RUN git clone https://github.com/zylc369/ai-doctor-opencode.git /home/aiuser/Codes/ai-doctor-opencode

# Create notes directory
RUN mkdir -p /home/aiuser/Codes/ai-doctor-opencode/notes

# Install oh-my-opencode (with OpenCode Zen for free models)
RUN cd /home/aiuser && \
    /home/aiuser/.bun/bin/bunx oh-my-opencode install --no-tui --claude=no --openai=no --gemini=no --copilot=no --opencode-zen=yes

# Copy oh-my-opencode.json config
COPY oh-my-opencode.json /home/aiuser/.config/opencode/oh-my-opencode.json

# Ensure proper ownership
RUN chown -R aiuser:aiuser /home/aiuser

# Set PATH environment variable for runtime
ENV PATH="/home/aiuser/.opencode/bin:/home/aiuser/.bun/bin:$PATH"

# Switch to non-root user
USER aiuser

# Expose port
EXPOSE 4096
