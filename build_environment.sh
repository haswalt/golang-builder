#!/bin/bash

tagName=$1

if [ "$(ls -A /src 2> /dev/null)" == "" ];
then
  echo "Error: Must mount Go source code into /src directory"
  exit 990
fi

# Grab Go package name from glide
pkgName="$(glide name 2>/dev/null || true)"

# If no package name check for import path
if [ -z "$pkgName" ];
then
  pkgName="$(go list -e -f '{{.ImportComment}}' 2>/dev/null || true)"
fi

if [ -z "$pkgName" ];
then
  echo "Error: Must add canonical import path to root package"
  exit 992
fi

# Grab just first path listed in GOPATH
goPath="${GOPATH%%:*}"

# Construct Go package path
pkgPath="$goPath/src/$pkgName"

# Set-up src directory tree in GOPATH
mkdir -p "$(dirname "$pkgPath")"

# Copy source dir into GOPATH
cp -R /src "$pkgPath"

builder='go'

if [ -e "$pkgPath/Gomfile" ];
then
    builder='gom'
    if [ -d "$pkgPath/vendor" ];
    then
        echo "Installing deps with gom"
        gom install
    fi
elif [ -e "$pkgPath/glide.yaml" ];
then
  # Install deps with glide
  echo "Installing deps with glide"
  glide install
elif [ -e "$pkgPath/vendor" ];
then
  # Enable vendor experiment
  echo "Using experimental vendoring"
  export GO15VENDOREXPERIMENT=1
elif [ -e "$pkgPath/Godeps/_workspace" ];
then
  # Add local godeps dir to GOPATH
  echo "Using deps from Godeps workspace"
  GOPATH=$pkgPath/Godeps/_workspace:$GOPATH
  builder='godep go'
else
  # Get all package dependencies
  echo "Attempting to download all deps"
  go get -t -d -v ./...
fi
