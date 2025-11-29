# 子模块：记录规则与行为

> 前置要求：`/load dev-logs-core`

## 自动记录规则

### 触发时机与级别

```yaml
# 记录配置 (.ai-logs-config.yaml)
logging:
  levels:
    critical:     # 必须记录
      - task_start
      - task_complete
      - major_error
      - architecture_decision

    important:    # 重要记录
      - milestone_reached
      - performance_issue
      - security_concern
      - code_refactoring

    standard:     # 标准记录
      - file_changes
      - test_results
      - dependencies_update
      - api_changes

    verbose:      # 详细记录
      - debug_info
      - minor_decisions
      - exploration_paths
      - rejected_solutions
```

### 记录行为规范

```javascript
// ❌ 错误示例：无记录或记录不规范
async function implementFeature(featureName) {
  // 直接开始编码，没有记录
  const code = writeCode();
  await saveFile(code);
  console.log("Done");
}

// ✅ 正确示例：完整的记录流程
async function implementFeature(featureName) {
  // 1. 任务开始记录
  const taskId = await logTaskStart({
    name: featureName,
    type: 'feature',
    estimatedTime: '2h',
    timestamp: new Date()
  });

  try {
    // 2. 记录关键决策
    await logDecision({
      taskId,
      decision: 'Using React hooks instead of class components',
      reason: 'Better performance and cleaner code',
      alternatives: ['Class components', 'Redux']
    });

    // 3. 记录代码变更
    const changes = await implementChanges();
    await logCodeChanges({
      taskId,
      files: changes.files,
      additions: changes.stats.additions,
      deletions: changes.stats.deletions
    });

    // 4. 记录测试结果
    const testResults = await runTests();
    await logTestResults({
      taskId,
      passed: testResults.passed,
      failed: testResults.failed,
      coverage: testResults.coverage
    });

    // 5. 任务完成记录
    await logTaskComplete({
      taskId,
      actualTime: calculateDuration(),
      status: 'success',
      summary: generateSummary()
    });

  } catch (error) {
    // 6. 错误记录
    await logError({
      taskId,
      error: error.message,
      stack: error.stack,
      context: getCurrentContext()
    });
    throw error;
  }
}
```

## 动态结构选择

```javascript
// 根据项目规模自动选择记录级别
function selectLogLevel(projectSize, teamSize, complexity) {
  // 评分系统
  let score = 0;

  // 项目规模评分
  score += projectSize === 'large' ? 3 :
           projectSize === 'medium' ? 2 : 1;

  // 团队规模评分
  score += teamSize > 10 ? 3 :
           teamSize > 5 ? 2 : 1;

  // 复杂度评分
  score += complexity === 'high' ? 3 :
           complexity === 'medium' ? 2 : 1;

  // 根据总分确定记录级别
  if (score >= 7) {
    return 'verbose';     // 详细记录
  } else if (score >= 5) {
    return 'standard';    // 标准记录
  } else if (score >= 3) {
    return 'important';   // 重要记录
  } else {
    return 'critical';    // 仅关键记录
  }
}
```

## 记录触发器配置

```javascript
class RecordingTrigger {
  constructor(config) {
    this.config = config;
    this.triggers = new Map();
    this.setupTriggers();
  }

  setupTriggers() {
    // 文件变更触发器
    this.triggers.set('file_change', {
      condition: (event) => event.type === 'change',
      action: (event) => this.logFileChange(event),
      level: 'standard'
    });

    // 错误触发器
    this.triggers.set('error', {
      condition: (event) => event.severity >= 'warning',
      action: (event) => this.logError(event),
      level: 'critical'
    });

    // 性能触发器
    this.triggers.set('performance', {
      condition: (event) => event.duration > 1000,
      action: (event) => this.logPerformance(event),
      level: 'important'
    });

    // 决策触发器
    this.triggers.set('decision', {
      condition: (event) => event.requiresDecision,
      action: (event) => this.logDecision(event),
      level: 'important'
    });
  }

  async processTrigger(event) {
    for (const [name, trigger] of this.triggers) {
      if (trigger.condition(event)) {
        // 检查记录级别
        if (this.shouldLog(trigger.level)) {
          await trigger.action(event);
        }
      }
    }
  }

  shouldLog(level) {
    const levelHierarchy = ['critical', 'important', 'standard', 'verbose'];
    const configLevel = this.config.level || 'standard';
    return levelHierarchy.indexOf(level) <= levelHierarchy.indexOf(configLevel);
  }
}
```

## 批量记录处理

```javascript
class BatchRecorder {
  constructor(batchSize = 10, flushInterval = 5000) {
    this.batch = [];
    this.batchSize = batchSize;
    this.flushInterval = flushInterval;
    this.startAutoFlush();
  }

  add(record) {
    this.batch.push({
      ...record,
      timestamp: new Date().toISOString()
    });

    if (this.batch.length >= this.batchSize) {
      this.flush();
    }
  }

  async flush() {
    if (this.batch.length === 0) return;

    const records = [...this.batch];
    this.batch = [];

    // 批量写入
    await this.writeBatch(records);
  }

  async writeBatch(records) {
    // 按类型分组
    const grouped = this.groupByType(records);

    // 写入不同文件
    for (const [type, items] of Object.entries(grouped)) {
      const filename = this.getFilename(type);
      await this.appendToFile(filename, items);
    }
  }

  groupByType(records) {
    return records.reduce((acc, record) => {
      const type = record.type || 'general';
      if (!acc[type]) acc[type] = [];
      acc[type].push(record);
      return acc;
    }, {});
  }

  startAutoFlush() {
    setInterval(() => this.flush(), this.flushInterval);
  }
}
```

## 记录过滤规则

```javascript
class RecordFilter {
  constructor(rules) {
    this.rules = rules;
  }

  // 应用过滤规则
  apply(record) {
    // 检查是否应该记录
    if (!this.shouldRecord(record)) {
      return null;
    }

    // 清理敏感信息
    record = this.sanitize(record);

    // 添加上下文
    record = this.enrichContext(record);

    return record;
  }

  shouldRecord(record) {
    // 检查排除规则
    if (this.rules.exclude) {
      for (const pattern of this.rules.exclude) {
        if (this.matchPattern(record, pattern)) {
          return false;
        }
      }
    }

    // 检查包含规则
    if (this.rules.include) {
      for (const pattern of this.rules.include) {
        if (this.matchPattern(record, pattern)) {
          return true;
        }
      }
      return false;
    }

    return true;
  }

  sanitize(record) {
    const sensitive = ['password', 'token', 'secret', 'key', 'api_key'];

    const clean = (obj) => {
      if (typeof obj !== 'object' || obj === null) return obj;

      const cleaned = Array.isArray(obj) ? [] : {};

      for (const [key, value] of Object.entries(obj)) {
        if (sensitive.some(s => key.toLowerCase().includes(s))) {
          cleaned[key] = '[REDACTED]';
        } else if (typeof value === 'object') {
          cleaned[key] = clean(value);
        } else {
          cleaned[key] = value;
        }
      }

      return cleaned;
    };

    return clean(record);
  }

  enrichContext(record) {
    return {
      ...record,
      context: {
        ...record.context,
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development',
        user: process.env.USER || 'unknown',
        cwd: process.cwd()
      }
    };
  }

  matchPattern(record, pattern) {
    // 简单的模式匹配实现
    if (typeof pattern === 'string') {
      return JSON.stringify(record).includes(pattern);
    }
    if (pattern instanceof RegExp) {
      return pattern.test(JSON.stringify(record));
    }
    return false;
  }
}
```

## 记录聚合规则

```javascript
class RecordAggregator {
  constructor() {
    this.aggregates = new Map();
  }

  // 聚合相似记录
  aggregate(records) {
    const aggregated = [];

    for (const record of records) {
      const key = this.generateKey(record);

      if (this.aggregates.has(key)) {
        // 更新现有聚合
        const agg = this.aggregates.get(key);
        agg.count++;
        agg.lastSeen = record.timestamp;
        agg.instances.push(record);
      } else {
        // 创建新聚合
        this.aggregates.set(key, {
          type: record.type,
          message: record.message,
          count: 1,
          firstSeen: record.timestamp,
          lastSeen: record.timestamp,
          instances: [record]
        });
      }
    }

    // 转换为数组
    for (const [key, agg] of this.aggregates) {
      if (agg.count >= this.getThreshold(agg.type)) {
        aggregated.push(this.formatAggregate(agg));
      }
    }

    return aggregated;
  }

  generateKey(record) {
    // 生成聚合键
    return `${record.type}:${record.message}:${record.severity || 'info'}`;
  }

  getThreshold(type) {
    const thresholds = {
      error: 1,      // 错误立即记录
      warning: 3,    // 警告3次后记录
      info: 10,      // 信息10次后记录
      debug: 50      // 调试50次后记录
    };
    return thresholds[type] || 5;
  }

  formatAggregate(agg) {
    return {
      summary: `${agg.type}: ${agg.message} (发生 ${agg.count} 次)`,
      details: {
        count: agg.count,
        firstSeen: agg.firstSeen,
        lastSeen: agg.lastSeen,
        frequency: this.calculateFrequency(agg),
        samples: agg.instances.slice(0, 3) // 保留前3个样本
      }
    };
  }

  calculateFrequency(agg) {
    const duration = new Date(agg.lastSeen) - new Date(agg.firstSeen);
    if (duration === 0) return 'instant';

    const hours = duration / (1000 * 60 * 60);
    return `${(agg.count / hours).toFixed(2)} 次/小时`;
  }
}
```

## 使用示例

```javascript
// 初始化记录系统
const recorder = new BatchRecorder();
const filter = new RecordFilter({
  exclude: ['*.tmp', '*.cache'],
  sanitize: true
});
const aggregator = new RecordAggregator();

// 记录任务
async function recordTask(task) {
  // 应用过滤
  const filtered = filter.apply(task);
  if (!filtered) return;

  // 添加到批处理
  recorder.add(filtered);

  // 定期聚合
  if (Date.now() % 60000 < 1000) {
    const aggregated = aggregator.aggregate(recorder.batch);
    console.log('聚合报告:', aggregated);
  }
}
```

---

**子模块名称**：记录规则与行为
**父模块**：dev-logs-core
**功能**：定义记录触发规则、过滤、聚合和批处理
**适用场景**：需要自动化记录的项目