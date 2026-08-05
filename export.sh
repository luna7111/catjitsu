#!/usr/bin/env bash

set -e

echo "======================================"
echo "Exporting CatJitsu Web client..."
echo "======================================"

cd /workspace/catjitsu-client

mkdir -p /workspace/client/web

godot --headless \
    --path . \
    --export-release "Web" \
    /workspace/client/web/catjitsu.html