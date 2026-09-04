LIB_NAME ?= $$(grep "module" go.mod | awk '{print $$2}' | xargs -n 1 basename)
COVER_FILE ?= $(LIB_NAME).coverage
COVERINGORE_CONFIG_LOCAL=./.coverignore

DOC_CMD_VERSION ?= v1.4.2
DOC_CMD ?= goreadme -types -constants -factories -functions -methods -variabless -credit=false
DOC_FILE ?= README.md

tools-current:
	go install github.com/mfridman/tparse@v0.17.0

tools-update:
	go install github.com/mfridman/tparse@latest

mod:
	go mod tidy

lint:
	golangci-lint run --timeout 10m

lint-fix:
	golangci-lint run --timeout 10m --fix

build:
	go build -o /dev/null ./...

test:
	go clean -testcache
	go test --short -coverprofile=$(COVER_FILE).tmp ./... -json | grep -v -f $(COVERINGORE_CONFIG_LOCAL) | tparse -all
	@grep -v -f $(COVERINGORE_CONFIG_LOCAL) $(COVER_FILE).tmp > $(COVER_FILE)
	@rm $(COVER_FILE).tmp
	@go tool cover -func=$(COVER_FILE) | grep ^total
	@rm -f $(COVER_FILE)

check: mod lint build test

autodoc:
	@echo "Updating documenting golang command up to selected version, which is $(DOC_CMD_VERSION)"
	@go install github.com/posener/goreadme/cmd/goreadme@$(DOC_CMD_VERSION)
	@echo "Preparing $(DOC_FILE) documentation for $(LIB_NAME) module"
	@$(DOC_CMD) > $(DOC_FILE)
	@for PKG in $$(go list -f '{{.Dir}}' ./...); do \
		echo "Preparing $(DOC_FILE) documentation for $$PKG"; \
		cd $$PKG && $(DOC_CMD) > $(DOC_FILE); \
	done
	@echo "Done! All the project documents are up to date!"

pre-commit: check autodoc
	git status
