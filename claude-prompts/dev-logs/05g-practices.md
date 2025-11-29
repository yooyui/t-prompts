# 子模块：最佳实践与指南

> 前置要求：`/load dev-logs-core`

## 实施计划

### 第一阶段：基础搭建（第1周）

#### Day 1-2: 环境准备
```bash
# 1. 初始化记录系统
.\claude-prompts\scripts\init-dev-logs.ps1 -Level minimal

# 2. 验证目录结构
ls .ai-dev-logs

# 3. 配置Git钩子
cp .ai-dev-logs/hooks/* .git/hooks/
chmod +x .git/hooks/*
```

#### Day 3-4: 模板配置
- [ ] 选择适合的模板
- [ ] 自定义模板内容
- [ ] 创建示例记录
- [ ] 验证模板效果

#### Day 5-7: 团队培训
- [ ] 编写使用指南
- [ ] 进行团队培训
- [ ] 收集反馈意见
- [ ] 调整配置

### 第二阶段：自动化增强（第2周）

#### 自动化清单
```javascript
// automation-checklist.js
const automationTasks = [
  {
    name: 'Git Hooks配置',
    priority: 1,
    scripts: [
      'pre-commit',
      'post-commit',
      'post-merge'
    ]
  },
  {
    name: '指标收集',
    priority: 2,
    scripts: [
      'metrics-collector.js',
      'quality-check.js'
    ]
  },
  {
    name: 'CI/CD集成',
    priority: 3,
    files: [
      '.github/workflows/dev-logs.yml',
      '.gitlab-ci.yml'
    ]
  },
  {
    name: '定时任务',
    priority: 4,
    cron: [
      '0 23 * * * daily-summary.js',
      '0 0 * * 0 weekly-report.js'
    ]
  }
];
```

### 第三阶段：可视化完善（第3周）

#### 仪表板开发步骤
1. **数据准备**
   ```javascript
   // 收集必要的数据
   const data = {
     tasks: collectTaskData(),
     metrics: collectMetrics(),
     trends: analyzeTrends()
   };
   ```

2. **界面设计**
   - 选择图表类型
   - 设计布局
   - 实现交互

3. **实时更新**
   - WebSocket连接
   - 数据推送
   - 自动刷新

### 第四阶段：持续优化（持续）

#### 优化检查表
- [ ] 性能监控
- [ ] 用户反馈收集
- [ ] 功能迭代
- [ ] 文档更新

## 记录原则

### 核心原则

1. **及时性原则**
   ```markdown
   ✅ 正确：任务开始时立即创建记录
   ❌ 错误：任务结束后补充记录
   ```

2. **完整性原则**
   ```markdown
   必须包含的要素：
   - What: 做了什么
   - Why: 为什么这样做
   - How: 怎么实现的
   - Result: 结果如何
   - Learning: 学到了什么
   ```

3. **准确性原则**
   ```markdown
   数据要求：
   - 时间精确到分钟
   - 数字使用具体值
   - 状态实时更新
   - 结果如实记录
   ```

4. **可读性原则**
   ```markdown
   格式要求：
   - 使用统一模板
   - 保持格式一致
   - 语言简洁明了
   - 适当使用图表
   ```

5. **可检索原则**
   ```markdown
   标签规范：
   #feature #bugfix #optimization
   #frontend #backend #database
   #high-priority #low-priority
   ```

## 应该做的和应该避免的

### ✅ 应该做的

#### 1. 实时记录
```javascript
// 正确的记录时机
async function startTask(taskName) {
  // 立即创建记录
  const logId = await createLog({
    task: taskName,
    startTime: new Date(),
    status: 'started'
  });

  // 执行任务
  await executeTask();

  // 更新记录
  await updateLog(logId, {
    endTime: new Date(),
    status: 'completed'
  });
}
```

#### 2. 详细决策记录
```markdown
## 决策记录
**问题**: 选择状态管理方案
**选项**:
1. Redux - 成熟但复杂
2. MobX - 简单但生态较小
3. Context API - 原生但功能有限

**决定**: 选择Redux
**原因**:
- 团队熟悉
- 生态成熟
- 便于调试
- 时间旅行功能
```

#### 3. 定期归档
```bash
# 每周归档脚本
#!/bin/bash
ARCHIVE_DIR=".ai-dev-logs/archive/$(date +%Y-%m)"
mkdir -p "$ARCHIVE_DIR"
mv .ai-dev-logs/daily/*.md "$ARCHIVE_DIR/"
echo "✅ 归档完成: $ARCHIVE_DIR"
```

#### 4. 指标追踪
```javascript
// 持续监控关键指标
const metrics = {
  taskCompletion: trackTaskCompletion(),
  codeQuality: trackCodeQuality(),
  performance: trackPerformance(),
  teamProductivity: trackProductivity()
};

// 生成趋势报告
generateTrendReport(metrics);
```

#### 5. 知识沉淀
```markdown
## 经验总结
### 本周学到的
1. **性能优化**: 使用虚拟滚动处理长列表
2. **错误处理**: 实现全局错误边界
3. **测试策略**: TDD提高代码质量

### 最佳实践
- 代码审查前先自测
- 提交前运行linter
- 文档先行开发
```

### ❌ 应该避免的

#### 1. 过度记录
```javascript
// ❌ 错误：记录过多琐碎细节
log('打开VSCode');
log('创建新文件');
log('输入第一行代码');
log('保存文件');

// ✅ 正确：记录关键节点
log('任务开始：实现用户认证');
log('完成JWT集成');
log('通过所有测试');
```

#### 2. 格式混乱
```markdown
❌ 错误：格式不一致
今天完成了认证功能。
- 2024/11/8 修复了一个bug
【性能】优化了查询

✅ 正确：统一格式
## 2024-11-08 任务记录

### 完成
- ✅ 实现用户认证功能
- ✅ 修复登录bug
- ✅ 优化数据库查询性能
```

#### 3. 忽视安全
```javascript
// ❌ 错误：记录敏感信息
log({
  apiKey: 'sk-1234567890',
  password: 'admin123',
  database: 'mongodb://user:pass@host'
});

// ✅ 正确：脱敏处理
log({
  apiKey: '[REDACTED]',
  password: '[HIDDEN]',
  database: 'mongodb://[CREDENTIALS]@host'
});
```

#### 4. 延迟更新
```javascript
// ❌ 错误：积压更新
// 周五一次性更新本周所有记录

// ✅ 正确：及时更新
// 每完成一个子任务就更新状态
updateTaskStatus(taskId, 'step1_completed');
```

#### 5. 忽视维护
```bash
# ❌ 错误：从不清理
# .ai-dev-logs/ 目录达到 10GB

# ✅ 正确：定期维护
# 自动归档和压缩
find .ai-dev-logs -type f -mtime +30 -exec gzip {} \;
```

## 常见错误示例

### 错误示例1：简略记录
```javascript
// ❌ 错误
log("Done");
log("Fixed");
log("OK");
```

### 错误示例2：冗长记录
```javascript
// ❌ 错误
log(`
  今天早上9点开始工作，首先打开电脑，然后打开VSCode，
  接着打开项目文件夹，然后查看昨天的代码，思考了一下
  今天要做什么，决定先喝杯咖啡....[500字省略]
`);
```

### 错误示例3：缺乏结构
```javascript
// ❌ 错误
log("fixed bug, added feature, tested, deployed, documented");
```

### 正确示例：结构化记录
```javascript
// ✅ 正确
log({
  timestamp: new Date().toISOString(),
  action: "bug_fixed",
  details: {
    component: "user_auth",
    issue: "Token过期未处理",
    solution: "添加refresh token机制",
    impact: "改善用户体验",
    testing: "通过所有测试"
  },
  metrics: {
    timeSpent: "2小时",
    linesChanged: "+45/-12",
    testsAdded: 3
  },
  nextSteps: ["代码审查", "部署到测试环境"]
});
```

## 性能优化建议

### 1. 异步批量写入
```javascript
class LogBuffer {
  constructor(flushInterval = 5000, batchSize = 100) {
    this.buffer = [];
    this.flushInterval = flushInterval;
    this.batchSize = batchSize;
    this.startAutoFlush();
  }

  log(entry) {
    this.buffer.push({
      ...entry,
      timestamp: Date.now()
    });

    // 缓冲区满时立即刷新
    if (this.buffer.length >= this.batchSize) {
      this.flush();
    }
  }

  async flush() {
    if (this.buffer.length === 0) return;

    const entries = [...this.buffer];
    this.buffer = [];

    // 批量写入
    await this.writeBatch(entries);
  }

  async writeBatch(entries) {
    // 使用事务批量写入
    const transaction = await this.beginTransaction();
    try {
      for (const entry of entries) {
        await transaction.write(entry);
      }
      await transaction.commit();
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }

  startAutoFlush() {
    setInterval(() => this.flush(), this.flushInterval);
  }
}
```

### 2. 索引优化
```javascript
class IndexOptimizer {
  optimizeIndex(logs) {
    // 创建多维索引
    const index = {
      byDate: new Map(),
      byType: new Map(),
      byTag: new Map(),
      byStatus: new Map()
    };

    // 一次遍历建立所有索引
    for (const log of logs) {
      // 日期索引
      const date = log.date.split('T')[0];
      if (!index.byDate.has(date)) {
        index.byDate.set(date, []);
      }
      index.byDate.get(date).push(log);

      // 类型索引
      if (!index.byType.has(log.type)) {
        index.byType.set(log.type, []);
      }
      index.byType.get(log.type).push(log);

      // 标签索引
      for (const tag of log.tags || []) {
        if (!index.byTag.has(tag)) {
          index.byTag.set(tag, []);
        }
        index.byTag.get(tag).push(log);
      }

      // 状态索引
      if (!index.byStatus.has(log.status)) {
        index.byStatus.set(log.status, []);
      }
      index.byStatus.get(log.status).push(log);
    }

    return index;
  }
}
```

### 3. 缓存策略
```javascript
class LogCache {
  constructor(maxSize = 1000, ttl = 3600000) {
    this.cache = new Map();
    this.maxSize = maxSize;
    this.ttl = ttl;
  }

  get(key) {
    const item = this.cache.get(key);
    if (!item) return null;

    // 检查过期
    if (Date.now() > item.expiry) {
      this.cache.delete(key);
      return null;
    }

    // LRU: 移到末尾
    this.cache.delete(key);
    this.cache.set(key, item);

    return item.value;
  }

  set(key, value) {
    // 容量检查
    if (this.cache.size >= this.maxSize) {
      // 删除最旧的项
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }

    this.cache.set(key, {
      value,
      expiry: Date.now() + this.ttl
    });
  }

  clear() {
    this.cache.clear();
  }
}
```

## 故障排除

### 问题1：记录文件过大
```bash
# 诊断
du -sh .ai-dev-logs/*

# 解决方案
# 1. 归档旧文件
find .ai-dev-logs -name "*.md" -mtime +30 -exec mv {} archive/ \;

# 2. 压缩归档
tar -czf archive-$(date +%Y%m).tar.gz archive/*.md

# 3. 清理临时文件
find .ai-dev-logs -name "*.tmp" -delete
```

### 问题2：记录丢失
```javascript
// 实现可靠性保障
class ResilientLogger {
  async log(data) {
    try {
      // 主存储
      await this.writeToFile(data);
    } catch (error) {
      // 备份存储
      await this.writeToBackup(data);

      // 队列重试
      this.retryQueue.push({
        data,
        attempts: 0,
        error
      });

      // 异步重试
      this.scheduleRetry();
    }
  }

  async scheduleRetry() {
    setTimeout(async () => {
      const pending = [...this.retryQueue];
      this.retryQueue = [];

      for (const item of pending) {
        if (item.attempts < 3) {
          item.attempts++;
          try {
            await this.writeToFile(item.data);
          } catch {
            this.retryQueue.push(item);
          }
        }
      }

      if (this.retryQueue.length > 0) {
        this.scheduleRetry();
      }
    }, 5000);
  }
}
```

### 问题3：记录不一致
```javascript
// 添加验证机制
class LogValidator {
  validate(log) {
    const errors = [];

    // 必填字段检查
    const required = ['timestamp', 'action', 'status'];
    for (const field of required) {
      if (!log[field]) {
        errors.push(`Missing required field: ${field}`);
      }
    }

    // 格式验证
    if (log.timestamp && !this.isValidDate(log.timestamp)) {
      errors.push('Invalid timestamp format');
    }

    // 状态验证
    const validStatuses = ['pending', 'in_progress', 'completed', 'failed'];
    if (log.status && !validStatuses.includes(log.status)) {
      errors.push(`Invalid status: ${log.status}`);
    }

    if (errors.length > 0) {
      throw new ValidationError(errors);
    }

    return true;
  }

  isValidDate(date) {
    return !isNaN(Date.parse(date));
  }
}
```

## 完整配置示例

```yaml
# .ai-logs-config.yaml - 完整配置
version: 2.0

# 基础配置
general:
  enabled: true
  level: standard
  language: zh-CN
  timezone: Asia/Shanghai

# 目录配置
paths:
  root: .ai-dev-logs
  templates: ${root}/templates
  daily: ${root}/daily
  features: ${root}/features
  metrics: ${root}/metrics
  archive: ${root}/archive
  backup: ${root}/.backup

# 自动化配置
automation:
  # 自动记录
  auto_log:
    enabled: true
    triggers:
      - file_save
      - test_run
      - commit
      - merge

  # 自动归档
  auto_archive:
    enabled: true
    schedule: "0 0 * * 0"  # 每周日
    older_than_days: 30
    compress: true

  # 自动索引
  auto_index:
    enabled: true
    rebuild_interval: 3600000  # 每小时
    incremental: true

  # 自动标签
  auto_tag:
    enabled: true
    rules:
      - pattern: "feat|feature"
        tag: "feature"
      - pattern: "fix|bug"
        tag: "bugfix"
      - pattern: "perf|optimize"
        tag: "optimization"

# 记录规则
logging:
  # 记录级别
  levels:
    - critical
    - important
    - standard
    - verbose

  # 过滤规则
  filters:
    include:
      - "*.js"
      - "*.ts"
      - "*.py"
    exclude:
      - "node_modules/**"
      - "*.min.js"
      - "*.map"

  # 采样率
  sampling:
    rate: 1.0  # 100%记录
    rules:
      verbose: 0.1  # verbose级别只记录10%

# 性能配置
performance:
  buffer_size: 100
  flush_interval: 5000
  max_file_size: 10485760  # 10MB
  compression:
    enabled: true
    algorithm: gzip
    level: 6

  cache:
    enabled: true
    size: 1000
    ttl: 3600000  # 1小时

# 集成配置
integrations:
  git:
    enabled: true
    hooks:
      - pre-commit
      - post-commit
      - post-merge

  github:
    enabled: true
    token: ${GITHUB_TOKEN}
    features:
      create_issues: true
      update_pr: true
      post_comments: true

  slack:
    enabled: false
    webhook: ${SLACK_WEBHOOK_URL}
    channels:
      errors: "#dev-errors"
      daily: "#dev-daily"
      alerts: "#dev-alerts"

  email:
    enabled: false
    smtp:
      host: smtp.gmail.com
      port: 587
      user: ${EMAIL_USER}
      pass: ${EMAIL_PASS}
    recipients:
      - team@example.com

# 导出配置
export:
  formats:
    - markdown
    - html
    - json
    - pdf

  schedule:
    daily: "23:59"
    weekly: "sun 23:59"
    monthly: "last-day 23:59"

  destinations:
    local: ./reports
    remote: s3://bucket/reports

# 安全配置
security:
  # 敏感信息过滤
  sanitize:
    enabled: true
    patterns:
      - password
      - token
      - secret
      - apikey
      - credential

  # 加密
  encryption:
    enabled: false
    algorithm: aes-256-gcm
    key: ${ENCRYPTION_KEY}

  # 访问控制
  access_control:
    enabled: false
    roles:
      admin: [read, write, delete]
      developer: [read, write]
      viewer: [read]

# 告警配置
alerts:
  enabled: true

  # 告警规则
  rules:
    - name: high_error_rate
      condition: "error_rate > 5"
      severity: critical
      notification: [email, slack]

    - name: low_test_coverage
      condition: "coverage < 60"
      severity: warning
      notification: [slack]

    - name: long_task_duration
      condition: "duration > 3600000"
      severity: info
      notification: [console]

  # 通知渠道
  channels:
    console:
      enabled: true
      format: text

    file:
      enabled: true
      path: ${paths.root}/alerts.log
      format: json

    webhook:
      enabled: false
      url: ${ALERT_WEBHOOK_URL}
      format: json

# 可视化配置
dashboard:
  enabled: true
  port: 3000
  host: localhost
  auto_open: true
  refresh_interval: 60000

  # 图表配置
  charts:
    - id: task_completion
      type: line
      data: tasks.completed
      refresh: 300000

    - id: code_changes
      type: bar
      data: git.stats
      refresh: 600000

    - id: test_coverage
      type: gauge
      data: tests.coverage
      refresh: 1800000

    - id: performance
      type: radar
      data: metrics.performance
      refresh: 300000

# 备份配置
backup:
  enabled: true
  schedule: "0 2 * * *"  # 每天凌晨2点
  retention_days: 30
  destinations:
    - type: local
      path: ${paths.backup}
    - type: cloud
      provider: s3
      bucket: ${BACKUP_BUCKET}
```

---

**子模块名称**：最佳实践与指南
**父模块**：dev-logs-core
**功能**：实施计划、使用规范、故障排除、配置示例
**适用场景**：所有需要规范化管理的项目