# 子模块：质量指标追踪系统

> 前置要求：`/load dev-logs-core`

## 指标配置

```yaml
# .ai-dev-logs/metrics-config.yaml
version: 2.0

metrics:
  # 代码质量指标
  code_quality:
    coverage:
      target: 80
      warning: 70
      critical: 60

    complexity:
      target: 10
      warning: 15
      critical: 20

    duplication:
      target: 3
      warning: 5
      critical: 10

    code_smells:
      target: 0
      warning: 5
      critical: 10

    technical_debt:
      target: 0
      warning: 8h
      critical: 40h

  # 性能指标
  performance:
    response_time:
      p50: 100
      p95: 200
      p99: 500

    throughput:
      target: 1000
      unit: "req/s"

    memory_usage:
      target: 100
      warning: 200
      critical: 500
      unit: "MB"

    cpu_usage:
      target: 30
      warning: 60
      critical: 80
      unit: "%"

    error_rate:
      target: 0.1
      warning: 1
      critical: 5
      unit: "%"

  # 生产力指标
  productivity:
    tasks_per_day:
      target: 5
      warning: 3
      minimum: 1

    code_velocity:
      target: 500
      unit: "lines/day"

    bug_fix_time:
      target: 4
      warning: 8
      critical: 24
      unit: "hours"

    review_turnaround:
      target: 2
      warning: 4
      critical: 8
      unit: "hours"

# 告警规则
alerts:
  channels:
    - type: console
      level: warning

    - type: file
      path: ".ai-dev-logs/alerts.log"
      level: all

    - type: dashboard
      level: critical

  rules:
    - metric: code_quality.coverage
      condition: "< 70"
      message: "代码覆盖率低于70%"
      severity: warning

    - metric: performance.error_rate
      condition: "> 1"
      message: "错误率超过1%"
      severity: critical

# 报告生成
reporting:
  schedule:
    daily: "23:59"
    weekly: "sunday 23:59"
    monthly: "last-day 23:59"

  formats:
    - markdown
    - html
    - json

  recipients:
    - file: ".ai-dev-logs/reports/"
    - dashboard: true
```

## 指标收集器

```javascript
// metrics-collector.js
class MetricsCollector {
  constructor(config) {
    this.config = config;
    this.metrics = {};
  }

  async collectAll() {
    console.log('📊 开始收集指标...');

    this.metrics = {
      timestamp: new Date().toISOString(),
      code_quality: await this.collectCodeQuality(),
      performance: await this.collectPerformance(),
      productivity: await this.collectProductivity()
    };

    // 检查阈值并生成告警
    await this.checkThresholds();

    // 保存指标
    await this.saveMetrics();

    // 生成报告
    await this.generateReport();

    console.log('✅ 指标收集完成');
    return this.metrics;
  }

  async collectCodeQuality() {
    const coverage = await this.runCoverage();
    const complexity = await this.analyzeComplexity();
    const duplication = await this.checkDuplication();

    return {
      coverage: coverage.percentage,
      complexity: complexity.average,
      duplication: duplication.percentage,
      code_smells: await this.countCodeSmells(),
      technical_debt: await this.calculateTechnicalDebt()
    };
  }

  async collectPerformance() {
    const loadTest = await this.runLoadTest();

    return {
      response_time: {
        p50: loadTest.percentiles[50],
        p95: loadTest.percentiles[95],
        p99: loadTest.percentiles[99]
      },
      throughput: loadTest.rps,
      memory_usage: await this.getMemoryUsage(),
      cpu_usage: await this.getCPUUsage(),
      error_rate: loadTest.errorRate
    };
  }

  async collectProductivity() {
    const gitStats = await this.getGitStats();
    const taskStats = await this.getTaskStats();

    return {
      tasks_per_day: taskStats.completed / taskStats.days,
      code_velocity: gitStats.linesPerDay,
      bug_fix_time: await this.getAverageBugFixTime(),
      review_turnaround: await this.getReviewTurnaround(),
      commit_frequency: gitStats.commitsPerDay
    };
  }

  async checkThresholds() {
    const alerts = [];

    // 检查每个指标
    for (const [category, metrics] of Object.entries(this.metrics)) {
      if (category === 'timestamp') continue;

      for (const [metric, value] of Object.entries(metrics)) {
        const threshold = this.config.metrics[category]?.[metric];
        if (!threshold) continue;

        if (typeof value === 'number') {
          if (threshold.critical && value > threshold.critical) {
            alerts.push({
              level: 'critical',
              metric: `${category}.${metric}`,
              value,
              threshold: threshold.critical,
              message: `${metric} 超过临界值`
            });
          } else if (threshold.warning && value > threshold.warning) {
            alerts.push({
              level: 'warning',
              metric: `${category}.${metric}`,
              value,
              threshold: threshold.warning,
              message: `${metric} 超过警告值`
            });
          }
        }
      }
    }

    // 发送告警
    if (alerts.length > 0) {
      await this.sendAlerts(alerts);
    }

    return alerts;
  }

  async generateReport() {
    const report = {
      date: new Date().toISOString().split('T')[0],
      summary: this.generateSummary(),
      metrics: this.metrics,
      trends: await this.analyzeTrends(),
      recommendations: this.generateRecommendations()
    };

    // 生成不同格式的报告
    await this.saveReport(report, 'markdown');
    await this.saveReport(report, 'html');
    await this.saveReport(report, 'json');

    return report;
  }

  generateSummary() {
    const quality = this.metrics.code_quality;
    const performance = this.metrics.performance;
    const productivity = this.metrics.productivity;

    return {
      health_score: this.calculateHealthScore(),
      highlights: [
        `代码覆盖率: ${quality.coverage}%`,
        `平均响应时间: ${performance.response_time.p50}ms`,
        `每日任务完成: ${productivity.tasks_per_day}`
      ],
      concerns: this.identifyConcerns()
    };
  }

  calculateHealthScore() {
    // 综合健康评分算法
    const weights = {
      code_quality: 0.3,
      performance: 0.4,
      productivity: 0.3
    };

    let score = 0;

    // 代码质量评分
    const quality = this.metrics.code_quality;
    const qualityScore = (quality.coverage / 100) * 0.5 +
                        (1 - quality.complexity / 20) * 0.3 +
                        (1 - quality.code_smells / 10) * 0.2;
    score += qualityScore * weights.code_quality;

    // 性能评分
    const perf = this.metrics.performance;
    const perfScore = (1 - perf.response_time.p50 / 500) * 0.4 +
                     (1 - perf.error_rate / 5) * 0.6;
    score += perfScore * weights.performance;

    // 生产力评分
    const prod = this.metrics.productivity;
    const prodScore = Math.min(prod.tasks_per_day / 5, 1);
    score += prodScore * weights.productivity;

    return Math.round(score * 100);
  }

  async analyzeTrends() {
    // 读取历史数据
    const history = await this.loadHistoricalData();

    return {
      coverage_trend: this.calculateTrend(history, 'code_quality.coverage'),
      performance_trend: this.calculateTrend(history, 'performance.response_time.p50'),
      productivity_trend: this.calculateTrend(history, 'productivity.tasks_per_day'),
      predictions: this.predictFuture(history)
    };
  }

  calculateTrend(history, metricPath) {
    const values = history.map(h => this.getNestedValue(h, metricPath));
    const recent = values.slice(-7);  // 最近7天
    const previous = values.slice(-14, -7);  // 前7天

    const recentAvg = this.average(recent);
    const previousAvg = this.average(previous);

    const change = ((recentAvg - previousAvg) / previousAvg) * 100;

    return {
      direction: change > 0 ? 'up' : 'down',
      percentage: Math.abs(change).toFixed(2),
      values: recent
    };
  }

  generateRecommendations() {
    const recommendations = [];
    const metrics = this.metrics;

    // 代码质量建议
    if (metrics.code_quality.coverage < 70) {
      recommendations.push({
        category: 'code_quality',
        priority: 'high',
        action: '增加测试覆盖率',
        target: '达到80%以上的代码覆盖率'
      });
    }

    if (metrics.code_quality.complexity > 15) {
      recommendations.push({
        category: 'code_quality',
        priority: 'medium',
        action: '重构复杂代码',
        target: '降低圈复杂度至10以下'
      });
    }

    // 性能建议
    if (metrics.performance.response_time.p95 > 500) {
      recommendations.push({
        category: 'performance',
        priority: 'high',
        action: '优化慢查询',
        target: 'P95响应时间降至200ms以下'
      });
    }

    // 生产力建议
    if (metrics.productivity.bug_fix_time > 8) {
      recommendations.push({
        category: 'productivity',
        priority: 'medium',
        action: '改进调试流程',
        target: '平均修复时间降至4小时内'
      });
    }

    return recommendations;
  }

  // 辅助方法
  async runCoverage() {
    // 模拟运行覆盖率测试
    return {
      percentage: 75,
      lines: { covered: 750, total: 1000 },
      functions: { covered: 80, total: 100 }
    };
  }

  async analyzeComplexity() {
    // 模拟复杂度分析
    return {
      average: 8,
      max: 15,
      files: []
    };
  }

  async checkDuplication() {
    // 模拟重复代码检查
    return {
      percentage: 3.5,
      blocks: 5
    };
  }

  getNestedValue(obj, path) {
    return path.split('.').reduce((acc, key) => acc?.[key], obj);
  }

  average(arr) {
    return arr.reduce((a, b) => a + b, 0) / arr.length;
  }
}
```

## 实时指标监控

```javascript
class MetricsMonitor {
  constructor(interval = 60000) {
    this.interval = interval;
    this.collectors = new Map();
    this.thresholds = new Map();
  }

  register(name, collector, threshold) {
    this.collectors.set(name, collector);
    this.thresholds.set(name, threshold);
  }

  start() {
    console.log('🚀 启动实时监控...');

    setInterval(async () => {
      for (const [name, collector] of this.collectors) {
        try {
          const value = await collector();
          await this.check(name, value);
        } catch (error) {
          console.error(`收集 ${name} 指标失败:`, error);
        }
      }
    }, this.interval);
  }

  async check(name, value) {
    const threshold = this.thresholds.get(name);
    if (!threshold) return;

    if (value > threshold.critical) {
      await this.alert('critical', name, value, threshold.critical);
    } else if (value > threshold.warning) {
      await this.alert('warning', name, value, threshold.warning);
    }
  }

  async alert(level, metric, value, threshold) {
    const message = `[${level.toUpperCase()}] ${metric}: ${value} (阈值: ${threshold})`;
    console.log(`🚨 ${message}`);

    // 记录到文件
    await this.logAlert({
      timestamp: new Date().toISOString(),
      level,
      metric,
      value,
      threshold,
      message
    });
  }

  async logAlert(alert) {
    const fs = require('fs').promises;
    const file = '.ai-dev-logs/alerts.log';
    await fs.appendFile(file, JSON.stringify(alert) + '\n');
  }
}

// 使用示例
const monitor = new MetricsMonitor();

// 注册CPU监控
monitor.register('cpu',
  async () => {
    // 获取CPU使用率
    const os = require('os');
    const cpus = os.cpus();
    let totalIdle = 0;
    let totalTick = 0;

    cpus.forEach(cpu => {
      for (const type in cpu.times) {
        totalTick += cpu.times[type];
      }
      totalIdle += cpu.times.idle;
    });

    return 100 - ~~(100 * totalIdle / totalTick);
  },
  { warning: 60, critical: 80 }
);

// 注册内存监控
monitor.register('memory',
  async () => {
    const os = require('os');
    const used = (os.totalmem() - os.freemem()) / 1024 / 1024;
    return Math.round(used);
  },
  { warning: 1000, critical: 1500 }
);

// 启动监控
monitor.start();
```

## 指标可视化

```javascript
class MetricsVisualizer {
  generateChart(data, type = 'line') {
    if (type === 'line') {
      return this.generateLineChart(data);
    } else if (type === 'bar') {
      return this.generateBarChart(data);
    } else if (type === 'pie') {
      return this.generatePieChart(data);
    }
  }

  generateLineChart(data) {
    const width = 60;
    const height = 10;
    const max = Math.max(...data.values);
    const min = Math.min(...data.values);
    const range = max - min;

    const chart = [];
    for (let y = height; y >= 0; y--) {
      let line = '';
      const threshold = min + (range * y / height);

      for (let x = 0; x < data.values.length; x++) {
        const value = data.values[x];
        if (value >= threshold) {
          line += '█';
        } else {
          line += ' ';
        }
      }

      chart.push(line);
    }

    return {
      chart: chart.join('\n'),
      legend: `最高: ${max} | 最低: ${min} | 平均: ${this.average(data.values).toFixed(2)}`
    };
  }

  generateBarChart(data) {
    const bars = [];
    const maxValue = Math.max(...Object.values(data));
    const scale = 50 / maxValue;

    for (const [label, value] of Object.entries(data)) {
      const barLength = Math.round(value * scale);
      const bar = '█'.repeat(barLength);
      bars.push(`${label.padEnd(15)} ${bar} ${value}`);
    }

    return bars.join('\n');
  }

  generatePieChart(data) {
    const total = Object.values(data).reduce((a, b) => a + b, 0);
    const segments = [];

    for (const [label, value] of Object.entries(data)) {
      const percentage = (value / total * 100).toFixed(1);
      segments.push(`${label}: ${percentage}%`);
    }

    return segments.join(' | ');
  }

  generateSparkline(values) {
    const sparks = ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'];
    const max = Math.max(...values);
    const min = Math.min(...values);
    const range = max - min;

    return values.map(v => {
      const index = Math.round((v - min) / range * (sparks.length - 1));
      return sparks[index];
    }).join('');
  }

  average(arr) {
    return arr.reduce((a, b) => a + b, 0) / arr.length;
  }
}

// 使用示例
const visualizer = new MetricsVisualizer();

// 生成趋势图
const trendData = {
  values: [65, 70, 75, 72, 78, 82, 80, 85, 83, 87]
};
const trendChart = visualizer.generateChart(trendData, 'line');
console.log('代码覆盖率趋势:');
console.log(trendChart.chart);
console.log(trendChart.legend);

// 生成柱状图
const qualityData = {
  '覆盖率': 75,
  '复杂度': 8,
  '重复率': 3
};
const barChart = visualizer.generateBarChart(qualityData);
console.log('\n质量指标:');
console.log(barChart);

// 生成迷你图
const sparkline = visualizer.generateSparkline([1, 5, 3, 7, 8, 3, 9, 2, 5]);
console.log('\n性能趋势: ' + sparkline);
```

## 指标导出

```javascript
class MetricsExporter {
  async export(metrics, format = 'json', destination = './reports') {
    switch (format) {
      case 'json':
        return await this.exportJSON(metrics, destination);
      case 'csv':
        return await this.exportCSV(metrics, destination);
      case 'html':
        return await this.exportHTML(metrics, destination);
      case 'markdown':
        return await this.exportMarkdown(metrics, destination);
      default:
        throw new Error(`不支持的格式: ${format}`);
    }
  }

  async exportJSON(metrics, destination) {
    const fs = require('fs').promises;
    const filename = `${destination}/metrics-${Date.now()}.json`;
    await fs.writeFile(filename, JSON.stringify(metrics, null, 2));
    return filename;
  }

  async exportCSV(metrics, destination) {
    const rows = [];
    rows.push(['指标', '值', '时间']);

    const flatten = (obj, prefix = '') => {
      for (const [key, value] of Object.entries(obj)) {
        if (typeof value === 'object' && !Array.isArray(value)) {
          flatten(value, `${prefix}${key}.`);
        } else {
          rows.push([`${prefix}${key}`, value, metrics.timestamp]);
        }
      }
    };

    flatten(metrics);

    const csv = rows.map(row => row.join(',')).join('\n');
    const filename = `${destination}/metrics-${Date.now()}.csv`;

    const fs = require('fs').promises;
    await fs.writeFile(filename, csv);
    return filename;
  }

  async exportMarkdown(metrics, destination) {
    const md = [];
    md.push(`# 指标报告 - ${metrics.timestamp}`);
    md.push('');

    // 代码质量
    md.push('## 代码质量');
    md.push('| 指标 | 值 | 状态 |');
    md.push('|------|-----|------|');
    for (const [key, value] of Object.entries(metrics.code_quality || {})) {
      const status = this.getStatus(value, key);
      md.push(`| ${key} | ${value} | ${status} |`);
    }
    md.push('');

    // 性能
    md.push('## 性能');
    md.push('| 指标 | 值 | 状态 |');
    md.push('|------|-----|------|');
    // ...类似处理

    const filename = `${destination}/metrics-${Date.now()}.md`;
    const fs = require('fs').promises;
    await fs.writeFile(filename, md.join('\n'));
    return filename;
  }

  getStatus(value, metric) {
    // 简单的状态判断逻辑
    if (metric.includes('coverage')) {
      return value >= 80 ? '✅' : value >= 60 ? '⚠️' : '❌';
    }
    // ...其他指标判断
    return '📊';
  }
}
```

---

**子模块名称**：质量指标追踪系统
**父模块**：dev-logs-core
**功能**：收集、监控、分析和导出各类指标
**适用场景**：需要质量监控和性能追踪的项目