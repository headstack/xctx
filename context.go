// Package xctx carries an X-Req-ID request identifier through a context.Context,
// so it can be set once (e.g. at the edge of a service) and read anywhere downstream.
package xctx

import (
	"context"

	"github.com/google/uuid"
)

type xReqIDKey string

const xReqIDKeyHeader xReqIDKey = "x-req-id"

// SetXReqID returns a copy of ctx carrying u as the request id.
// It returns nil if ctx is nil.
func SetXReqID(ctx context.Context, u uuid.UUID) context.Context {
	if ctx == nil {
		return nil
	}
	return context.WithValue(ctx, xReqIDKeyHeader, u.String())
}

// DeriveWithGeneratedXReqIDv7 returns a copy of ctx carrying a freshly generated
// UUIDv7 as the request id. It returns nil if ctx is nil.
func DeriveWithGeneratedXReqIDv7(ctx context.Context) context.Context {
	if ctx == nil {
		return nil
	}
	u, err := uuid.NewV7()
	if err != nil {
		// u - because uuid.NewV7 return uuid.Nil in error case, which implements Stringer interface.
		return SetXReqID(ctx, u)
	}
	return SetXReqID(ctx, u)
}

// GetXReqID returns the request id stored in ctx, or the nil UUID string
// ("00000000-0000-0000-0000-000000000000") if ctx is nil or carries no request id.
func GetXReqID(ctx context.Context) string {
	nilUUID := uuid.Nil.String()
	if ctx == nil {
		return nilUUID
	}
	switch ctx.Value(xReqIDKeyHeader).(type) {
	case string:
		val, ok := ctx.Value(xReqIDKeyHeader).(string)
		if !ok {
			return nilUUID
		}
		return val
	default:
		return nilUUID
	}
}
