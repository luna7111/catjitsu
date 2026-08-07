#!/usr/bin/env bash

set -e

SRC="tos-pp"
DST="client/web"

echo "Copying Terms of Service and Privacy Policy..."

mkdir -p "$DST"

cp -r "$SRC"/* "$DST"/

echo "Done!"