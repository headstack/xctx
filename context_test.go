package xctx

import (
	"context"
	"testing"

	"github.com/google/uuid"
)

func TestSetXReqID(t *testing.T) {
	t.Run("nil context returns nil", func(t *testing.T) {
		//nolint:staticcheck // intentionally passing nil context to exercise the guard clause
		got := SetXReqID(nil, uuid.New())
		if got != nil {
			t.Fatalf("expected nil context, got %v", got)
		}
	})

	t.Run("stores the given uuid as string", func(t *testing.T) {
		u := uuid.New()
		ctx := SetXReqID(context.Background(), u)

		val, ok := ctx.Value(xReqIDKeyHeader).(string)
		if !ok {
			t.Fatalf("expected string value stored under xReqIDKeyHeader, got %T", ctx.Value(xReqIDKeyHeader))
		}
		if val != u.String() {
			t.Fatalf("expected %q, got %q", u.String(), val)
		}
	})

	t.Run("overwrites a previously set value", func(t *testing.T) {
		first := uuid.New()
		second := uuid.New()

		ctx := SetXReqID(context.Background(), first)
		ctx = SetXReqID(ctx, second)

		if got := GetXReqID(ctx); got != second.String() {
			t.Fatalf("expected %q, got %q", second.String(), got)
		}
	})
}

func TestDeriveWithGeneratedXReqIDv7(t *testing.T) {
	t.Run("nil context returns nil", func(t *testing.T) {
		//nolint:staticcheck // intentionally passing nil context to exercise the guard clause
		got := DeriveWithGeneratedXReqIDv7(nil)
		if got != nil {
			t.Fatalf("expected nil context, got %v", got)
		}
	})

	t.Run("derives a context carrying a valid uuid v7", func(t *testing.T) {
		ctx := DeriveWithGeneratedXReqIDv7(context.Background())

		got := GetXReqID(ctx)
		parsed, err := uuid.Parse(got)
		if err != nil {
			t.Fatalf("expected a parsable uuid, got %q: %v", got, err)
		}
		if parsed.Version() != uuid.Version(7) { //nolint:mnd // uuid v7 version identifier
			t.Fatalf("expected uuid version 7, got %d", parsed.Version())
		}
	})

	t.Run("generated ids are unique across calls", func(t *testing.T) {
		first := GetXReqID(DeriveWithGeneratedXReqIDv7(context.Background()))
		second := GetXReqID(DeriveWithGeneratedXReqIDv7(context.Background()))

		if first == second {
			t.Fatalf("expected distinct request ids, got the same value %q twice", first)
		}
	})
}

func TestGetXReqID(t *testing.T) {
	nilUUID := uuid.Nil.String()

	t.Run("nil context returns the nil uuid", func(t *testing.T) {
		//nolint:staticcheck // intentionally passing nil context to exercise the guard clause
		if got := GetXReqID(nil); got != nilUUID {
			t.Fatalf("expected %q, got %q", nilUUID, got)
		}
	})

	t.Run("context without a stored value returns the nil uuid", func(t *testing.T) {
		if got := GetXReqID(context.Background()); got != nilUUID {
			t.Fatalf("expected %q, got %q", nilUUID, got)
		}
	})

	t.Run("context with a non-string value returns the nil uuid", func(t *testing.T) {
		ctx := context.WithValue(context.Background(), xReqIDKeyHeader, 123) //nolint:mnd // arbitrary non-string sentinel

		if got := GetXReqID(ctx); got != nilUUID {
			t.Fatalf("expected %q, got %q", nilUUID, got)
		}
	})

	t.Run("context with a stored value returns it", func(t *testing.T) {
		u := uuid.New()
		ctx := SetXReqID(context.Background(), u)

		if got := GetXReqID(ctx); got != u.String() {
			t.Fatalf("expected %q, got %q", u.String(), got)
		}
	})
}
