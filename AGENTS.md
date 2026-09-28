## Agent skills

### Issue tracker
使用本地 Markdown 管理规格与任务，存放在 `.scratch/`。
详见 `docs/agents/issue-tracker.md`。

### Domain docs
使用单一领域上下文：根目录 `CONTEXT.md` 和 `docs/adr/`。
详见 `docs/agents/domain.md`。

### Build
使用根目录 Makefile 测试、构建与验收：`make test` 跑测试，`make build` 跳过测试打包，`make accept` 测试通过后构建并覆盖 `dist/yi_app.app`，`make clean` 清理。Flutter SDK 不在 PATH 时由脚本回退到 `~/development/flutter`，无需手动配置。
详见 `scripts/build_app.sh`。
