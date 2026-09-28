.PHONY: help test build accept clean

help: ## 列出所有命令
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-8s %s\n", $$1, $$2}'

test: ## 只跑 flutter test
	@scripts/build_app.sh test

build: ## 跳过测试：release 构建并覆盖 dist/yi_app.app
	@scripts/build_app.sh build

accept: test build ## 完整验收：测试通过后构建（任何一步失败即中断）
	@echo "✅ 验收构建完成：dist/yi_app.app"

clean: ## flutter clean 并删除 dist/yi_app.app
	@scripts/build_app.sh clean
