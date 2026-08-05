#!/usr/bin/env bash

set -e

echo "======================================"
echo "Exporting CatJitsu Client..."
echo "======================================"

cd /workspace/catjitsu-client

mkdir -p /workspace/client/web

godot --headless \
    --path . \
    --export-release "Web" \
    /workspace/client/web/catjitsu.html \
	>/dev/null 2>&1


echo
echo "======================================"
echo "Exporting CatJitsu Server..."
echo "======================================"

cd /workspace/catjitsu-server

mkdir -p /workspace/server/build

godot --headless \
    --path . \
    --export-release "Linux" \
    /workspace/server/build/catjitsu-server.x86_64 \
	>/dev/null 2>&1


echo
echo "======================================"
echo "Export completed successfully!"
echo "======================================"