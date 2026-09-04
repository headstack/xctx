package xctx

import (
	"context"

	"github.com/google/uuid"
)

type xReqIDKey string

const xReqIDKeyHeader xReqIDKey = "x-req-id"

func SetXReqID(ctx context.Context, u uuid.UUID) context.Context {
	if ctx == nil {
		return nil
	}
	return context.WithValue(ctx, xReqIDKeyHeader, u.String())
}

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
