# golang-builder
[![](https://badge.imagelayers.io/haswalt/golang-builder.svg)](https://imagelayers.io/?images=haswalt/golang-builder:latest 'Get your own badge on imagelayers.io')

Containerized build environment for compiling an executable Golang package.

## Requirements
In order for the golang-builder to work properly with your project, you need to follow a few simple conventions:

### Project Structure
The *golang-builder* assumes that your "main" package (the package containing your executable command) is at the root of your project directory structure.

    .
    ├─Dockerfile
    ├─api
    | ├─api.go
    | └─api_test.go
    ├─greeting
    | ├─greeting.go
    | └─greeting_test.go
    ├─hello.go
    └─hello_test.go

In the example above, the `hello.go` source file defines the "main" package for this project and lives at the root of the project directory structure. This project defines other packages ("api" and "greeting") but those are subdirectories off the root.

This convention is in place so that the *golang-builder* knows where to find the "main" package in the project structure. In a future release, we may make this a configurable option in order to support projects with different directory structures.

### Canonical Import Path
In addition to knowing where to find the "main" package, the *golang-builder* also needs to know the fully-qualified package name for your application. For the "hello" application shown above, the fully-qualified package name for the executable is "github.com/haswalt/hello" but there is no way to determine that just by looking at the project directory structure (during the development, the project directory would likely be mounted at `$GOPATH/src/github.com/haswalt/hello` so that the Go tools can determine the package name).

In version 1.4 of Go an annotation was introduced which allows you to identify the [canonical import path](https://golang.org/doc/go1.4#canonicalimports) as part of your source code. The annotation is a specially formatted comment that appears immediately after the `package` clause:

    package main // import "github.com/haswalt/hello"

The *golang-builder* will read this annotation from your source code and use it to mount the source code into the proper place in the GOPATH for compilation.

### Dependencies
The *golang-builder* supports several ways of installing dependencies:

 * If a vendor directory is present then experimental support is enabled.
 * If a [glide](https://github.com/Masterminds/glide) configuration file is present then [glide](https://github.com/Masterminds/glide) is used to install the dependencies.
 * If a Godeps workspace is detected then it is added to the GOPATH
 * Finally if none of the above are found then the *golang-builder* will attempt to go get all dependencies.

## Usage

There is only one thing that the *golang-builder* needs to compile your application:

* Access to your source code. Inject your source code into the container by mounting it at the `/src` mount point with the `-v` flag.
Assuming that the source code for your Go executable package is located at
`/home/go/src/github.com/haswalt/hello` on your local system and you're currently in the `hello` directory, you'd run the `golang-builder` container as follows:

    docker run --rm -v $(pwd):/src haswalt/golang-builder

### Additional Options

* CGO_ENABLED - whether or not to compile the binary with CGO (defaults to false)
* LDFLAGS - flags to pass to the linker (defaults to '-s')

The above are environment variables to be passed to the docker run command:

    docker run --rm \
      -e CGO_ENABLED=true \
      -e LDFLAGS='-extldflags "-static"' \
      -v $(pwd):/src \
      haswalt/golang-builder
