# xctx

Package xctx carries an X-Req-ID request identifier through a context.Context,
so it can be set once (e.g. at the edge of a service) and read anywhere downstream.

## Functions

### func [DeriveWithGeneratedXReqIDv7](/context.go#L26)

`func DeriveWithGeneratedXReqIDv7(ctx context.Context) context.Context`

DeriveWithGeneratedXReqIDv7 returns a copy of ctx carrying a freshly generated
UUIDv7 as the request id. It returns nil if ctx is nil.

### func [GetXReqID](/context.go#L40)

`func GetXReqID(ctx context.Context) string`

GetXReqID returns the request id stored in ctx, or the nil UUID string
("00000000-0000-0000-0000-000000000000") if ctx is nil or carries no request id.

### func [SetXReqID](/context.go#L17)

`func SetXReqID(ctx context.Context, u uuid.UUID) context.Context`

SetXReqID returns a copy of ctx carrying u as the request id.
It returns nil if ctx is nil.
