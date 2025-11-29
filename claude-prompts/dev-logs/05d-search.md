# 子模块：查询和分析工具

> 前置要求：`/load dev-logs-core`

## 快速查询命令

```bash
# 查看今日任务
ai-logs today

# 查看本周总结
ai-logs summary --period=week

# 搜索特定功能
ai-logs search "authentication" --type=feature

# 生成月度报告
ai-logs report --month=2024-11 --format=html

# 分析性能趋势
ai-logs analyze performance --days=30

# 导出知识库
ai-logs export --format=markdown --output=knowledge.md
```

## 增强版搜索系统

```javascript
// search.js - 增强版搜索系统
class AIDevLogsSearch {
  constructor(logsDir = '.ai-dev-logs') {
    this.logsDir = logsDir;
    this.index = this.buildIndex();
  }

  // 构建索引
  buildIndex() {
    const index = {
      tasks: [],
      features: [],
      commits: [],
      tags: new Map(),
      dates: new Map()
    };

    // 扫描所有记录文件
    this.scanDirectory(this.logsDir, index);

    return index;
  }

  // 多维度搜索
  search(query) {
    const results = {
      exact: [],
      fuzzy: [],
      related: []
    };

    // 关键词搜索
    if (query.keyword) {
      results.exact = this.searchByKeyword(query.keyword, true);
      results.fuzzy = this.searchByKeyword(query.keyword, false);
    }

    // 标签搜索
    if (query.tags) {
      const tagResults = this.searchByTags(query.tags);
      results.exact.push(...tagResults);
    }

    // 日期范围搜索
    if (query.dateRange) {
      const dateResults = this.searchByDateRange(
        query.dateRange.start,
        query.dateRange.end
      );
      results.exact.push(...dateResults);
    }

    // 状态过滤
    if (query.status) {
      results.exact = this.filterByStatus(results.exact, query.status);
    }

    // 相关性排序
    return this.rankResults(results);
  }

  // 全文搜索
  searchByKeyword(keyword, exact = true) {
    const results = [];
    const pattern = exact
      ? new RegExp(`\\b${keyword}\\b`, 'gi')
      : new RegExp(keyword, 'gi');

    for (const item of [...this.index.tasks, ...this.index.features]) {
      if (pattern.test(item.content)) {
        results.push({
          ...item,
          score: this.calculateRelevance(item.content, keyword)
        });
      }
    }

    return results.sort((a, b) => b.score - a.score);
  }

  // 标签搜索
  searchByTags(tags) {
    const results = [];
    const tagSet = new Set(tags);

    for (const [tag, items] of this.index.tags) {
      if (tagSet.has(tag)) {
        results.push(...items);
      }
    }

    return this.uniqueResults(results);
  }

  // 日期范围搜索
  searchByDateRange(startDate, endDate) {
    const results = [];
    const start = new Date(startDate);
    const end = new Date(endDate);

    for (const [date, items] of this.index.dates) {
      const d = new Date(date);
      if (d >= start && d <= end) {
        results.push(...items);
      }
    }

    return results;
  }

  // 计算相关性分数
  calculateRelevance(content, keyword) {
    const lowerContent = content.toLowerCase();
    const lowerKeyword = keyword.toLowerCase();

    let score = 0;

    // 完全匹配
    if (lowerContent.includes(lowerKeyword)) {
      score += 10;
    }

    // 标题匹配
    const titleMatch = content.match(/^#\s+(.+)/m);
    if (titleMatch && titleMatch[1].toLowerCase().includes(lowerKeyword)) {
      score += 20;
    }

    // 出现频率
    const matches = (lowerContent.match(new RegExp(lowerKeyword, 'g')) || []).length;
    score += matches * 2;

    // 位置权重（越靠前权重越高）
    const position = lowerContent.indexOf(lowerKeyword);
    if (position !== -1) {
      score += Math.max(0, 10 - position / 100);
    }

    return score;
  }

  // 生成搜索报告
  generateSearchReport(results) {
    return {
      summary: {
        total: results.length,
        by_type: this.groupByType(results),
        by_status: this.groupByStatus(results),
        by_date: this.groupByDate(results)
      },
      results: results.map(r => ({
        id: r.id,
        title: r.title,
        type: r.type,
        path: r.path,
        excerpt: this.extractExcerpt(r.content),
        tags: r.tags,
        date: r.date,
        score: r.score
      })),
      suggestions: this.generateSuggestions(results)
    };
  }

  // 提取摘要
  extractExcerpt(content, maxLength = 200) {
    // 移除markdown格式
    let text = content
      .replace(/^#+\s+/gm, '')
      .replace(/\*\*/g, '')
      .replace(/\*/g, '')
      .replace(/`/g, '')
      .trim();

    if (text.length > maxLength) {
      text = text.substring(0, maxLength) + '...';
    }

    return text;
  }

  // 结果去重
  uniqueResults(results) {
    const seen = new Set();
    return results.filter(r => {
      if (seen.has(r.id)) {
        return false;
      }
      seen.add(r.id);
      return true;
    });
  }

  // 结果排序
  rankResults(results) {
    const ranked = {
      exact: this.sortByRelevance(results.exact),
      fuzzy: this.sortByRelevance(results.fuzzy),
      related: this.sortByRelevance(results.related)
    };

    return ranked;
  }

  sortByRelevance(results) {
    return results.sort((a, b) => {
      // 优先级：分数 > 日期 > 类型
      if (a.score !== b.score) return b.score - a.score;
      if (a.date !== b.date) return new Date(b.date) - new Date(a.date);
      return 0;
    });
  }

  // 生成搜索建议
  generateSuggestions(results) {
    const suggestions = [];

    // 相关标签
    const tags = new Set();
    results.forEach(r => {
      if (r.tags) {
        r.tags.forEach(t => tags.add(t));
      }
    });

    if (tags.size > 0) {
      suggestions.push({
        type: 'tags',
        message: '相关标签',
        items: Array.from(tags).slice(0, 5)
      });
    }

    // 时间范围
    if (results.length > 0) {
      const dates = results.map(r => new Date(r.date));
      const minDate = new Date(Math.min(...dates));
      const maxDate = new Date(Math.max(...dates));

      suggestions.push({
        type: 'date_range',
        message: '时间范围',
        items: [`${minDate.toISOString().split('T')[0]} 至 ${maxDate.toISOString().split('T')[0]}`]
      });
    }

    return suggestions;
  }

  // 分组统计
  groupByType(results) {
    const groups = {};
    results.forEach(r => {
      groups[r.type] = (groups[r.type] || 0) + 1;
    });
    return groups;
  }

  groupByStatus(results) {
    const groups = {};
    results.forEach(r => {
      groups[r.status] = (groups[r.status] || 0) + 1;
    });
    return groups;
  }

  groupByDate(results) {
    const groups = {};
    results.forEach(r => {
      const date = r.date.split('T')[0];
      groups[date] = (groups[date] || 0) + 1;
    });
    return groups;
  }

  // 扫描目录构建索引
  scanDirectory(dir, index) {
    const fs = require('fs');
    const path = require('path');

    const items = fs.readdirSync(dir);

    items.forEach(item => {
      const fullPath = path.join(dir, item);
      const stat = fs.statSync(fullPath);

      if (stat.isDirectory()) {
        this.scanDirectory(fullPath, index);
      } else if (item.endsWith('.md')) {
        const content = fs.readFileSync(fullPath, 'utf8');
        const parsed = this.parseLogFile(content, fullPath);

        if (parsed.type === 'task') {
          index.tasks.push(parsed);
        } else if (parsed.type === 'feature') {
          index.features.push(parsed);
        }

        // 索引标签
        if (parsed.tags) {
          parsed.tags.forEach(tag => {
            if (!index.tags.has(tag)) {
              index.tags.set(tag, []);
            }
            index.tags.get(tag).push(parsed);
          });
        }

        // 索引日期
        if (parsed.date) {
          const dateKey = parsed.date.split('T')[0];
          if (!index.dates.has(dateKey)) {
            index.dates.set(dateKey, []);
          }
          index.dates.get(dateKey).push(parsed);
        }
      }
    });
  }

  // 解析日志文件
  parseLogFile(content, path) {
    const parsed = {
      id: this.generateId(path),
      path: path,
      content: content,
      type: this.detectType(content),
      title: this.extractTitle(content),
      date: this.extractDate(content),
      status: this.extractStatus(content),
      tags: this.extractTags(content)
    };

    return parsed;
  }

  generateId(path) {
    return path.replace(/[\/\\]/g, '-').replace('.md', '');
  }

  detectType(content) {
    if (content.includes('任务记录')) return 'task';
    if (content.includes('功能：')) return 'feature';
    if (content.includes('Bug修复')) return 'bug';
    if (content.includes('每日总结')) return 'daily';
    return 'general';
  }

  extractTitle(content) {
    const match = content.match(/^#\s+(.+)/m);
    return match ? match[1] : 'Untitled';
  }

  extractDate(content) {
    const match = content.match(/创建时间[：:]\s*(.+)/);
    if (match) return match[1];

    const dateMatch = content.match(/\d{4}-\d{2}-\d{2}/);
    return dateMatch ? dateMatch[0] : new Date().toISOString();
  }

  extractStatus(content) {
    if (content.includes('✅') || content.includes('完成')) return 'completed';
    if (content.includes('🚧') || content.includes('进行中')) return 'in_progress';
    if (content.includes('❌') || content.includes('失败')) return 'failed';
    if (content.includes('📋') || content.includes('计划中')) return 'planned';
    return 'unknown';
  }

  extractTags(content) {
    const tags = [];
    const matches = content.matchAll(/#(\w+)/g);
    for (const match of matches) {
      tags.push(match[1]);
    }
    return tags;
  }
}
```

## 智能分析工具

```javascript
class LogAnalyzer {
  constructor() {
    this.patterns = this.loadPatterns();
  }

  loadPatterns() {
    return {
      performance_issues: [
        /响应时间.*超过.*\d+ms/,
        /内存使用.*达到.*\d+%/,
        /CPU.*占用.*过高/
      ],
      security_concerns: [
        /SQL.*注入/i,
        /XSS.*攻击/i,
        /未授权.*访问/
      ],
      code_quality: [
        /代码.*重复/,
        /圈复杂度.*过高/,
        /测试.*覆盖率.*不足/
      ]
    };
  }

  analyze(logs) {
    const insights = {
      issues: [],
      trends: [],
      recommendations: [],
      statistics: {}
    };

    // 问题识别
    insights.issues = this.findIssues(logs);

    // 趋势分析
    insights.trends = this.analyzeTrends(logs);

    // 生成建议
    insights.recommendations = this.generateRecommendations(insights);

    // 统计信息
    insights.statistics = this.generateStatistics(logs);

    return insights;
  }

  findIssues(logs) {
    const issues = [];

    logs.forEach(log => {
      for (const [category, patterns] of Object.entries(this.patterns)) {
        patterns.forEach(pattern => {
          if (pattern.test(log.content)) {
            issues.push({
              category,
              severity: this.calculateSeverity(category),
              location: log.path,
              match: log.content.match(pattern)[0],
              date: log.date
            });
          }
        });
      }
    });

    return issues.sort((a, b) =>
      this.getSeverityWeight(b.severity) - this.getSeverityWeight(a.severity)
    );
  }

  analyzeTrends(logs) {
    const trends = [];

    // 任务完成趋势
    const tasksByDate = this.groupByDate(logs.filter(l => l.type === 'task'));
    const completionRates = this.calculateCompletionRates(tasksByDate);

    if (completionRates.trend !== 'stable') {
      trends.push({
        type: 'task_completion',
        direction: completionRates.trend,
        change: completionRates.change,
        message: `任务完成率${completionRates.trend === 'up' ? '上升' : '下降'} ${Math.abs(completionRates.change)}%`
      });
    }

    // 错误频率趋势
    const errors = logs.filter(l => l.status === 'failed' || l.content.includes('错误'));
    if (errors.length > 0) {
      const errorTrend = this.analyzeFrequencyTrend(errors);
      trends.push({
        type: 'error_frequency',
        ...errorTrend
      });
    }

    // 代码变更趋势
    const codeChanges = this.extractCodeChanges(logs);
    if (codeChanges.length > 0) {
      const changeTrend = this.analyzeCodeChangeTrend(codeChanges);
      trends.push({
        type: 'code_changes',
        ...changeTrend
      });
    }

    return trends;
  }

  generateRecommendations(insights) {
    const recommendations = [];

    // 基于问题生成建议
    const issueCounts = {};
    insights.issues.forEach(issue => {
      issueCounts[issue.category] = (issueCounts[issue.category] || 0) + 1;
    });

    for (const [category, count] of Object.entries(issueCounts)) {
      if (count >= 3) {
        recommendations.push({
          priority: 'high',
          category,
          action: this.getRecommendationForCategory(category),
          reason: `发现 ${count} 个 ${category} 相关问题`
        });
      }
    }

    // 基于趋势生成建议
    insights.trends.forEach(trend => {
      if (trend.direction === 'down' && trend.type === 'task_completion') {
        recommendations.push({
          priority: 'medium',
          category: 'productivity',
          action: '优化工作流程，考虑任务分解和优先级管理',
          reason: '任务完成率呈下降趋势'
        });
      }
    });

    return recommendations;
  }

  getRecommendationForCategory(category) {
    const recommendations = {
      performance_issues: '进行性能分析和优化，考虑引入缓存和异步处理',
      security_concerns: '进行安全审计，更新依赖并实施安全最佳实践',
      code_quality: '增加代码审查频率，引入自动化质量检查工具'
    };

    return recommendations[category] || '需要进一步分析';
  }

  generateStatistics(logs) {
    return {
      total_logs: logs.length,
      by_type: this.countByProperty(logs, 'type'),
      by_status: this.countByProperty(logs, 'status'),
      average_per_day: this.calculateAveragePerDay(logs),
      most_active_day: this.findMostActiveDay(logs),
      completion_rate: this.calculateOverallCompletionRate(logs)
    };
  }

  // 辅助方法
  calculateSeverity(category) {
    const severityMap = {
      security_concerns: 'critical',
      performance_issues: 'high',
      code_quality: 'medium'
    };
    return severityMap[category] || 'low';
  }

  getSeverityWeight(severity) {
    const weights = {
      critical: 4,
      high: 3,
      medium: 2,
      low: 1
    };
    return weights[severity] || 0;
  }

  groupByDate(logs) {
    const grouped = {};
    logs.forEach(log => {
      const date = log.date.split('T')[0];
      if (!grouped[date]) grouped[date] = [];
      grouped[date].push(log);
    });
    return grouped;
  }

  calculateCompletionRates(tasksByDate) {
    const rates = [];

    for (const [date, tasks] of Object.entries(tasksByDate)) {
      const completed = tasks.filter(t => t.status === 'completed').length;
      const rate = (completed / tasks.length) * 100;
      rates.push({ date, rate });
    }

    // 计算趋势
    if (rates.length < 2) {
      return { trend: 'stable', change: 0 };
    }

    const recent = rates.slice(-7);
    const previous = rates.slice(-14, -7);

    const recentAvg = recent.reduce((a, b) => a + b.rate, 0) / recent.length;
    const previousAvg = previous.reduce((a, b) => a + b.rate, 0) / previous.length;

    const change = recentAvg - previousAvg;

    return {
      trend: change > 5 ? 'up' : change < -5 ? 'down' : 'stable',
      change: Math.round(change)
    };
  }

  countByProperty(items, property) {
    const counts = {};
    items.forEach(item => {
      const value = item[property];
      counts[value] = (counts[value] || 0) + 1;
    });
    return counts;
  }

  calculateAveragePerDay(logs) {
    const byDate = this.groupByDate(logs);
    const total = Object.keys(byDate).length;
    return total > 0 ? (logs.length / total).toFixed(1) : 0;
  }

  findMostActiveDay(logs) {
    const byDate = this.groupByDate(logs);
    let maxCount = 0;
    let maxDate = null;

    for (const [date, items] of Object.entries(byDate)) {
      if (items.length > maxCount) {
        maxCount = items.length;
        maxDate = date;
      }
    }

    return { date: maxDate, count: maxCount };
  }

  calculateOverallCompletionRate(logs) {
    const tasks = logs.filter(l => l.type === 'task');
    if (tasks.length === 0) return 0;

    const completed = tasks.filter(t => t.status === 'completed').length;
    return Math.round((completed / tasks.length) * 100);
  }

  extractCodeChanges(logs) {
    const changes = [];

    logs.forEach(log => {
      const match = log.content.match(/\+(\d+).*-(\d+)/);
      if (match) {
        changes.push({
          date: log.date,
          additions: parseInt(match[1]),
          deletions: parseInt(match[2])
        });
      }
    });

    return changes;
  }

  analyzeFrequencyTrend(items) {
    const byDate = this.groupByDate(items);
    const counts = Object.values(byDate).map(items => items.length);

    const avg = counts.reduce((a, b) => a + b, 0) / counts.length;
    const recent = counts.slice(-7);
    const recentAvg = recent.reduce((a, b) => a + b, 0) / recent.length;

    return {
      direction: recentAvg > avg * 1.2 ? 'up' : recentAvg < avg * 0.8 ? 'down' : 'stable',
      average: avg.toFixed(1),
      recent: recentAvg.toFixed(1),
      message: `平均频率: ${avg.toFixed(1)}, 最近: ${recentAvg.toFixed(1)}`
    };
  }

  analyzeCodeChangeTrend(changes) {
    const recent = changes.slice(-10);
    const totalAdditions = recent.reduce((a, c) => a + c.additions, 0);
    const totalDeletions = recent.reduce((a, c) => a + c.deletions, 0);

    return {
      direction: totalAdditions > totalDeletions ? 'growth' : 'reduction',
      additions: totalAdditions,
      deletions: totalDeletions,
      net: totalAdditions - totalDeletions,
      message: `代码净增长: ${totalAdditions - totalDeletions} 行`
    };
  }
}
```

## 可视化仪表板

```html
<!DOCTYPE html>
<html>
<head>
  <title>AI 开发记录仪表板</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      margin: 0;
      padding: 20px;
      background: #f5f5f5;
    }
    .dashboard {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
      gap: 20px;
    }
    .card {
      background: white;
      border-radius: 8px;
      padding: 20px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .card h3 {
      margin-top: 0;
      color: #333;
    }
    .stat-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
      gap: 15px;
      margin-bottom: 20px;
    }
    .stat-item {
      text-align: center;
      padding: 15px;
      background: #f8f9fa;
      border-radius: 5px;
    }
    .stat-value {
      font-size: 2em;
      font-weight: bold;
      color: #007bff;
    }
    .stat-label {
      color: #666;
      margin-top: 5px;
    }
  </style>
</head>
<body>
  <h1>AI 开发记录仪表板</h1>

  <div class="stat-grid">
    <div class="stat-item">
      <div class="stat-value" id="totalTasks">0</div>
      <div class="stat-label">总任务数</div>
    </div>
    <div class="stat-item">
      <div class="stat-value" id="completionRate">0%</div>
      <div class="stat-label">完成率</div>
    </div>
    <div class="stat-item">
      <div class="stat-value" id="avgResponseTime">0ms</div>
      <div class="stat-label">平均响应时间</div>
    </div>
    <div class="stat-item">
      <div class="stat-value" id="codeCoverage">0%</div>
      <div class="stat-label">代码覆盖率</div>
    </div>
  </div>

  <div class="dashboard">
    <div class="card">
      <h3>任务完成趋势</h3>
      <canvas id="taskTrend"></canvas>
    </div>

    <div class="card">
      <h3>代码变更统计</h3>
      <canvas id="codeChanges"></canvas>
    </div>

    <div class="card">
      <h3>测试覆盖率</h3>
      <canvas id="testCoverage"></canvas>
    </div>

    <div class="card">
      <h3>性能指标</h3>
      <canvas id="performance"></canvas>
    </div>
  </div>

  <script>
    // 动态加载数据
    async function loadDashboard() {
      try {
        const response = await fetch('.ai-dev-logs/metrics/summary.json');
        const data = await response.json();
        updateStats(data);
        renderCharts(data);
      } catch (error) {
        console.error('Failed to load dashboard data:', error);
      }
    }

    function updateStats(data) {
      document.getElementById('totalTasks').textContent = data.totalTasks || 0;
      document.getElementById('completionRate').textContent = `${data.completionRate || 0}%`;
      document.getElementById('avgResponseTime').textContent = `${data.avgResponseTime || 0}ms`;
      document.getElementById('codeCoverage').textContent = `${data.codeCoverage || 0}%`;
    }

    function renderCharts(data) {
      // 任务趋势图
      new Chart(document.getElementById('taskTrend'), {
        type: 'line',
        data: {
          labels: data.dates || [],
          datasets: [{
            label: '完成任务数',
            data: data.tasksCompleted || [],
            borderColor: 'rgb(75, 192, 192)',
            backgroundColor: 'rgba(75, 192, 192, 0.2)'
          }]
        },
        options: {
          responsive: true,
          plugins: {
            legend: { position: 'bottom' }
          }
        }
      });

      // 代码变更图
      new Chart(document.getElementById('codeChanges'), {
        type: 'bar',
        data: {
          labels: data.dates || [],
          datasets: [
            {
              label: '新增行数',
              data: data.additions || [],
              backgroundColor: 'rgba(54, 162, 235, 0.5)'
            },
            {
              label: '删除行数',
              data: data.deletions || [],
              backgroundColor: 'rgba(255, 99, 132, 0.5)'
            }
          ]
        },
        options: {
          responsive: true,
          plugins: {
            legend: { position: 'bottom' }
          }
        }
      });

      // 测试覆盖率
      new Chart(document.getElementById('testCoverage'), {
        type: 'doughnut',
        data: {
          labels: ['已覆盖', '未覆盖'],
          datasets: [{
            data: [data.codeCoverage || 0, 100 - (data.codeCoverage || 0)],
            backgroundColor: [
              'rgba(75, 192, 192, 0.8)',
              'rgba(255, 99, 132, 0.8)'
            ]
          }]
        },
        options: {
          responsive: true,
          plugins: {
            legend: { position: 'bottom' }
          }
        }
      });

      // 性能指标
      new Chart(document.getElementById('performance'), {
        type: 'radar',
        data: {
          labels: ['响应时间', 'CPU使用率', '内存使用', '错误率', '吞吐量'],
          datasets: [{
            label: '当前值',
            data: data.performanceMetrics || [0, 0, 0, 0, 0],
            borderColor: 'rgb(54, 162, 235)',
            backgroundColor: 'rgba(54, 162, 235, 0.2)'
          }]
        },
        options: {
          responsive: true,
          scales: {
            r: {
              beginAtZero: true,
              max: 100
            }
          }
        }
      });
    }

    // 自动刷新
    loadDashboard();
    setInterval(loadDashboard, 60000); // 每分钟刷新
  </script>
</body>
</html>
```

## 命令行工具

```javascript
#!/usr/bin/env node

const { program } = require('commander');
const search = new AIDevLogsSearch();
const analyzer = new LogAnalyzer();

program
  .name('ai-logs')
  .description('AI 开发记录查询工具')
  .version('1.0.0');

program
  .command('search <keyword>')
  .description('搜索记录')
  .option('-t, --type <type>', '记录类型')
  .option('-s, --status <status>', '状态过滤')
  .option('--tags <tags...>', '标签过滤')
  .action((keyword, options) => {
    const results = search.search({
      keyword,
      type: options.type,
      status: options.status,
      tags: options.tags
    });

    console.log(`找到 ${results.exact.length} 条记录`);
    results.exact.slice(0, 10).forEach(r => {
      console.log(`- ${r.title} (${r.path})`);
    });
  });

program
  .command('analyze')
  .description('分析记录')
  .option('-d, --days <days>', '分析最近N天', 30)
  .action((options) => {
    const logs = search.index.tasks;
    const insights = analyzer.analyze(logs);

    console.log('分析报告：');
    console.log(`- 发现 ${insights.issues.length} 个问题`);
    console.log(`- 识别 ${insights.trends.length} 个趋势`);
    console.log(`- 生成 ${insights.recommendations.length} 条建议`);

    insights.recommendations.forEach(rec => {
      console.log(`[${rec.priority}] ${rec.action}`);
    });
  });

program
  .command('today')
  .description('查看今日任务')
  .action(() => {
    const today = new Date().toISOString().split('T')[0];
    const results = search.searchByDateRange(today, today);

    console.log(`今日任务 (${results.length}):`);
    results.forEach(r => {
      const status = r.status === 'completed' ? '✅' : '🚧';
      console.log(`${status} ${r.title}`);
    });
  });

program.parse(process.argv);
```

---

**子模块名称**：查询和分析工具
**父模块**：dev-logs-core
**功能**：搜索、分析、可视化记录数据
**适用场景**：需要深度分析和数据挖掘的项目