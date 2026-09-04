package xctx_test

import (
	"context"
	"fmt"

	"github.com/headstack/xctx"
)

func Example() {
	ctx := xctx.DeriveWithGeneratedXReqIDv7(context.Background())

	reqID := xctx.GetXReqID(ctx)

	fmt.Println(reqID != "")
	// Output: true
}
