FROM debian:bookworm

# Dependencies
RUN apt update && \
    apt install -y --no-install-recommends \
        curl \
        wget \
        unzip \
        ca-certificates \
        fontconfig && \
    rm -rf /var/lib/apt/lists/*

# Install Godot
RUN wget https://github.com/godotengine/godot/releases/download/4.7-stable/Godot_v4.7-stable_linux.x86_64.zip && \
    unzip Godot_v4.7-stable_linux.x86_64.zip && \
    mv Godot_v4.7-stable_linux.x86_64 /usr/local/bin/godot && \
    chmod +x /usr/local/bin/godot && \
    rm Godot_v4.7-stable_linux.x86_64.zip

# Install export templates
# RUN mkdir -p /root/.local/share/godot/export_templates/4.7.stable && \
#     wget https://github.com/godotengine/godot/releases/download/4.7-stable/Godot_v4.7-stable_export_templates.tpz && \
#     unzip Godot_v4.7-stable_export_templates.tpz && \
#     cp templates/linux_release.x86_64 \
#         /root/.local/share/godot/export_templates/4.7.stable/ && \
#     cp templates/version.txt \
#         /root/.local/share/godot/export_templates/4.7.stable/ && \
#     rm -rf templates Godot_v4.7-stable_export_templates.tpz

RUN mkdir -p /root/.local/share/godot/export_templates/4.7.stable

# Lets hold a minut the server builder
# COPY templates/linux_release.x86_64 \
# 	/root/.local/share/godot/export_templates/4.7.stable/

COPY templates/web_release.zip \
	/root/.local/share/godot/export_templates/4.7.stable/

COPY templates/web_nothreads_debug.zip \
	/root/.local/share/godot/export_templates/4.7.stable/

COPY templates/web_nothreads_release.zip \
	/root/.local/share/godot/export_templates/4.7.stable/

COPY templates/version.txt \
	/root/.local/share/godot/export_templates/4.7.stable/

WORKDIR /workspace

COPY export.sh /usr/local/bin/export.sh
RUN chmod +x /usr/local/bin/export.sh

ENTRYPOINT ["/usr/local/bin/export.sh"]