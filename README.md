# xctx

A tiny Go package for carrying an `X-Req-ID` request identifier through a `context.Context`.

## Install

```bash
go get github.com/headstack/xctx
```

## Usage

```go
import "github.com/headstack/xctx"

ctx := xctx.DeriveWithGeneratedXReqIDv7(context.Background())
reqID := xctx.GetXReqID(ctx)
```

## Functions

### func [DeriveWithGeneratedXReqIDv7](/context.go#L20)

`func DeriveWithGeneratedXReqIDv7(ctx context.Context) context.Context`

### func [GetXReqID](/context.go#L32)

`func GetXReqID(ctx context.Context) string`

### func [SetXReqID](/context.go#L13)

`func SetXReqID(ctx context.Context, u uuid.UUID) context.Context`
