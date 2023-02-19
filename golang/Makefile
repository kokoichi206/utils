DB_URL=postgresql://root:account@localhost:5432/account_book?sslmode=disable

.PHONY: build help bootstrap godoc
.DEFAULT_GOAL := help

EXTERNAL_TOOLS := \
	github.com/golangci/golangci-lint/cmd/golangci-lint@v1.51.1 \
	golang.org/x/pkgsite/cmd/pkgsite@latest # latest は go 1.19 以上が必要: https://github.com/golang/pkgsite#requirements

postgres:
	docker run --name postgres12 --network account-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=account -d postgres:12-alpine

createdb:
	docker exec -it postgres12 createdb --username=root --owner=root account_book

dropdb:
	docker exec -it postgres12 dropdb account_book

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

sqlc:
	sqlc generate

test:	## 全テストを実行
	go test -cover -shuffle=on ./... -v

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/querier.go github.com/kokoichi206/account-book-api/db/sqlc Querier

.PHONY: test server sqlc mock

help:	## https://postd.cc/auto-documented-makefile/
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

bootstrap: ## 外部ツールをインストールする。
	for t in $(EXTERNAL_TOOLS); do \
		echo "Installing $$t ..." ; \
		go install $$t ; \
	done

godoc:	## godoc をローカルで表示する。http://localhost:8080/{module_name}
	pkgsite

.PHONY: lint serve

lint:	## golangci を使って lint を走らせる
	golangci-lint run -v

lint-fix:	## lint 実行時, gofumpt のエラーが出たらやると良い
	golangci-lint run --fix

serve:	## サーバーを起動する
	go run main.go
