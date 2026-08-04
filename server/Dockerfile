FROM debian:bookworm

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

# Install Linux export templates
RUN wget https://github.com/godotengine/godot/releases/download/4.7-stable/Godot_v4.7-stable_export_templates.tpz && \
    mkdir -p /root/.local/share/godot/export_templates/4.7.stable && \
    unzip Godot_v4.7-stable_export_templates.tpz && \
    cp -r templates/* /root/.local/share/godot/export_templates/4.7.stable/ && \
    rm -rf templates Godot_v4.7-stable_export_templates.tpz

# RUN mkdir -p /root/.local/share/godot/export_templates/4.7.stable

# COPY templates/linux_release.x86_64 \
# 	/root/.local/share/godot/export_templates/4.7.stable/

# COPY templates/version.txt \
# 	/root/.local/share/godot/export_templates/4.7.stable/


# Copy project
COPY catjitsu-server /catjitsu-server

WORKDIR /catjitsu-server


# Export server
RUN mkdir -p build && \
	godot --headless --export-release "Linux"


# Runtime folder
WORKDIR /catjitsu-server/build


# Entrypoint
COPY catjitsu-server/docker-entrypoint.sh .

RUN chmod +x docker-entrypoint.sh


EXPOSE 8080


CMD ["./docker-entrypoint.sh"]