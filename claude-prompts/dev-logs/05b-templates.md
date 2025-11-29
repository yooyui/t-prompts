# 子模块：模板系统

> 前置要求：`/load dev-logs-core`

## 增强版任务记录模板

```markdown
# 任务记录 - [任务名称]

## 元信息
- **任务ID**: TASK-$(date +%Y-%m-%d)-XXX
- **创建时间**: $(date +"%Y-%m-%d %H:%M:%S")
- **完成时间**: [待填写]
- **耗时**: [自动计算]
- **状态**: 📋 计划中 | 🚀 开始 | 🚧 进行中 | ✅ 完成 | ❌ 失败 | ⏸️ 暂停
- **优先级**: 🔥 P0 | ⚡ P1 | 📌 P2 | 📝 P3
- **标签**: #authentication #backend #api

## 任务描述
[清晰的任务描述和业务背景]

## 输入条件
- [ ] 前置条件1
- [ ] 前置条件2
- [ ] 依赖项

## 实施步骤
- [x] Step 1: 分析需求
  - 子步骤 1.1: 理解业务逻辑
  - 子步骤 1.2: 确定技术方案
- [x] Step 2: 编写代码
  - 实现核心逻辑
  - 添加错误处理
- [ ] Step 3: 测试验证
- [ ] Step 4: 文档更新

## 关键决策
| 决策点 | 选项 | 最终选择 | 原因 |
|--------|------|---------|------|
| 认证方式 | JWT/Session/OAuth | JWT | 无状态、可扩展 |
| 加密算法 | bcrypt/argon2/pbkdf2 | bcrypt | 成熟稳定、社区支持好 |
| 存储方案 | Redis/Memory/Database | Redis | 性能好、支持过期 |

## 代码变更
### 新增文件
\`\`\`
src/
├── auth/
│   ├── jwt.service.ts       # JWT服务实现
│   ├── auth.guard.ts        # 认证守卫
│   └── auth.module.ts       # 认证模块
\`\`\`

### 修改文件
| 文件路径 | 变更类型 | 行数变化 | 说明 |
|---------|---------|----------|------|
| `src/user/user.controller.ts` | 修改 | +45/-10 | 添加登录端点 |
| `src/app.module.ts` | 修改 | +5/-0 | 注册认证模块 |

## 测试结果
\`\`\`json
{
  "unit_tests": {
    "total": 15,
    "passed": 15,
    "failed": 0,
    "coverage": 87.5
  },
  "integration_tests": {
    "total": 5,
    "passed": 5,
    "failed": 0
  },
  "e2e_tests": {
    "total": 3,
    "passed": 3,
    "failed": 0
  }
}
\`\`\`

## 性能指标
| 指标 | 目标值 | 实际值 | 状态 |
|------|-------|--------|------|
| 响应时间 | < 200ms | 120ms | ✅ |
| 内存增量 | < 10MB | 5MB | ✅ |
| CPU使用率 | < 10% | 3% | ✅ |
| 并发支持 | 1000/s | 1500/s | ✅ |

## 问题与解决
### 问题1: [问题标题]
- **现象**:
- **根因**:
- **解决**:
- **预防**:

## AI 反思与学习
### 做得好的地方
- ✅
- ✅

### 可改进的地方
- ⚠️
- ⚠️

### 学到的知识
-
-

## 后续任务
- [ ]
- [ ]

## 相关链接
- [需求文档](../planning/requirements.md)
- [API文档](../artifacts/docs/api.md)
- [测试报告](../testing/test-results.md)
```

## 每日总结模板

```markdown
# 每日总结 - [日期]

## 📊 今日统计
- **完成任务**：X/Y (Z%)
- **代码变更**：+X行 / -Y行
- **提交次数**：X
- **测试通过率**：X%
- **工作时长**：X小时

## ✅ 已完成
| 任务 | 类型 | 耗时 | 成果 |
|-----|-----|-----|-----|
| | | | |

## 🚧 进行中
- **任务**：
- **进度**：X%
- **阻塞**：

## ❌ 未完成
- **任务**：
- **原因**：
- **计划**：

## 💡 关键发现
1.
2.
3.

## 📈 性能趋势
\`\`\`
[可视化图表]
\`\`\`

## 🎯 明日计划
1. [ ] (P0)
2. [ ] (P1)
3. [ ] (P2)

## 📝 备注
```

## 功能开发记录模板

```markdown
# 功能：[功能名称]

## 概述
**模块**：[所属模块]
**版本**：v1.0.0
**负责人**：AI Assistant
**状态**：规划中 | 开发中 | 测试中 | 已发布

## 需求分析
### 业务需求
[业务背景和目标]

### 技术需求
- 性能：
- 安全：
- 兼容性：

## 设计方案
### 架构设计
\`\`\`mermaid
graph TB
  A[组件A] --> B[组件B]
\`\`\`

### 数据模型
\`\`\`typescript
interface Model {
  // ...
}
\`\`\`

## 实施记录
### Phase 1: 基础功能
- [ ]
- [ ]

### Phase 2: 核心功能
- [ ]
- [ ]

### Phase 3: 高级功能
- [ ]
- [ ]

## 测试记录
### 单元测试
- 覆盖率：X%
- 通过率：X%

### 集成测试
- 场景覆盖：X/Y
- 问题发现：X个

### 性能测试
- 并发用户：X
- 响应时间：P95 < Xms
- 错误率：< X%

## 部署记录
### 环境配置
- 开发环境：✅/⏳/❌
- 测试环境：✅/⏳/❌
- 生产环境：✅/⏳/❌

### 发布历史
| 版本 | 日期 | 变更内容 | 回滚计划 |
|-----|-----|---------|---------|
| | | | |

## 监控指标
- 可用性：X%
- 错误率：X%
- 平均响应时间：Xms

## 问题追踪
| ID | 问题描述 | 严重程度 | 状态 | 解决方案 |
|----|---------|---------|------|---------|
| | | | | |

## 经验总结
### 成功经验
1.
2.

### 教训
1.
2.

## 相关文档
- [API文档](./api-docs.md)
- [测试报告](./test-reports/)
- [部署手册](./deployment-guide.md)
```

## 专项模板

### 决策记录模板（ADR）

```markdown
# ADR-[编号]: [决策标题]

## 状态
[提议/接受/拒绝/废弃/取代]

## 上下文
[描述导致需要做出决策的技术、政治、社会和项目背景]

## 决策
[描述我们的回应]

## 后果
[描述应用决策后的结果上下文。所有后果都应该列出，不仅是"积极的"。]

## 选项考虑
### 选项1：[名称]
- **优点**：
- **缺点**：
- **风险**：

### 选项2：[名称]
- **优点**：
- **缺点**：
- **风险**：

## 相关决策
- ADR-XXX: [相关决策]

## 更新历史
- [日期] - [更新内容]
```

### Bug修复模板

```markdown
# Bug修复 - [BUG-ID]

## 问题描述
**报告人**：
**发现时间**：
**严重程度**：🔥 紧急 | ⚡ 高 | 📌 中 | 📝 低
**影响范围**：

## 复现步骤
1.
2.
3.

## 期望行为
[描述正确的行为应该是什么]

## 实际行为
[描述当前的错误行为]

## 根因分析
### 调试过程
1.
2.

### 根本原因
[技术层面的根本原因]

## 解决方案
### 代码修改
\`\`\`diff
- 旧代码
+ 新代码
\`\`\`

### 测试验证
- [ ] 单元测试
- [ ] 集成测试
- [ ] 回归测试

## 影响评估
- **兼容性**：
- **性能影响**：
- **安全影响**：

## 预防措施
[如何避免类似问题再次发生]

## 相关链接
- Issue: #XXX
- PR: #XXX
- 测试用例：
```

### 性能优化模板

```markdown
# 性能优化 - [优化项]

## 优化目标
- **当前性能**：
- **目标性能**：
- **优化指标**：响应时间 | 吞吐量 | 内存 | CPU

## 性能分析
### 瓶颈识别
1.
2.

### 测量数据
| 指标 | 优化前 | 优化后 | 改善 |
|-----|-------|--------|-----|
| | | | |

## 优化方案
### 方案1：[名称]
- **实施内容**：
- **预期效果**：
- **风险评估**：

### 方案2：[名称]
- **实施内容**：
- **预期效果**：
- **风险评估**：

## 实施记录
### 代码优化
\`\`\`javascript
// 优化前
// 优化后
\`\`\`

### 配置调整
| 参数 | 原值 | 新值 | 说明 |
|-----|-----|-----|-----|
| | | | |

## 验证结果
### 基准测试
\`\`\`
[测试结果]
\`\`\`

### 压力测试
- 并发数：
- 持续时间：
- 错误率：

## 监控计划
- [ ] 设置性能监控
- [ ] 配置告警阈值
- [ ] 定期复查

## 经验总结
```

## 动态模板生成

```javascript
class TemplateGenerator {
  constructor() {
    this.templates = new Map();
    this.loadTemplates();
  }

  loadTemplates() {
    // 加载预定义模板
    this.templates.set('task', this.taskTemplate);
    this.templates.set('daily', this.dailyTemplate);
    this.templates.set('feature', this.featureTemplate);
    this.templates.set('bug', this.bugTemplate);
    this.templates.set('adr', this.adrTemplate);
  }

  generate(type, data = {}) {
    const template = this.templates.get(type);
    if (!template) {
      throw new Error(`Unknown template type: ${type}`);
    }

    return this.render(template(), data);
  }

  render(template, data) {
    // 简单的模板渲染
    return template.replace(/\{\{(\w+)\}\}/g, (match, key) => {
      return data[key] || match;
    });
  }

  // 智能选择模板
  selectTemplate(context) {
    if (context.type === 'bug' || context.error) {
      return 'bug';
    }
    if (context.type === 'feature') {
      return 'feature';
    }
    if (context.type === 'decision') {
      return 'adr';
    }
    if (context.daily) {
      return 'daily';
    }
    return 'task';
  }

  // 自定义模板
  registerCustomTemplate(name, template) {
    this.templates.set(name, template);
  }

  taskTemplate() {
    return `# 任务记录 - {{name}}

## 元信息
- **任务ID**: {{id}}
- **创建时间**: {{created}}
- **状态**: {{status}}

## 描述
{{description}}

## 实施步骤
{{steps}}

## 结果
{{results}}
`;
  }

  dailyTemplate() {
    return `# 每日总结 - {{date}}

## 今日统计
- **完成任务**：{{completed}}/{{total}}
- **代码变更**：+{{additions}}行 / -{{deletions}}行

## 已完成
{{completedTasks}}

## 明日计划
{{tomorrowPlan}}
`;
  }
}

// 使用示例
const generator = new TemplateGenerator();

// 生成任务记录
const taskRecord = generator.generate('task', {
  name: '实现用户认证',
  id: 'TASK-2024-001',
  created: new Date().toISOString(),
  status: '进行中',
  description: '实现JWT认证系统',
  steps: '1. 设计API\n2. 实现服务\n3. 添加测试',
  results: '待完成'
});

// 智能选择模板
const context = { type: 'bug', error: true };
const templateType = generator.selectTemplate(context);
const bugRecord = generator.generate(templateType, {
  // bug数据
});
```

## 模板验证器

```javascript
class TemplateValidator {
  validate(record, templateType) {
    const rules = this.getValidationRules(templateType);
    const errors = [];

    for (const rule of rules) {
      if (!rule.validate(record)) {
        errors.push({
          field: rule.field,
          message: rule.message
        });
      }
    }

    return {
      valid: errors.length === 0,
      errors
    };
  }

  getValidationRules(templateType) {
    const rules = {
      task: [
        {
          field: 'name',
          validate: (r) => r.name && r.name.length > 0,
          message: '任务名称不能为空'
        },
        {
          field: 'status',
          validate: (r) => ['pending', 'in_progress', 'completed'].includes(r.status),
          message: '无效的任务状态'
        }
      ],
      bug: [
        {
          field: 'severity',
          validate: (r) => ['critical', 'high', 'medium', 'low'].includes(r.severity),
          message: '无效的严重程度'
        },
        {
          field: 'steps',
          validate: (r) => r.steps && r.steps.length > 0,
          message: '复现步骤不能为空'
        }
      ]
    };

    return rules[templateType] || [];
  }
}
```

---

**子模块名称**：模板系统
**父模块**：dev-logs-core
**功能**：提供各类记录模板和动态生成
**适用场景**：需要标准化记录格式的项目