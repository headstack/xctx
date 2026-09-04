# xctx

[![CI](https://github.com/headstack/xctx/actions/workflows/ci.yml/badge.svg)](https://github.com/headstack/xctx/actions/workflows/ci.yml)
[![Go Reference](https://pkg.go.dev/badge/github.com/headstack/xctx.svg)](https://pkg.go.dev/github.com/headstack/xctx)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A tiny Go package for carrying an `X-Req-ID` request identifier through a `context.Context`.

## Install

```bash
go get github.com/headstack/xctx
```

Pin a specific released version instead of the latest commit on `main`:

```bash
go get github.com/headstack/xctx@v0.1.0
```

## Usage

```go
import "github.com/headstack/xctx"

ctx := xctx.DeriveWithGeneratedXReqIDv7(context.Background())
reqID := xctx.GetXReqID(ctx)
```

## Versioning

This module follows [Semantic Versioning](https://semver.org/) via Git tags of the form
`vMAJOR.MINOR.PATCH` (e.g. `v0.1.0`), which is how the Go module system resolves versions —
there's no separate release/publish step beyond pushing the tag.

To cut a new release:

```bash
git tag -a v0.1.0 -m "v0.1.0"
git push origin v0.1.0
```

Consumers can then depend on that exact version with `go get github.com/headstack/xctx@v0.1.0`,
or pick up the newest tagged release with `go get github.com/headstack/xctx@latest`.
`go get github.com/headstack/xctx` (no version suffix) also resolves to the latest tagged version
when the module is already a dependency — Go only tracks `main` for a module that hasn't been tagged yet.

> Note: a `v2.0.0+` (breaking-change) release requires the module path itself to gain a `/v2`
> suffix (`github.com/headstack/xctx/v2`) per Go's
> [semantic import versioning](https://go.dev/ref/mod#major-version-suffixes) rules. `v0`/`v1` need no suffix.

## Functions

### func [DeriveWithGeneratedXReqIDv7](/context.go#L20)

`func DeriveWithGeneratedXReqIDv7(ctx context.Context) context.Context`

### func [GetXReqID](/context.go#L32)

`func GetXReqID(ctx context.Context) string`

### func [SetXReqID](/context.go#L13)

`func SetXReqID(ctx context.Context, u uuid.UUID) context.Context`
