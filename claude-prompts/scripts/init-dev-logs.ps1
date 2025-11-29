# AI 开发记录系统初始化脚本 (PowerShell) v2.0
# 使用方法: .\init-dev-logs.ps1 [-Level minimal|standard|enterprise] [-ProjectSize small|medium|large] [-TeamSize <number>]

param(
    [ValidateSet("minimal", "standard", "enterprise", "auto")]
    [string]$Level,

    [ValidateSet("small", "medium", "large")]
    [string]$ProjectSize,

    [int]$TeamSize = 1,

    [switch]$Force,

    [switch]$WithDashboard,

    [switch]$WithGitHooks
)

# 现在再设置输出编码等
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'


# 支持环境变量方式传参（解决BOM导致的参数绑定问题）
if ([string]::IsNullOrEmpty($Level) -and $env:INIT_LEVEL) { $Level = $env:INIT_LEVEL }
if ([string]::IsNullOrEmpty($ProjectSize) -and $env:INIT_PROJECT_SIZE) { $ProjectSize = $env:INIT_PROJECT_SIZE }
if ($TeamSize -eq 0 -and $env:INIT_TEAM_SIZE) { $TeamSize = [int]$env:INIT_TEAM_SIZE }
if (-not $WithDashboard -and $env:INIT_WITH_DASHBOARD -eq 'true') { $WithDashboard = $true }
if (-not $WithGitHooks -and $env:INIT_WITH_GIT_HOOKS -eq 'true') { $WithGitHooks = $true }
if (-not $Force -and $env:INIT_FORCE -eq 'true') { $Force = $true }

# 设置默认值
if ([string]::IsNullOrEmpty($Level)) { $Level = "auto" }
if ([string]::IsNullOrEmpty($ProjectSize)) { $ProjectSize = "medium" }
if ($TeamSize -eq 0) { $TeamSize = 1 }

# 定义颜色
$colors = @{
    Info = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Detail = "Gray"
    Highlight = "Magenta"
}

function Write-ColorHost {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline
    )
    $params = @{
        Object = $Message
        ForegroundColor = if ($colors.ContainsKey($Color)) { $colors[$Color] } else { $Color }
        NoNewline = $NoNewline
    }
    Write-Host @params
}

# 自动选择合适的级别
function Get-RecommendedLevel {
    param(
        [string]$ProjectSize,
        [int]$TeamSize
    )

    if ($ProjectSize -eq "small" -and $TeamSize -le 2) {
        return "minimal"
    } elseif ($ProjectSize -eq "medium" -or $TeamSize -le 5) {
        return "standard"
    } else {
        return "enterprise"
    }
}

# 如果是 auto 模式，自动选择级别
if ($Level -eq "auto") {
    $Level = Get-RecommendedLevel -ProjectSize $ProjectSize -TeamSize $TeamSize
    Write-ColorHost "`n🤖 自动选择级别: $Level (项目规模: $ProjectSize, 团队规模: $TeamSize)" -Color "Info"
}

Write-ColorHost "`n🚀 初始化 AI 开发记录系统 v2.0" -Color "Highlight"
Write-ColorHost "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -Color "Detail"
Write-ColorHost "   级别: $Level" -Color "Info"
Write-ColorHost "   项目规模: $ProjectSize" -Color "Info"
Write-ColorHost "   团队规模: $TeamSize 人" -Color "Info"
Write-ColorHost "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -Color "Detail"

# 定义目录结构
$structures = @{
    minimal = @{
        dirs = @(
            ".ai-dev-logs",
            ".ai-dev-logs/archive"
        )
        files = @(
            @{
                path = ".ai-dev-logs/README.md"
                content = "minimal_readme"
            },
            @{
                path = ".ai-dev-logs/today.md"
                content = "today_summary"
            }
        )
    }

    standard = @{
        dirs = @(
            ".ai-dev-logs",
            ".ai-dev-logs/daily",
            ".ai-dev-logs/features",
            ".ai-dev-logs/issues",
            ".ai-dev-logs/issues/resolved",
            ".ai-dev-logs/issues/pending",
            ".ai-dev-logs/metrics",
            ".ai-dev-logs/templates",
            ".ai-dev-logs/commits",
            ".ai-dev-logs/sessions"
        )
        files = @(
            @{
                path = ".ai-dev-logs/README.md"
                content = "standard_readme"
            },
            @{
                path = ".ai-dev-logs/index.md"
                content = "standard_index"
            }
        )
    }

    enterprise = @{
        dirs = @(
            ".ai-dev-logs",
            ".ai-dev-logs/management",
            ".ai-dev-logs/management/milestones",
            ".ai-dev-logs/management/reports",
            ".ai-dev-logs/development",
            ".ai-dev-logs/development/daily",
            ".ai-dev-logs/development/weekly",
            ".ai-dev-logs/development/sprints",
            ".ai-dev-logs/features",
            ".ai-dev-logs/architecture",
            ".ai-dev-logs/architecture/decisions",
            ".ai-dev-logs/architecture/diagrams",
            ".ai-dev-logs/architecture/dependencies",
            ".ai-dev-logs/quality",
            ".ai-dev-logs/quality/code-reviews",
            ".ai-dev-logs/quality/security-audits",
            ".ai-dev-logs/quality/performance-tests",
            ".ai-dev-logs/knowledge",
            ".ai-dev-logs/dashboard",
            ".ai-dev-logs/dashboard/assets",
            ".ai-dev-logs/templates",
            ".ai-dev-logs/commits",
            ".ai-dev-logs/sessions",
            ".ai-dev-logs/backup"
        )
        files = @(
            @{
                path = ".ai-dev-logs/README.md"
                content = "enterprise_readme"
            },
            @{
                path = ".ai-dev-logs/management/roadmap.md"
                content = "roadmap"
            },
            @{
                path = ".ai-dev-logs/knowledge/lessons-learned.md"
                content = "lessons"
            },
            @{
                path = ".ai-dev-logs/knowledge/best-practices.md"
                content = "practices"
            },
            @{
                path = ".ai-dev-logs/knowledge/troubleshooting.md"
                content = "troubleshooting"
            }
        )
    }
}

# 文件内容模板
$templates = @{
    minimal_readme = @"
# AI 开发记录

## 项目信息
- **初始化时间**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
- **记录级别**: 最小化（个人项目/原型）
- **团队规模**: $TeamSize 人

## 快速访问
- [今日聚焦](today.md)
- [历史归档](archive/)

## 使用说明
本项目使用最小化的记录结构，适合个人项目和原型开发。
AI 助手会自动更新 today.md 文件记录每日进展。

---
*由 AI 开发记录系统 v2.0 自动生成*
"@

    standard_readme = @"
# AI 开发记录

## 项目信息
- **初始化时间**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
- **记录级别**: 标准（团队项目）
- **项目规模**: $ProjectSize
- **团队规模**: $TeamSize 人

## 目录结构
\`\`\`
.ai-dev-logs/
├── daily/          # 每日记录
├── features/       # 功能模块记录
├── issues/         # 问题追踪
├── metrics/        # 性能指标
└── templates/      # 记录模板
\`\`\`

## 快速导航
- [项目索引](index.md)
- [每日记录](daily/)
- [功能列表](features/)
- [问题追踪](issues/)
- [性能指标](metrics/)

---
*由 AI 开发记录系统 v2.0 自动生成*
"@

    enterprise_readme = @"
# AI 开发记录 - 企业级

## 项目信息
- **初始化时间**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
- **记录级别**: 企业级（大型项目）
- **项目规模**: $ProjectSize
- **团队规模**: $TeamSize 人

## 管理层视图
- [项目路线图](management/roadmap.md)
- [里程碑追踪](management/milestones/)
- [管理报告](management/reports/)

## 开发层视图
- [每日进展](development/daily/)
- [周报汇总](development/weekly/)
- [冲刺记录](development/sprints/)

## 架构与质量
- [架构决策记录](architecture/decisions/)
- [代码审查](quality/code-reviews/)
- [安全审计](quality/security-audits/)
- [性能测试](quality/performance-tests/)

## 知识管理
- [经验教训](knowledge/lessons-learned.md)
- [最佳实践](knowledge/best-practices.md)
- [问题解决](knowledge/troubleshooting.md)

## 可视化
- [仪表板](dashboard/index.html) $(if ($WithDashboard) { "✅ 已启用" } else { "⏸️ 未启用" })

---
*由 AI 开发记录系统 v2.0 自动生成*
"@

    today_summary = @"
# 今日聚焦 - $(Get-Date -Format "yyyy-MM-dd")

## 📋 待办任务
- [ ] 任务 1
- [ ] 任务 2
- [ ] 任务 3

## 🚧 进行中
_暂无_

## ✅ 已完成
_暂无_

## 💡 关键发现
_暂无_

## 🎯 明日计划
- [ ] 待规划

---
*更新时间: $(Get-Date -Format "HH:mm:ss")*
"@

    standard_index = @"
# 项目索引

## 📊 统计概览
- **总任务数**: 0
- **已完成**: 0 (0%)
- **进行中**: 0 (0%)
- **平均完成时间**: N/A

## 🔥 最近活动
_暂无记录_

## 📁 快速跳转
### 按时间
- [今日](daily/$(Get-Date -Format "yyyy-MM-dd").md)
- [本周](weekly/$(Get-Date -UFormat "%Y-W%V").md)
- [本月](monthly/$(Get-Date -Format "yyyy-MM").md)

### 按类型
- [功能开发](features/)
- [Bug修复](issues/resolved/)
- [待解决问题](issues/pending/)

## 🏷️ 标签云
_暂无标签_

---
*自动生成于: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")*
"@

    roadmap = @"
# 项目路线图

## 🎯 项目愿景
[待定义项目愿景]

## 📅 时间线

### Q1 2024
- [ ] **里程碑 1**: 基础架构搭建
  - [ ] 环境配置
  - [ ] 基础框架
  - [ ] 开发规范

### Q2 2024
- [ ] **里程碑 2**: 核心功能开发
  - [ ] 功能模块 A
  - [ ] 功能模块 B
  - [ ] 功能模块 C

### Q3 2024
- [ ] **里程碑 3**: 测试与优化
  - [ ] 性能优化
  - [ ] 安全加固
  - [ ] 用户体验

### Q4 2024
- [ ] **里程碑 4**: 发布准备
  - [ ] 文档完善
  - [ ] 部署流程
  - [ ] 运维准备

## 🔑 关键决策点
1. **技术栈选择** - 待定
2. **架构模式** - 待定
3. **部署策略** - 待定

---
*创建于: $(Get-Date -Format "yyyy-MM-dd")*
"@

    lessons = @"
# 经验教训

## 📚 成功经验

### 1. [经验标题]
- **场景**: 描述具体场景
- **做法**: 采取的方法
- **效果**: 取得的成果
- **建议**: 后续建议

## ⚠️ 失败教训

### 1. [教训标题]
- **问题**: 遇到的问题
- **原因**: 问题根因
- **影响**: 造成的影响
- **改进**: 改进措施

## 💡 最佳实践提炼
1. **原则一**: 说明
2. **原则二**: 说明
3. **原则三**: 说明

---
*持续更新中...*
"@

    practices = @"
# 最佳实践

## 🏗️ 架构实践

### 模块化设计
- 单一职责原则
- 高内聚低耦合
- 依赖倒置

### 性能优化
- 缓存策略
- 异步处理
- 懒加载

## 💻 编码实践

### 代码规范
- 命名规范
- 注释规范
- 格式规范

### 测试驱动
- 单元测试优先
- 集成测试覆盖
- E2E测试验证

## 🔄 流程实践

### 版本管理
- Git工作流
- 分支策略
- 提交规范

### 持续集成
- 自动化测试
- 代码审查
- 部署流程

---
*版本: 1.0.0*
"@

    troubleshooting = @"
# 故障排查手册

## 🔍 常见问题

### 问题 1: [问题描述]
**症状**:
- 症状描述

**原因**:
- 可能原因

**解决方案**:
\`\`\`bash
# 解决命令
\`\`\`

**预防措施**:
- 措施说明

## 🛠️ 调试技巧

### 日志分析
\`\`\`powershell
# 查看日志
Get-Content .ai-dev-logs/daily/*.md | Select-String "error"
\`\`\`

### 性能分析
\`\`\`powershell
# 分析性能
Get-Content .ai-dev-logs/metrics/*.json | ConvertFrom-Json | Where-Object {$_.responseTime -gt 500}
\`\`\`

## 📞 支持渠道
- 内部 Wiki: [链接]
- 技术支持: [邮箱]
- 紧急联系: [电话]

---
*更新日期: $(Get-Date -Format "yyyy-MM-dd")*
"@

    task_template = @"
# 任务：[任务名称]
**ID**: TASK-$(Get-Date -Format "yyyyMMdd")-XXX
**类型**: Feature | Bug | Refactor | Performance | Security
**优先级**: P0 | P1 | P2 | P3
**状态**: 🚀 开始 | 🚧 进行中 | ✅ 完成 | ❌ 失败 | ⏸️ 暂停

## 元信息
- **开始时间**: $(Get-Date -Format "yyyy-MM-dd HH:mm")
- **预计耗时**: 2小时
- **实际耗时**: [自动计算]
- **执行者**: AI Assistant

## 任务目标
[清晰的任务描述和预期成果]

## 实施步骤
- [ ] 步骤1：分析需求
- [ ] 步骤2：设计方案
- [ ] 步骤3：编码实现
- [ ] 步骤4：测试验证

## 代码变更
| 文件 | 变更类型 | 行数变化 | 说明 |
|-----|---------|---------|------|
| file1.js | 修改 | +50/-20 | 说明 |
| file2.js | 新增 | +120 | 说明 |

## 测试结果
\`\`\`json
{
  "total": 0,
  "passed": 0,
  "failed": 0,
  "coverage": 0
}
\`\`\`

## 问题与解决
_暂无_

## 后续任务
- [ ] 任务1
- [ ] 任务2

## 参考资料
- [链接1](url)
- [链接2](url)
"@

    feature_template = @"
# 功能：[功能名称]

## 概述
**模块**: [所属模块]
**版本**: v0.0.1
**负责人**: AI Assistant
**状态**: 规划中 | 开发中 | 测试中 | 已发布

## 需求分析
### 业务需求
[业务背景和目标]

### 技术需求
- 性能：响应时间 < 500ms
- 安全：防止SQL注入、XSS
- 兼容性：支持主流浏览器

## 设计方案
### 架构设计
[架构图或说明]

### 数据模型
[数据结构定义]

## 实施记录
### Phase 1: 基础功能
- [ ] 任务1
- [ ] 任务2

### Phase 2: 核心功能
- [ ] 任务3
- [ ] 任务4

## 测试记录
- 单元测试：0/0
- 集成测试：0/0
- 覆盖率：0%

## 部署记录
- 开发环境：⏳ 待配置
- 测试环境：⏳ 待配置
- 生产环境：⏳ 待配置

## 相关文档
- [API文档](./api-docs.md)
- [测试报告](./test-reports/)
- [部署手册](./deployment-guide.md)
"@

    adr_template = @"
# ADR-$(Get-Date -Format "yyyyMMdd")-001: [决策标题]

## 状态
⏳ 讨论中 | ✅ 已采纳 | ❌ 已拒绝 | 🔄 已替代

## 日期
$(Get-Date -Format "yyyy-MM-dd")

## 上下文
[描述需要做决策的背景和原因]
- 当前情况：
- 面临问题：
- 触发因素：

## 决策驱动因素
- [ ] 性能要求
- [ ] 安全考虑
- [ ] 可维护性
- [ ] 开发效率
- [ ] 成本控制
- [ ] 技术栈一致性

## 考虑的方案

### 方案 1: [方案名称]
**描述**: [详细描述]
**优点**:
- ✅ 优点1
- ✅ 优点2

**缺点**:
- ❌ 缺点1
- ❌ 缺点2

**风险**: [潜在风险]
**成本**: [时间/资源成本]

### 方案 2: [方案名称]
**描述**: [详细描述]
**优点**:
- ✅ 优点1
- ✅ 优点2

**缺点**:
- ❌ 缺点1
- ❌ 缺点2

**风险**: [潜在风险]
**成本**: [时间/资源成本]

## 决策
我们将采用 **方案X**，因为[决策理由]。

## 后果

### 积极影响
- ✅ 正面影响1
- ✅ 正面影响2
- ✅ 正面影响3

### 消极影响
- ⚠️ 负面影响1
- ⚠️ 负面影响2

### 风险缓解措施
1. 风险1 → 缓解措施
2. 风险2 → 缓解措施

## 实施计划
| 阶段 | 任务 | 负责人 | 截止日期 | 状态 |
|------|------|--------|----------|------|
| 1 | 任务1 | AI | - | ⏳ |
| 2 | 任务2 | AI | - | ⏳ |
| 3 | 任务3 | AI | - | ⏳ |

## 验证标准
- [ ] 标准1
- [ ] 标准2
- [ ] 标准3

## 相关决策
- [ADR-XXX: 相关决策1]
- [ADR-YYY: 相关决策2]

## 参考资料
- [参考文档1]
- [参考文档2]

## 变更历史
| 日期 | 版本 | 变更内容 | 作者 |
|------|------|----------|------|
| $(Get-Date -Format "yyyy-MM-dd") | v1.0 | 初始版本 | AI Assistant |
"@

    session_template = @"
# 会话记录 - SESSION-$(Get-Date -Format "yyyyMMdd-HHmmss")

## 会话信息
- **开始时间**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
- **结束时间**: [待填写]
- **持续时长**: [自动计算]
- **参与者**: User & AI Assistant
- **会话类型**: 开发 | 调试 | 咨询 | 学习

## 会话目标
[本次会话要解决的问题或达成的目标]

## 对话要点

### 用户需求
1. 需求1
2. 需求2

### AI 响应
1. 方案1
2. 方案2

## 执行的操作
| 时间 | 操作类型 | 操作内容 | 结果 |
|------|---------|---------|------|
| HH:mm | 文件操作 | 创建/修改文件 | ✅/❌ |
| HH:mm | 代码生成 | 生成XX代码 | ✅/❌ |

## 生成的文件
- [ ] 文件1：路径
- [ ] 文件2：路径

## 解决的问题
1. **问题**: [描述]
   **解决方案**: [方案]
   **结果**: ✅ 已解决

## 待办事项
- [ ] 后续任务1
- [ ] 后续任务2

## 学习要点
- 知识点1
- 知识点2

## 会话评价
- **目标达成度**: 0%
- **效率评分**: ⭐⭐⭐☆☆
- **满意度**: ⭐⭐⭐☆☆

## 改进建议
- 建议1
- 建议2

## 相关资源
- [文档链接]
- [参考资料]
"@

    config_yaml = @"
# AI 开发记录配置
version: 2.0

# 基础配置
enabled: true
level: $Level  # minimal | standard | enterprise

# 目录配置
paths:
  root: .ai-dev-logs
  daily: `${root}/$(if ($Level -eq "minimal") { "archive" } elseif ($Level -eq "standard") { "daily" } else { "development/daily" })
  features: `${root}/features
  metrics: `${root}/metrics
  archive: `${root}/archive

# 自动化配置
automation:
  auto_summary: true
  auto_archive: true
  auto_index: true
  auto_tag: $(if ($Level -eq "enterprise") { "true" } else { "false" })

# 记录规则
rules:
  - trigger: task_start
    required: true
    template: task.md

  - trigger: task_complete
    required: true
    template: task-complete.md

  - trigger: error
    required: true
    template: error.md

  - trigger: decision
    required: $(if ($Level -eq "minimal") { "false" } else { "true" })
    template: decision.md

# 性能配置
performance:
  buffer_size: $(if ($Level -eq "minimal") { "50" } elseif ($Level -eq "standard") { "100" } else { "200" })
  flush_interval: 5000
  max_file_size: $(if ($Level -eq "minimal") { "5MB" } elseif ($Level -eq "standard") { "10MB" } else { "20MB" })
  compression: $(if ($Level -eq "enterprise") { "true" } else { "false" })

# 集成配置
integrations:
  git:
    enabled: $(if ($WithGitHooks) { "true" } else { "false" })
    hooks: [pre-commit, post-merge]

  dashboard:
    enabled: $(if ($WithDashboard) { "true" } else { "false" })
    port: 3000
    refresh_interval: 60000

# 团队配置
team:
  size: $TeamSize
  project_size: $ProjectSize

# 创建信息
metadata:
  created: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
  created_by: AI Dev Logs Init Script v2.0
  hostname: $(hostname)
"@

    dashboard_html = @"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI 开发记录仪表板</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --bg-primary: #f8fafc;
            --bg-secondary: #ffffff;
            --bg-gradient-start: #667eea;
            --bg-gradient-end: #764ba2;
            --text-primary: #1e293b;
            --text-secondary: #64748b;
            --text-tertiary: #94a3b8;
            --accent-primary: #667eea;
            --accent-secondary: #764ba2;
            --accent-success: #10b981;
            --accent-warning: #f59e0b;
            --accent-danger: #ef4444;
            --accent-info: #3b82f6;
            --card-bg: rgba(255, 255, 255, 0.95);
            --card-shadow: rgba(0, 0, 0, 0.1);
            --border-color: rgba(226, 232, 240, 0.8);
            --glass-bg: rgba(255, 255, 255, 0.7);
            --glass-border: rgba(255, 255, 255, 0.3);
        }

        [data-theme="dark"] {
            --bg-primary: #0f172a;
            --bg-secondary: #1e293b;
            --text-primary: #f1f5f9;
            --text-secondary: #cbd5e1;
            --text-tertiary: #64748b;
            --card-bg: rgba(30, 41, 59, 0.95);
            --card-shadow: rgba(0, 0, 0, 0.3);
            --border-color: rgba(51, 65, 85, 0.8);
            --glass-bg: rgba(30, 41, 59, 0.7);
            --glass-border: rgba(71, 85, 105, 0.3);
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: var(--bg-primary);
            min-height: 100vh;
            padding: 20px;
            transition: background 0.3s ease, color 0.3s ease;
            position: relative;
            overflow-x: hidden;
        }

        body::before {
            content: "";
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 400px;
            background: linear-gradient(135deg, var(--bg-gradient-start) 0%, var(--bg-gradient-end) 100%);
            z-index: -1;
            opacity: 0.8;
        }

        .container {
            max-width: 1600px;
            margin: 0 auto;
            position: relative;
            z-index: 1;
        }

        /* 顶部工具栏 */
        .toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 16px;
            padding: 15px 20px;
            box-shadow: 0 8px 32px var(--card-shadow);
        }

        .toolbar-left {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .toolbar-right {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        h1 {
            color: white;
            font-size: 1.8rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 12px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        }

        /* 主题切换按钮 */
        .theme-toggle {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 10px 15px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
            color: var(--text-primary);
        }

        .theme-toggle:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px var(--card-shadow);
        }

        /* 搜索框 */
        .search-box {
            position: relative;
            width: 300px;
        }

        .search-box input {
            width: 100%;
            padding: 10px 15px 10px 40px;
            border: 1px solid var(--border-color);
            border-radius: 12px;
            background: var(--card-bg);
            color: var(--text-primary);
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }

        .search-box input:focus {
            outline: none;
            border-color: var(--accent-primary);
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .search-box i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-tertiary);
        }

        /* 刷新指示器 */
        .auto-refresh {
            background: var(--card-bg);
            padding: 8px 16px;
            border-radius: 20px;
            box-shadow: 0 4px 12px var(--card-shadow);
            font-size: 0.85rem;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            gap: 8px;
            border: 1px solid var(--border-color);
        }

        .refresh-countdown {
            color: var(--accent-primary);
            font-weight: 600;
            min-width: 30px;
            text-align: center;
        }

        h2 {
            color: var(--text-primary);
            margin-bottom: 20px;
            font-size: 1.3rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* 统计卡片网格 */
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--card-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 24px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 20px var(--card-shadow);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .stat-card::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--accent-primary), var(--accent-secondary));
            transform: scaleX(0);
            transform-origin: left;
            transition: transform 0.4s ease;
        }

        .stat-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 12px 40px var(--card-shadow);
        }

        .stat-card:hover::before {
            transform: scaleX(1);
        }

        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            margin-bottom: 15px;
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            color: white;
        }

        .stat-value {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 8px;
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .stat-label {
            color: var(--text-secondary);
            font-size: 0.95rem;
            margin-bottom: 10px;
            font-weight: 500;
        }

        .stat-trend {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            color: var(--accent-success);
            font-size: 0.85rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 20px;
            background: rgba(16, 185, 129, 0.1);
        }

        .stat-trend.down {
            color: var(--accent-danger);
            background: rgba(239, 68, 68, 0.1);
        }

        .stat-trend.neutral {
            color: var(--text-tertiary);
            background: rgba(148, 163, 184, 0.1);
        }

        /* 卡片网格 */
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 24px;
            margin-bottom: 30px;
        }

        .card {
            background: var(--card-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 28px;
            box-shadow: 0 4px 20px var(--card-shadow);
            transition: all 0.3s ease;
        }

        .card:hover {
            box-shadow: 0 8px 30px var(--card-shadow);
        }

        /* 进度卡片 */
        .progress-card {
            background: var(--card-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 28px;
            margin-bottom: 30px;
            box-shadow: 0 4px 20px var(--card-shadow);
        }

        .progress-bar {
            height: 40px;
            background: var(--bg-secondary);
            border-radius: 20px;
            overflow: hidden;
            margin: 20px 0;
            position: relative;
            box-shadow: inset 0 2px 8px rgba(0,0,0,0.1);
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--accent-primary), var(--accent-secondary));
            transition: width 1s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 0.95rem;
            position: relative;
            overflow: hidden;
        }

        .progress-fill::after {
            content: "";
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            animation: shimmer 2s infinite;
        }

        @keyframes shimmer {
            to { left: 100%; }
        }

        .progress-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: var(--text-secondary);
            font-size: 0.95rem;
        }

        .progress-info strong {
            color: var(--text-primary);
        }

        /* 时间线 */
        .timeline {
            background: var(--card-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 28px;
            box-shadow: 0 4px 20px var(--card-shadow);
            max-height: 600px;
            overflow-y: auto;
            scrollbar-width: thin;
            scrollbar-color: var(--accent-primary) var(--bg-secondary);
        }

        .timeline::-webkit-scrollbar {
            width: 6px;
        }

        .timeline::-webkit-scrollbar-track {
            background: var(--bg-secondary);
            border-radius: 10px;
        }

        .timeline::-webkit-scrollbar-thumb {
            background: var(--accent-primary);
            border-radius: 10px;
        }

        .timeline-item {
            padding: 20px;
            border-left: 3px solid var(--accent-primary);
            margin-left: 15px;
            margin-bottom: 25px;
            position: relative;
            background: var(--bg-secondary);
            border-radius: 0 12px 12px 0;
            transition: all 0.3s ease;
        }

        .timeline-item:hover {
            transform: translateX(5px);
            box-shadow: 0 4px 12px var(--card-shadow);
        }

        .timeline-item::before {
            content: "";
            width: 16px;
            height: 16px;
            background: var(--accent-primary);
            border: 3px solid var(--card-bg);
            border-radius: 50%;
            position: absolute;
            left: -11px;
            top: 22px;
            box-shadow: 0 0 0 4px var(--accent-primary) + 20;
        }

        .timeline-item.success {
            border-left-color: var(--accent-success);
        }

        .timeline-item.success::before {
            background: var(--accent-success);
        }

        .timeline-item.error {
            border-left-color: var(--accent-danger);
        }

        .timeline-item.error::before {
            background: var(--accent-danger);
        }

        .timeline-time {
            color: var(--text-tertiary);
            font-size: 0.85rem;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .timeline-title {
            font-weight: 600;
            margin-bottom: 6px;
            color: var(--text-primary);
            font-size: 1.05rem;
        }

        .timeline-desc {
            color: var(--text-secondary);
            font-size: 0.9rem;
            line-height: 1.5;
        }

        .timeline-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-top: 8px;
        }

        .timeline-badge.success {
            background: rgba(16, 185, 129, 0.1);
            color: var(--accent-success);
        }

        .timeline-badge.info {
            background: rgba(59, 130, 246, 0.1);
            color: var(--accent-info);
        }

        /* 底部信息 */
        #updateTime {
            text-align: center;
            color: var(--text-tertiary);
            margin-top: 30px;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        /* 加载动画 */
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid var(--border-color);
            border-radius: 50%;
            border-top-color: var(--accent-primary);
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* 响应式设计 */
        @media (max-width: 1200px) {
            .grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            body {
                padding: 15px;
            }

            .toolbar {
                flex-direction: column;
                gap: 15px;
                align-items: stretch;
            }

            .toolbar-left,
            .toolbar-right {
                flex-direction: column;
                align-items: stretch;
            }

            .search-box {
                width: 100%;
            }

            h1 {
                font-size: 1.5rem;
            }

            .stats {
                grid-template-columns: 1fr;
            }

            .stat-card {
                padding: 20px;
            }

            .grid {
                grid-template-columns: 1fr;
            }
        }

        /* 动画效果 */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .stats > *, .card, .timeline {
            animation: fadeInUp 0.6s ease-out;
            animation-fill-mode: both;
        }

        .stats > *:nth-child(1) { animation-delay: 0.1s; }
        .stats > *:nth-child(2) { animation-delay: 0.2s; }
        .stats > *:nth-child(3) { animation-delay: 0.3s; }
        .stats > *:nth-child(4) { animation-delay: 0.4s; }
        .stats > *:nth-child(5) { animation-delay: 0.5s; }
        .stats > *:nth-child(6) { animation-delay: 0.6s; }

        /* 工具提示 */
        [data-tooltip] {
            position: relative;
            cursor: help;
        }

        [data-tooltip]::after {
            content: attr(data-tooltip);
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%) translateY(-8px);
            padding: 8px 12px;
            background: var(--text-primary);
            color: var(--bg-primary);
            border-radius: 8px;
            font-size: 0.85rem;
            white-space: nowrap;
            opacity: 0;
            pointer-events: none;
            transition: opacity 0.3s ease;
        }

        [data-tooltip]:hover::after {
            opacity: 1;
        }
    </style>
</head>
<body>
    <!-- 顶部工具栏 -->
    <div class="container">
        <div class="toolbar">
            <div class="toolbar-left">
                <h1>
                    <i class="fas fa-robot"></i>
                    AI 开发记录仪表板
                </h1>
            </div>
            <div class="toolbar-right">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" placeholder="搜索任务、指标..." id="searchInput">
                </div>
                <button class="theme-toggle" onclick="toggleTheme()">
                    <i class="fas fa-moon" id="themeIcon"></i>
                    <span id="themeText">暗色模式</span>
                </button>
                <div class="auto-refresh">
                    <i class="fas fa-sync-alt"></i>
                    <span class="refresh-countdown">60</span>秒后刷新
                </div>
            </div>
        </div>

        <!-- 统计卡片 -->
        <div class="stats">
            <div class="stat-card" data-tooltip="项目总任务数量">
                <div class="stat-icon"><i class="fas fa-tasks"></i></div>
                <div class="stat-value" id="totalTasks">0</div>
                <div class="stat-label">总任务数</div>
                <div class="stat-trend"><i class="fas fa-arrow-up"></i> 12% 本周</div>
            </div>
            <div class="stat-card" data-tooltip="已成功完成的任务">
                <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
                <div class="stat-value" id="completedTasks">0</div>
                <div class="stat-label">已完成</div>
                <div class="stat-trend"><i class="fas fa-arrow-up"></i> 80% 完成率</div>
            </div>
            <div class="stat-card" data-tooltip="单元测试覆盖率">
                <div class="stat-icon"><i class="fas fa-shield-alt"></i></div>
                <div class="stat-value" id="testCoverage">0%</div>
                <div class="stat-label">测试覆盖率</div>
                <div class="stat-trend"><i class="fas fa-arrow-up"></i> +5% 本周</div>
            </div>
            <div class="stat-card" data-tooltip="任务平均完成时间">
                <div class="stat-icon"><i class="fas fa-clock"></i></div>
                <div class="stat-value" id="avgTime">0h</div>
                <div class="stat-label">平均耗时</div>
                <div class="stat-trend neutral"><i class="fas fa-minus"></i> 持平</div>
            </div>
            <div class="stat-card" data-tooltip="本周代码变更行数">
                <div class="stat-icon"><i class="fas fa-code"></i></div>
                <div class="stat-value" id="codeLines">0</div>
                <div class="stat-label">代码行数</div>
                <div class="stat-trend"><i class="fas fa-arrow-up"></i> +320 今日</div>
            </div>
            <div class="stat-card" data-tooltip="Git 提交次数">
                <div class="stat-icon"><i class="fas fa-code-branch"></i></div>
                <div class="stat-value" id="commits">0</div>
                <div class="stat-label">提交次数</div>
                <div class="stat-trend"><i class="fas fa-arrow-up"></i> +3 今日</div>
            </div>
        </div>

        <!-- 今日进度 -->
        <div class="progress-card">
            <h2><i class="fas fa-chart-line"></i> 今日进度</h2>
            <div class="progress-bar">
                <div class="progress-fill" style="width: 0%" id="dailyProgress">
                    0%
                </div>
            </div>
            <div class="progress-info">
                <span>完成 <strong id="completedCount">0</strong> / <strong id="totalCount">0</strong> 个任务</span>
                <span>预计剩余: <strong id="remainingTime">--</strong></span>
            </div>
        </div>

        <!-- 图表网格 -->
        <div class="grid">
            <div class="card">
                <h2><i class="fas fa-chart-area"></i> 任务完成趋势</h2>
                <canvas id="taskTrend"></canvas>
            </div>
            <div class="card">
                <h2><i class="fas fa-chart-bar"></i> 代码变更统计</h2>
                <canvas id="codeChanges"></canvas>
            </div>
            <div class="card">
                <h2><i class="fas fa-chart-pie"></i> 任务类型分布</h2>
                <canvas id="taskTypes"></canvas>
            </div>
            <div class="card">
                <h2><i class="fas fa-tachometer-alt"></i> 性能指标</h2>
                <canvas id="performance"></canvas>
            </div>
        </div>

        <!-- 时间线 -->
        <div class="timeline">
            <h2><i class="fas fa-history"></i> 最近活动时间线</h2>
            <div class="timeline-item success">
                <div class="timeline-time">
                    <i class="far fa-clock"></i>
                    $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                </div>
                <div class="timeline-title">✨ 系统初始化完成</div>
                <div class="timeline-desc">AI 开发记录系统已成功搭建，所有模块正常运行</div>
                <span class="timeline-badge success">完成</span>
            </div>
            <div class="timeline-item success">
                <div class="timeline-time">
                    <i class="far fa-clock"></i>
                    $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                </div>
                <div class="timeline-title">📊 仪表板创建</div>
                <div class="timeline-desc">企业级可视化仪表板已启用，支持实时数据更新</div>
                <span class="timeline-badge info">部署</span>
            </div>
            <div class="timeline-item success">
                <div class="timeline-time">
                    <i class="far fa-clock"></i>
                    <span id="currentTime"></span>
                </div>
                <div class="timeline-title">🎨 UI/UX 优化</div>
                <div class="timeline-desc">完成现代化设计改版，支持暗色模式和响应式布局</div>
                <span class="timeline-badge info">进行中</span>
            </div>
        </div>

        <div id="updateTime">
            <i class="fas fa-sync-alt"></i>
            最后更新: <span id="lastUpdate"></span>
        </div>
    </div>

    <script>
        // 主题切换
        function toggleTheme() {
            const html = document.documentElement;
            const currentTheme = html.getAttribute('data-theme');
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
            html.setAttribute('data-theme', newTheme);

            const icon = document.getElementById('themeIcon');
            const text = document.getElementById('themeText');

            if (newTheme === 'dark') {
                icon.className = 'fas fa-sun';
                text.textContent = '亮色模式';
            } else {
                icon.className = 'fas fa-moon';
                text.textContent = '暗色模式';
            }

            localStorage.setItem('theme', newTheme);
            updateCharts();
        }

        // 加载保存的主题
        const savedTheme = localStorage.getItem('theme') || 'light';
        if (savedTheme === 'dark') {
            document.documentElement.setAttribute('data-theme', 'dark');
            document.getElementById('themeIcon').className = 'fas fa-sun';
            document.getElementById('themeText').textContent = '亮色模式';
        }

        // 更新当前时间
        function updateCurrentTime() {
            const now = new Date();
            const timeString = now.toLocaleString('zh-CN', {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            });
            document.getElementById('lastUpdate').textContent = timeString;
            document.getElementById('currentTime').textContent = timeString;
        }

        updateCurrentTime();
        setInterval(updateCurrentTime, 1000);

        // 自动刷新倒计时
        let countdown = 60;
        const countdownElement = document.querySelector('.refresh-countdown');

        setInterval(() => {
            countdown--;
            countdownElement.textContent = countdown;

            if (countdown <= 0) {
                location.reload();
            }
        }, 1000);

        // 搜索功能
        document.getElementById('searchInput').addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            console.log('搜索:', searchTerm);
            // TODO: 实现搜索过滤功能
        });

        // 模拟数据
        const mockData = {
            dates: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
            tasksCompleted: [5, 8, 6, 9, 7, 11, 8],
            codeChanges: {
                added: [320, 450, 280, 510, 380, 620, 410],
                deleted: [120, 180, 150, 220, 160, 280, 190]
            },
            taskTypes: {
                feature: 45,
                bug: 30,
                refactor: 15,
                performance: 10
            },
            performance: [180, 165, 170, 155, 160, 148, 152]
        };

        // 获取主题颜色
        function getThemeColors() {
            const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
            return {
                text: isDark ? '#cbd5e1' : '#64748b',
                grid: isDark ? '#334155' : '#e2e8f0',
                background: isDark ? 'rgba(30, 41, 59, 0.5)' : 'rgba(255, 255, 255, 0.5)'
            };
        }

        // 图表配置
        Chart.defaults.font.family = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
        Chart.defaults.font.size = 12;

        let charts = {};

        function updateCharts() {
            const colors = getThemeColors();

            Object.values(charts).forEach(chart => {
                chart.options.scales.x.ticks.color = colors.text;
                chart.options.scales.y.ticks.color = colors.text;
                chart.options.scales.x.grid.color = colors.grid;
                chart.options.scales.y.grid.color = colors.grid;
                chart.update();
            });
        }

        // 任务趋势图
        charts.taskTrend = new Chart(document.getElementById('taskTrend'), {
            type: 'line',
            data: {
                labels: mockData.dates,
                datasets: [{
                    label: '完成任务数',
                    data: mockData.tasksCompleted,
                    borderColor: '#667eea',
                    backgroundColor: 'rgba(102, 126, 234, 0.1)',
                    tension: 0.4,
                    fill: true,
                    borderWidth: 3,
                    pointRadius: 5,
                    pointHoverRadius: 7,
                    pointBackgroundColor: '#667eea',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.8)',
                        padding: 12,
                        cornerRadius: 8,
                        titleFont: { size: 14, weight: 'bold' },
                        bodyFont: { size: 13 }
                    }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { color: getThemeColors().text }
                    },
                    y: {
                        beginAtZero: true,
                        grid: { color: getThemeColors().grid },
                        ticks: { color: getThemeColors().text }
                    }
                }
            }
        });

        // 代码变更统计
        charts.codeChanges = new Chart(document.getElementById('codeChanges'), {
            type: 'bar',
            data: {
                labels: mockData.dates,
                datasets: [{
                    label: '新增',
                    data: mockData.codeChanges.added,
                    backgroundColor: '#10b981',
                    borderRadius: 6
                }, {
                    label: '删除',
                    data: mockData.codeChanges.deleted,
                    backgroundColor: '#ef4444',
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        position: 'top',
                        labels: {
                            usePointStyle: true,
                            padding: 15,
                            font: { size: 12 }
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.8)',
                        padding: 12,
                        cornerRadius: 8
                    }
                },
                scales: {
                    x: {
                        stacked: false,
                        grid: { display: false },
                        ticks: { color: getThemeColors().text }
                    },
                    y: {
                        stacked: false,
                        grid: { color: getThemeColors().grid },
                        ticks: { color: getThemeColors().text }
                    }
                }
            }
        });

        // 任务类型分布
        charts.taskTypes = new Chart(document.getElementById('taskTypes'), {
            type: 'doughnut',
            data: {
                labels: ['功能开发', 'Bug修复', '重构', '性能优化'],
                datasets: [{
                    data: Object.values(mockData.taskTypes),
                    backgroundColor: ['#667eea', '#10b981', '#f59e0b', '#ef4444'],
                    borderWidth: 0,
                    hoverOffset: 10
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 15,
                            usePointStyle: true,
                            font: { size: 12 }
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.8)',
                        padding: 12,
                        cornerRadius: 8,
                        callbacks: {
                            label: function(context) {
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((context.parsed / total) * 100).toFixed(1);
                                return context.label + ': ' + percentage + '%';
                            }
                        }
                    }
                }
            }
        });

        // 性能指标
        charts.performance = new Chart(document.getElementById('performance'), {
            type: 'line',
            data: {
                labels: mockData.dates,
                datasets: [{
                    label: '响应时间 (ms)',
                    data: mockData.performance,
                    borderColor: '#10b981',
                    backgroundColor: 'rgba(16, 185, 129, 0.1)',
                    tension: 0.4,
                    fill: true,
                    borderWidth: 3,
                    pointRadius: 5,
                    pointHoverRadius: 7,
                    pointBackgroundColor: '#10b981',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.8)',
                        padding: 12,
                        cornerRadius: 8,
                        callbacks: {
                            label: function(context) {
                                return '响应时间: ' + context.parsed.y + 'ms';
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { color: getThemeColors().text }
                    },
                    y: {
                        beginAtZero: true,
                        grid: { color: getThemeColors().grid },
                        ticks: { color: getThemeColors().text }
                    }
                }
            }
        });

        // 更新统计数字（带动画效果）
        function animateValue(id, start, end, duration, suffix = '') {
            const obj = document.getElementById(id);
            const range = end - start;
            const increment = range / (duration / 16);
            let current = start;

            const timer = setInterval(() => {
                current += increment;
                if ((increment > 0 && current >= end) || (increment < 0 && current <= end)) {
                    current = end;
                    clearInterval(timer);
                }
                obj.textContent = Math.round(current) + suffix;
            }, 16);
        }

        setTimeout(() => {
            animateValue('totalTasks', 0, 35, 1000);
            animateValue('completedTasks', 0, 28, 1000);
            animateValue('testCoverage', 0, 85, 1000, '%');
            animateValue('codeLines', 0, 1200, 1000);
            animateValue('commits', 0, 12, 1000);

            document.getElementById('avgTime').textContent = '2.5h';
            document.getElementById('dailyProgress').style.width = '70%';
            document.getElementById('dailyProgress').textContent = '70%';
            document.getElementById('completedCount').textContent = '7';
            document.getElementById('totalCount').textContent = '10';
            document.getElementById('remainingTime').textContent = '2.5h';
        }, 500);
    </script>
</body>
</html>
"@

    git_hook = @'
#!/bin/bash
# AI 开发记录 Git Hook

# 记录提交信息
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Commit: $1" >> .ai-dev-logs/commits.log

# 更新统计
if [ -f ".ai-dev-logs/metrics/git-stats.json" ]; then
    # 更新现有统计
    commits=$(jq '.commits + 1' .ai-dev-logs/metrics/git-stats.json)
    echo "{\"commits\": $commits, \"last_commit\": \"$(date -Iseconds)\"}" > .ai-dev-logs/metrics/git-stats.json
else
    # 创建新统计
    echo '{"commits": 1, "last_commit": "'$(date -Iseconds)'"}' > .ai-dev-logs/metrics/git-stats.json
fi

# 生成提交记录
cat << EOF >> .ai-dev-logs/commits/$(date +'%Y-%m-%d').md

## Commit at $(date +'%H:%M:%S')
- **Message**: $1
- **Files**: $(git diff --cached --name-only | wc -l) files changed
- **Stats**: $(git diff --cached --stat | tail -1)

EOF

exit 0
'@
}

# 检查是否强制重新初始化
if ((Test-Path ".ai-dev-logs") -and -not $Force) {
    Write-ColorHost "`n⚠️  AI 开发记录系统已存在" -Color "Warning"
    $response = Read-Host "是否要重新初始化？(y/N)"
    if ($response -ne 'y') {
        Write-ColorHost "初始化已取消" -Color "Detail"
        exit 0
    }
}

Write-ColorHost "`n📁 创建目录结构..." -Color "Info"

# 创建目录
$structure = $structures[$Level]
foreach ($dir in $structure.dirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-ColorHost "  ✅ $dir" -Color "Success"
    } else {
        Write-ColorHost "  ⏭️  $dir (已存在)" -Color "Detail"
    }
}

Write-ColorHost "`n📝 创建文件..." -Color "Info"

# 创建基础文件
foreach ($file in $structure.files) {
    $content = $templates[$file.content]
    if ($content) {
        Set-Content -Path $file.path -Value $content -Encoding UTF8
        Write-ColorHost "  ✅ $($file.path)" -Color "Success"
    }
}

# 创建配置文件
$configPath = ".ai-dev-logs/.ai-logs-config.yaml"
Set-Content -Path $configPath -Value $templates.config_yaml -Encoding UTF8
Write-ColorHost "  ✅ $configPath" -Color "Success"

# 创建模板文件
if ($Level -ne "minimal") {
    $templateFiles = @(
        @{ name = "task.md"; content = $templates.task_template }
        @{ name = "feature.md"; content = $templates.feature_template }
        @{ name = "adr.md"; content = $templates.adr_template }
        @{ name = "session.md"; content = $templates.session_template }
        @{ name = "daily.md"; content = @"
# 每日总结 - $(Get-Date -Format "yyyy-MM-dd")

## 📊 今日统计
- **完成任务**: 0/0 (0%)
- **代码变更**: +0行 / -0行
- **提交次数**: 0
- **测试通过率**: 0%
- **工作时长**: 0小时

## ✅ 已完成
| 任务 | 类型 | 耗时 | 成果 |
|-----|-----|-----|-----|
| - | - | - | - |

## 🚧 进行中
- **任务**: -
- **进度**: 0%
- **阻塞**: 无

## ❌ 未完成
- **任务**: -
- **原因**: -
- **计划**: -

## 💡 关键发现
1. -

## 🐛 问题追踪
| 问题 | 严重度 | 状态 | 解决方案 |
|------|--------|------|----------|
| - | - | - | - |

## 📝 学习与收获
- -

## 🎯 明日计划
1. [ ] 待规划

## 📎 相关链接
- -

---
*生成时间: $(Get-Date -Format "HH:mm:ss")*
"@ }
    )

    foreach ($tmpl in $templateFiles) {
        $path = ".ai-dev-logs/templates/$($tmpl.name)"
        Set-Content -Path $path -Value $tmpl.content -Encoding UTF8
        Write-ColorHost "  ✅ $path" -Color "Success"
    }

    # 创建第一个 ADR（如果是企业级）
    if ($Level -eq "enterprise") {
        $adr001Path = ".ai-dev-logs/architecture/decisions/ADR-001-initial-architecture.md"
        $adr001Content = @"
# ADR-001: 初始架构决策

## 状态
✅ 已采纳

## 日期
$(Get-Date -Format "yyyy-MM-dd")

## 上下文
项目初始化，需要确定基础架构和记录系统。

## 决策
采用 AI 开发记录系统 v2.0 作为项目记录和管理框架。

## 理由
1. 提供完整的任务追踪和记录
2. 支持多种级别的项目规模
3. 内置可视化仪表板
4. 自动化记录和报告生成

## 后果
### 积极影响
- ✅ 提高开发透明度
- ✅ 便于项目回顾和审计
- ✅ 知识沉淀和复用

### 消极影响
- ⚠️ 需要维护记录的习惯
- ⚠️ 初期有学习成本

## 实施状态
✅ 已完成初始化

---
*创建者: AI Assistant*
*日期: $(Get-Date -Format "yyyy-MM-dd")*
"@
        Set-Content -Path $adr001Path -Value $adr001Content -Encoding UTF8
        Write-ColorHost "  ✅ $adr001Path" -Color "Success"
    }
}

# 创建今日记录
$todayPath = if ($Level -eq "minimal") {
    ".ai-dev-logs/today.md"
} elseif ($Level -eq "standard") {
    ".ai-dev-logs/daily/$(Get-Date -Format 'yyyy-MM-dd').md"
} else {
    ".ai-dev-logs/development/daily/$(Get-Date -Format 'yyyy-MM-dd').md"
}

if ($Level -ne "minimal") {
    $todayDir = Split-Path $todayPath -Parent
    if (!(Test-Path $todayDir)) {
        New-Item -ItemType Directory -Path $todayDir -Force | Out-Null
    }
}

$todayContent = @"
# 每日总结 - $(Get-Date -Format "yyyy-MM-dd")

## 📊 今日统计
- **完成任务**: 0/0 (0%)
- **代码变更**: +0行 / -0行
- **测试通过率**: 0%
- **工作时长**: 0小时

## ✅ 已完成
_暂无记录_

## 🚧 进行中
_暂无记录_

## ❌ 未完成
_暂无记录_

## 💡 关键发现
_暂无记录_

## 🎯 明日计划
- [ ] 待规划

---
*创建时间: $(Get-Date -Format "HH:mm:ss")*
"@

if ($Level -ne "minimal" -or !(Test-Path $todayPath)) {
    Set-Content -Path $todayPath -Value $todayContent -Encoding UTF8
    Write-ColorHost "  ✅ $todayPath" -Color "Success"
}

# 创建仪表板（如果启用）
if ($WithDashboard) {
    Write-ColorHost "`n📊 创建可视化仪表板..." -Color "Info"
    $dashboardPath = ".ai-dev-logs/dashboard/index.html"
    Set-Content -Path $dashboardPath -Value $templates.dashboard_html -Encoding UTF8
    Write-ColorHost "  ✅ $dashboardPath" -Color "Success"
}

# 创建 Git Hooks（如果启用）
if ($WithGitHooks -and (Test-Path ".git")) {
    Write-ColorHost "`n🔗 配置 Git Hooks..." -Color "Info"

    $hookPath = ".git/hooks/pre-commit"
    Set-Content -Path $hookPath -Value $templates.git_hook -Encoding UTF8 -NoNewline

    # 设置可执行权限（在 Windows 上使用 attrib）
    if ($IsWindows -or $PSVersionTable.Platform -eq 'Win32NT') {
        # Windows 不需要特殊权限
        Write-ColorHost "  ✅ Git Hook 已创建（Windows）" -Color "Success"
    } else {
        # Unix-like 系统
        chmod +x $hookPath
        Write-ColorHost "  ✅ Git Hook 已创建并设置执行权限" -Color "Success"
    }
}

# 生成初始指标文件
if ($Level -ne "minimal") {
    $metricsDir = ".ai-dev-logs/metrics"
    $metricsPath = "$metricsDir/initial.json"

    # 确保metrics目录存在
    if (!(Test-Path $metricsDir)) {
        New-Item -ItemType Directory -Path $metricsDir -Force | Out-Null
    }

    $metricsContent = @{
        initialized = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        level = $Level
        projectSize = $ProjectSize
        teamSize = $TeamSize
        totalTasks = 0
        completedTasks = 0
        averageCompletionTime = 0
        testCoverage = 0
    } | ConvertTo-Json -Depth 3

    Set-Content -Path $metricsPath -Value $metricsContent -Encoding UTF8
    Write-ColorHost "`n📈 初始化指标..." -Color "Info"
    Write-ColorHost "  ✅ $metricsPath" -Color "Success"
}

# 完成提示
Write-ColorHost "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -Color "Detail"
Write-ColorHost "✨ AI 开发记录系统初始化完成!" -Color "Highlight"
Write-ColorHost "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -Color "Detail"

Write-ColorHost "`n📚 快速开始:" -Color "Info"
Write-ColorHost "  1. 查看文档: " -Color "Detail" -NoNewline
Write-ColorHost ".ai-dev-logs/README.md" -Color "Success"

if ($Level -ne "minimal") {
    Write-ColorHost "  2. 任务模板: " -Color "Detail" -NoNewline
    Write-ColorHost ".ai-dev-logs/templates/task.md" -Color "Success"
    Write-ColorHost "  3. 功能模板: " -Color "Detail" -NoNewline
    Write-ColorHost ".ai-dev-logs/templates/feature.md" -Color "Success"
}

Write-ColorHost "  4. 今日记录: " -Color "Detail" -NoNewline
Write-ColorHost "$todayPath" -Color "Success"

if ($WithDashboard) {
    Write-ColorHost "  5. 仪表板: " -Color "Detail" -NoNewline
    Write-ColorHost ".ai-dev-logs/dashboard/index.html" -Color "Success"
}

Write-ColorHost "`n💡 使用提示:" -Color "Warning"
Write-ColorHost "  • 使用 '/load dev-logs' 命令来加载记录模块" -Color "Detail"
Write-ColorHost "  • AI 助手会自动维护和更新记录文件" -Color "Detail"
Write-ColorHost "  • 定期查看仪表板了解项目进展" -Color "Detail"

if ($Level -eq "enterprise") {
    Write-ColorHost "  • 企业级功能：架构决策记录、知识管理、质量追踪" -Color "Detail"
}

Write-ColorHost "`n📊 配置信息:" -Color "Info"
Write-ColorHost "  • 记录级别: $Level" -Color "Detail"
Write-ColorHost "  • 项目规模: $ProjectSize" -Color "Detail"
Write-ColorHost "  • 团队规模: $TeamSize 人" -Color "Detail"
Write-ColorHost "  • 仪表板: $(if ($WithDashboard) { '已启用' } else { '未启用' })" -Color "Detail"
Write-ColorHost "  • Git集成: $(if ($WithGitHooks) { '已启用' } else { '未启用' })" -Color "Detail"

Write-ColorHost "`n🚀 下一步操作:" -Color "Highlight"
Write-ColorHost "  1. 开始记录第一个任务" -Color "Detail"
Write-ColorHost "  2. 查看模板了解记录格式" -Color "Detail"
Write-ColorHost "  3. 定制配置文件以适应项目需求" -Color "Detail"

# 返回成功状态
exit 0