# 模块：项目配置模板

## 项目类型快速配置

### React 应用
```markdown
# .claude/project.md
type: react-app
modules: principles, workflow, testing

## 项目约定
- 组件：函数式组件 + Hooks
- 状态：Context API / Redux Toolkit
- 样式：CSS Modules / Styled Components
- 测试：Jest + React Testing Library

## 开发流程
1. 组件开发遵循 TDD
2. 每个组件必须有 .test.tsx 文件
3. 提交前运行 lint 和 test
```

### Node.js API
```markdown
# .claude/project.md
type: nodejs-api
modules: principles, workflow, security

## 项目约定
- 框架：Express / Fastify
- 数据库：PostgreSQL + Prisma
- 认证：JWT
- 测试：Jest + Supertest

## API 规范
- RESTful 设计
- 版本化路由 (/api/v1/)
- 统一错误处理
- 请求验证 (Joi/Zod)
```

### 全栈应用
```markdown
# .claude/project.md
type: fullstack
modules: principles, workflow, mcp-services, dev-logs

## 技术栈
- 前端：Next.js + TypeScript
- 后端：Node.js + Express
- 数据库：PostgreSQL
- 部署：Docker + K8s

## 开发规范
- Monorepo 结构 (pnpm workspaces)
- 共享类型定义
- E2E 测试 (Playwright)
```

## 项目初始化模板

### 基础项目结构
```bash
project/
├── .claude/              # AI 配置
│   ├── project.md       # 项目特定配置
│   └── local.md         # 本地覆盖（不提交）
├── .ai-dev-logs/        # AI 开发记录
├── src/                 # 源代码
├── tests/               # 测试文件
├── docs/                # 文档
└── README.md
```

### 初始化脚本
```bash
#!/bin/bash
# init-project.sh

PROJECT_TYPE=$1
PROJECT_NAME=$2

# 创建基础结构
mkdir -p $PROJECT_NAME/{.claude,.ai-dev-logs,src,tests,docs}

# 创建项目配置
cat > $PROJECT_NAME/.claude/project.md << EOF
# 项目：$PROJECT_NAME
type: $PROJECT_TYPE
modules: principles, workflow, dev-logs

## 项目信息
- 名称：$PROJECT_NAME
- 类型：$PROJECT_TYPE
- 创建时间：$(date +%Y-%m-%d)

## 开发规范
[根据项目类型自定义]

## 自动加载模块
- principles: 编程原则
- workflow: 工作流程
- dev-logs: 开发记录
EOF

echo "✅ 项目 $PROJECT_NAME 已初始化"
```

## 项目特定配置示例

### 微服务项目
```markdown
# .claude/project.md
type: microservices
modules: principles, workflow, mcp-services

## 服务列表
- auth-service: 认证服务
- user-service: 用户服务
- order-service: 订单服务

## 通信方式
- 同步：REST API
- 异步：RabbitMQ

## 部署策略
- 容器化：Docker
- 编排：Kubernetes
- CI/CD：GitLab CI

## 服务规范
每个服务必须包含：
- Dockerfile
- .env.example
- README.md
- /health 端点
- OpenAPI 文档
```

### 数据密集型项目
```markdown
# .claude/project.md
type: data-intensive
modules: performance, mcp-services

## 数据处理
- ETL：Apache Airflow
- 存储：S3 + PostgreSQL
- 缓存：Redis
- 搜索：Elasticsearch

## 性能目标
- 查询响应：< 100ms
- 批处理：> 1M records/min
- 并发用户：> 10K

## 优化策略
- 数据分区
- 索引优化
- 查询缓存
- 异步处理
```

### AI/ML 项目
```markdown
# .claude/project.md
type: ml-project
modules: workflow, dev-logs

## 项目阶段
1. 数据准备
2. 特征工程
3. 模型训练
4. 评估验证
5. 部署监控

## 工具链
- 框架：PyTorch / TensorFlow
- 实验：MLflow
- 部署：TorchServe
- 监控：Prometheus + Grafana

## 记录要求
- 每次实验记录参数和结果
- 保存模型版本
- 记录数据集变更
```

## 环境特定配置

### 开发环境
```markdown
# .claude/local.dev.md
env: development
modules: dev-logs

## 开发设置
- 热重载：启用
- 日志级别：DEBUG
- Mock 数据：启用

## 本地服务
- 数据库：Docker PostgreSQL
- 缓存：Docker Redis
- 消息队列：Docker RabbitMQ
```

### 生产环境
```markdown
# .claude/local.prod.md
env: production
modules: security, performance

## 生产设置
- 日志级别：INFO
- 错误监控：Sentry
- APM：Datadog

## 安全要求
- HTTPS 强制
- Rate limiting
- WAF 规则
```

## 团队协作配置

### 代码审查规范
```markdown
# .claude/review.md
modules: code-review

## PR 要求
- [ ] 通过所有测试
- [ ] 代码覆盖率 > 80%
- [ ] 无 linting 错误
- [ ] 更新文档
- [ ] 添加变更日志

## 审查重点
1. 业务逻辑正确性
2. 性能影响
3. 安全隐患
4. 代码可读性
```

### 提交规范
```markdown
# .claude/commit.md

## 提交格式
type(scope): subject

## 类型
- feat: 新功能
- fix: 修复
- docs: 文档
- style: 格式
- refactor: 重构
- test: 测试
- chore: 构建

## 示例
feat(auth): add JWT refresh token
fix(api): handle null response
docs(readme): update installation guide
```

## 配置继承链

```
全局配置 (CLAUDE_CORE.md)
    ↓
项目类型模板 (project-type.md)
    ↓
项目配置 (.claude/project.md)
    ↓
本地配置 (.claude/local.md)
```

## 配置优先级
1. 本地配置（最高）
2. 项目配置
3. 模板配置
4. 全局配置（最低）

## 动态加载示例

### 根据任务加载
```bash
# 任务：性能优化
/load performance

# 任务：安全审计
/load security, code-review

# 任务：新功能开发
/load workflow, testing, dev-logs
```

### 条件加载
```yaml
# 项目配置中的条件加载
conditions:
  - if: project.size > 'large'
    modules: task-management

  - if: project.type == 'api'
    modules: security, performance

  - if: env == 'production'
    modules: monitoring
```

---
**模块类型**：项目配置
**适用场景**：项目初始化、团队协作
**配合模块**：所有其他模块