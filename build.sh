#!/bin/bash -e

source /build_environment.sh


echo "Building $pkgName"
`CGO_ENABLED=${CGO_ENABLED:-0} $builder build -a --installsuffix cgo --ldflags="${LDFLAGS:--s}" $pkgName`
