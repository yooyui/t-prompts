# AI 助手配置系统 v3.1

> **⚠️ 实验性项目**
>
> 这是一个实验性质的设想，旨在探索 Claude Code 模块化配置的可能性。

基于 Claude Code 的模块化 AI 助手配置框架，支持按需加载、斜杠命令和开发记录管理。

## 快速开始

### 对话式使用

直接用自然语言与 AI 助手对话即可：

```
你：初始化开发记录系统
你：加载代码规范模块
你：加载测试模块
你：执行安全检查
你：应用 TDD 策略
```

### 斜杠命令

也可以使用斜杠命令：

```bash
/load workflow              # 加载单个模块
/load principles, testing   # 加载多个模块
/init react-app             # 初始化项目
/apply tdd                  # 应用 TDD 策略
/check security             # 执行安全检查
/devlog init                # 初始化开发记录
```

### 任务场景速查

| 场景 | 命令 |
|------|------|
| 日常开发 | `/load principles, workflow` |
| 测试驱动 | `/apply tdd` |
| 代码审查 | `/load principles, code-review` |
| 性能优化 | `/load performance` |
| 安全审计 | `/check security` |
| 大型任务 | `/load task-management, dev-logs` |

## 可用模块

| 模块 | 用途 |
|------|------|
| `principles` | 编程原则（KISS/YAGNI/DRY/SOLID） |
| `workflow` | 标准工作流程 |
| `task-management` | 大任务分解与追踪 |
| `testing` | 测试规范和策略 |
| `security` | 安全检查清单 |
| `performance` | 性能优化指南 |
| `code-review` | 代码审查标准 |
| `dev-logs` | AI 开发记录系统 |
| `mcp-services` | MCP 服务配置 |
| `tech-stack` | 技术选型决策 |
| `project-templates` | 项目初始化模板 |
| `quick-ref` | 快速参考手册 |

## 开发记录初始化

```powershell
# 在 \.claude\ 目录下执行
.\claude-prompts\scripts\init-dev-logs.ps1                   # 自动选择级别
.\claude-prompts\scripts\init-dev-logs.ps1 -Level minimal    # 小项目 (≤2人)
.\claude-prompts\scripts\init-dev-logs.ps1 -Level standard   # 中型项目 (≤5人)
.\claude-prompts\scripts\init-dev-logs.ps1 -Level enterprise # 大型项目 (>5人)
```

## 状态标记

| 标记 | 含义 | 标记 | 含义 |
|:----:|------|:----:|------|
| ✅ | 已完成 | ⚠️ | 有风险 |
| 🚧 | 进行中 | 🚫 | 已阻塞 |
| 📋 | 计划中 | 🔥 | 紧急 |

## 目录结构

```
claude-prompts/
├── 01-principles.md        # 编程原则
├── 02-workflow.md          # 工作流程
├── 03-task-management.md   # 任务管理
├── 04-mcp-services.md      # MCP 服务
├── 05-dev-logs.md          # 开发记录
├── 06-testing.md           # 测试规范
├── 07-security.md          # 安全检查
├── 08-performance.md       # 性能优化
├── 09-code-review.md       # 代码审查
├── 10-tech-stack.md        # 技术选型
├── 11-ai-collaboration.md  # AI 协作
├── 12-project-templates.md # 项目模板
├── module-loader.md        # 模块加载器规范
├── QUICK_REFERENCE.md      # 快速参考
└── scripts/
    └── init-dev-logs.ps1   # 开发记录初始化脚本
```

## License

MIT
