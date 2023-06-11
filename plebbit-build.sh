#!/usr/bin/env bash

# go to current folder
cd "$(dirname "$0")"

rm -fr dist
mkdir -p dist

# build linux amd64
make build GOOS=linux GOARCH=amd64
mv cmd/ipfs/ipfs dist/ipfs-linux-amd64

# build linux arm64
make build GOOS=linux GOARCH=arm64
mv cmd/ipfs/ipfs dist/ipfs-linux-arm64

# build mac amd64
make build GOOS=darwin GOARCH=amd64
mv cmd/ipfs/ipfs dist/ipfs-darwin-amd64

# build windows amd64
make build GOOS=windows GOARCH=amd64
mv cmd/ipfs/ipfs dist/ipfs-windows-amd64
