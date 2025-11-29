# 模块：AI 开发记录系统（核心）

## 快速开始

```bash
# 使用核心功能（轻量级）
/load dev-logs-core

# 加载完整功能
/load dev-logs-core, dev-logs/recording, dev-logs/templates

# 企业级完整配置
/load dev-logs-core, dev-logs/*
```

## 子模块列表

| 子模块 | 功能 | 适用场景 | 依赖 |
|--------|------|----------|------|
| `dev-logs/recording` | 记录规则与行为 | 需要自动记录 | core |
| `dev-logs/templates` | 模板系统 | 标准化记录格式 | core |
| `dev-logs/metrics` | 指标追踪 | 质量监控 | core |
| `dev-logs/search` | 查询分析 | 历史搜索 | core |
| `dev-logs/automation` | 自动化集成 | Git/CI集成 | core |
| `dev-logs/intelligent` | 智能功能 | AI增强 | core |
| `dev-logs/practices` | 最佳实践 | 参考指南 | core |

## 快速初始化

### 一键初始化命令
```powershell
# 基本使用（自动选择级别）
.\claude-prompts\scripts\init-dev-logs.ps1

# 指定项目规模和团队大小
.\claude-prompts\scripts\init-dev-logs.ps1 -ProjectSize large -TeamSize 10

# 强制使用企业级
.\claude-prompts\scripts\init-dev-logs.ps1 -Level enterprise -WithDashboard -WithGitHooks
```

### 参数说明
- **Level**: `minimal` | `standard` | `enterprise` | `auto` (默认)
- **ProjectSize**: `small` | `medium` | `large`
- **TeamSize**: 团队人数（数字）
- **WithDashboard**: 启用可视化仪表板
- **WithGitHooks**: 启用Git集成
- **Force**: 强制重新初始化

### 自动级别选择
- **minimal**: 个人项目/原型（团队 ≤ 2人）
- **standard**: 团队项目（团队 ≤ 5人）
- **enterprise**: 大型项目（团队 > 5人）

## 核心概念

### 定义
**系统化地记录 AI 开发过程中的所有重要信息**，包括任务进度、决策理由、代码变更、性能指标等，形成可追溯、可复用的知识库。

### 核心价值
- **透明性**：让用户了解 AI 的工作过程
- **可追溯**：方便回顾和审计开发历史
- **知识沉淀**：积累项目经验供未来参考
- **质量保证**：通过记录发现和改进问题

## 基础目录结构

### 最小化结构（个人项目）
```
.ai-dev-logs/
├── README.md           # 记录说明
├── today.md           # 今日聚焦
└── archive/           # 历史归档
    └── 2024-11/       # 按月归档
```

### 标准结构（团队项目）
```
.ai-dev-logs/
├── README.md                 # 项目记录概述
├── daily/                    # 每日记录
│   └── 2024-11-08.md
├── features/                 # 功能记录
│   └── {feature}/
├── issues/                   # 问题追踪
│   ├── resolved/
│   └── pending/
├── metrics/                  # 性能指标
└── index.md                 # 快速索引
```

### 企业级结构
```
.ai-dev-logs/
├── README.md                      # 总览
├── management/                    # 管理层面
├── development/                   # 开发记录
├── features/                      # 功能模块
├── architecture/                  # 架构
├── quality/                       # 质量
├── knowledge/                     # 知识库
└── dashboard/                     # 可视化
```

## 快速记录命令

### 基础命令
```javascript
// 任务开始
await logTaskStart({
  name: 'feature-name',
  type: 'feature',
  priority: 'high'
});

// 任务完成
await logTaskComplete({
  taskId: 'TASK-001',
  status: 'success',
  summary: 'Implementation completed'
});

// 记录错误
await logError({
  error: error.message,
  context: getCurrentContext()
});
```

### 使用 TODO 工具记录
```
1. 使用 TodoWrite 工具创建任务
2. 标记任务为 in_progress
3. 完成后标记为 completed
4. 记录会自动保存
```

## 基础配置

```yaml
# .ai-logs-config.yaml (最小配置)
version: 2.0
enabled: true
level: minimal  # minimal | standard | enterprise

paths:
  root: .ai-dev-logs

automation:
  auto_summary: true
  auto_archive: false
```

## 快速查看命令

```bash
# 查看今日任务
cat .ai-dev-logs/today.md

# 查看本周记录
ls .ai-dev-logs/daily/*.md

# 搜索关键词
grep -r "authentication" .ai-dev-logs/
```

## 与其他模块配合

- **workflow**: 在工作流程中嵌入记录
- **task-management**: 任务分解时自动创建记录
- **testing**: 测试结果自动记录
- **performance**: 性能指标自动收集

## 注意事项

1. **核心模块包含基础功能**，足以满足个人和小型项目需求
2. **按需加载子模块**，避免不必要的复杂性
3. **企业级项目建议加载所有模块**
4. **定期归档**历史记录，保持主目录清晰
5. **不要记录敏感信息**（密码、密钥等）

---

**模块类型**：核心记录系统
**版本**：3.0.0
**适用场景**：所有规模项目的基础记录需求
**子模块数量**：7个可选子模块
**最小依赖**：无（独立运行）