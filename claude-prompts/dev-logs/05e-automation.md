# 子模块：自动化与集成

> 前置要求：`/load dev-logs-core`

## 增强版 Git Hooks 配置

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "🔍 AI 开发记录 Pre-commit Hook"

# 检查是否有未记录的任务
UNRECORDED_TASKS=$(find .ai-dev-logs/features -name "*.md" -exec grep -l "状态: 🚧 进行中" {} \;)

if [ ! -z "$UNRECORDED_TASKS" ]; then
  echo "⚠️  发现未完成的任务记录："
  echo "$UNRECORDED_TASKS"
  echo "请先完成任务记录再提交"
  exit 1
fi

# 自动更新指标
echo "📊 更新代码质量指标..."
node .ai-dev-logs/scripts/metrics-collector.js

# 生成提交记录
COMMIT_MSG_FILE=$1
COMMIT_RECORD=".ai-dev-logs/commits/$(date +%Y-%m-%d-%H%M%S).md"

cat > "$COMMIT_RECORD" << EOF
# 提交记录

## 基本信息
- **时间**: $(date +"%Y-%m-%d %H:%M:%S")
- **分支**: $(git branch --show-current)
- **作者**: $(git config user.name)

## 提交信息
$(cat $COMMIT_MSG_FILE)

## 文件变更
\`\`\`
$(git diff --cached --stat)
\`\`\`

## 代码变更详情
$(git diff --cached --name-status)

## 相关任务
[待AI分析填充]

## 影响分析
[待AI分析填充]
EOF

echo "✅ 提交记录已生成"
```

### Post-commit Hook

```bash
#!/bin/bash
# .git/hooks/post-commit

echo "📝 AI 开发记录 Post-commit Hook"

COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_SHORT=${COMMIT_HASH:0:7}

# 更新索引
echo "🔄 更新索引文件..."
node .ai-dev-logs/scripts/update-index.js

# 生成每日总结（如果是当天最后一次提交）
HOUR=$(date +%H)
if [ $HOUR -ge 18 ]; then
  echo "📊 生成每日总结..."
  node .ai-dev-logs/scripts/daily-summary.js
fi

# 更新仪表板
echo "📈 更新仪表板..."
node .ai-dev-logs/scripts/update-dashboard.js

echo "✅ AI 开发记录更新完成"
echo "📁 查看记录: .ai-dev-logs/commits/$COMMIT_SHORT.md"
```

### Post-merge Hook

```bash
#!/bin/bash
# .git/hooks/post-merge

echo "🔀 AI 开发记录 Post-merge Hook"

# 检测冲突
CONFLICTS=$(git diff --name-only --diff-filter=U)

if [ ! -z "$CONFLICTS" ]; then
  echo "⚠️  检测到合并冲突，记录冲突信息..."

  cat > ".ai-dev-logs/conflicts/$(date +%Y-%m-%d-%H%M%S).md" << EOF
# 合并冲突记录

## 时间
$(date +"%Y-%m-%d %H:%M:%S")

## 冲突文件
$CONFLICTS

## 解决建议
1. 检查每个冲突文件
2. 与团队成员沟通
3. 运行测试确保正确性

## 命令参考
\`\`\`bash
# 查看冲突
git status

# 标记为已解决
git add <file>

# 完成合并
git commit
\`\`\`
EOF
fi

# 同步记录
echo "🔄 同步团队记录..."
node .ai-dev-logs/scripts/sync-team-logs.js

echo "✅ 合并记录完成"
```

## CI/CD 集成

### GitHub Actions

```yaml
# .github/workflows/dev-logs.yml
name: AI Development Logs

on:
  push:
    branches: [main, develop]
  pull_request:
    types: [opened, synchronize, reopened]
  schedule:
    - cron: '0 0 * * 0'  # 每周日生成周报

jobs:
  log-analysis:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # 获取完整历史

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install Dependencies
        run: |
          cd .ai-dev-logs/scripts
          npm install

      - name: Analyze Dev Logs
        run: |
          node .ai-dev-logs/scripts/analyze.js --check-consistency
          node .ai-dev-logs/scripts/report.js --format=json > report.json

      - name: Check Quality Gates
        run: |
          node .ai-dev-logs/scripts/quality-gates.js
        continue-on-error: false

      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: dev-logs-report
          path: report.json

      - name: Comment on PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = JSON.parse(fs.readFileSync('report.json', 'utf8'));

            const comment = `## 📊 AI 开发记录分析

            ### 任务完成情况
            - 完成: ${report.tasks.completed}
            - 进行中: ${report.tasks.in_progress}
            - 待处理: ${report.tasks.pending}

            ### 代码质量
            - 覆盖率: ${report.quality.coverage}%
            - 复杂度: ${report.quality.complexity}

            ### 性能指标
            - 响应时间: ${report.performance.responseTime}ms
            - 错误率: ${report.performance.errorRate}%

            [查看详细报告](.ai-dev-logs/reports/latest.html)`;

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });

  weekly-report:
    if: github.event.schedule == '0 0 * * 0'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Generate Weekly Report
        run: |
          node .ai-dev-logs/scripts/weekly-report.js

      - name: Create Issue
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('.ai-dev-logs/reports/weekly.md', 'utf8');

            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `📊 周报 - ${new Date().toISOString().split('T')[0]}`,
              body: report,
              labels: ['weekly-report', 'ai-logs']
            });
```

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - analyze
  - report
  - notify

variables:
  LOGS_DIR: ".ai-dev-logs"

analyze-logs:
  stage: analyze
  script:
    - cd $LOGS_DIR/scripts
    - npm install
    - node analyze.js --output=analysis.json
  artifacts:
    reports:
      junit: $LOGS_DIR/reports/junit.xml
    paths:
      - $LOGS_DIR/reports/
    expire_in: 1 week

generate-report:
  stage: report
  dependencies:
    - analyze-logs
  script:
    - node $LOGS_DIR/scripts/generate-report.js
    - node $LOGS_DIR/scripts/update-dashboard.js
  artifacts:
    paths:
      - $LOGS_DIR/dashboard/
    expire_in: 1 month

notify-team:
  stage: notify
  only:
    - schedules
  script:
    - node $LOGS_DIR/scripts/notify.js --channel=slack
```

## 自动化脚本

### 每日总结生成器

```javascript
// daily-summary.js
const fs = require('fs').promises;
const path = require('path');

class DailySummaryGenerator {
  async generate() {
    const today = new Date().toISOString().split('T')[0];
    const logs = await this.collectTodayLogs(today);
    const summary = this.createSummary(logs);
    await this.saveSummary(summary, today);
    return summary;
  }

  async collectTodayLogs(date) {
    const logsDir = '.ai-dev-logs';
    const logs = {
      tasks: [],
      commits: [],
      issues: [],
      metrics: {}
    };

    // 收集任务
    const tasksDir = path.join(logsDir, 'daily', `${date}.md`);
    if (await this.fileExists(tasksDir)) {
      const content = await fs.readFile(tasksDir, 'utf8');
      logs.tasks = this.parseTasks(content);
    }

    // 收集提交
    logs.commits = await this.getGitCommits(date);

    // 收集指标
    const metricsFile = path.join(logsDir, 'metrics', `${date}.json`);
    if (await this.fileExists(metricsFile)) {
      logs.metrics = JSON.parse(await fs.readFile(metricsFile, 'utf8'));
    }

    return logs;
  }

  createSummary(logs) {
    const completed = logs.tasks.filter(t => t.status === 'completed');
    const inProgress = logs.tasks.filter(t => t.status === 'in_progress');
    const failed = logs.tasks.filter(t => t.status === 'failed');

    return {
      date: new Date().toISOString(),
      statistics: {
        tasksCompleted: completed.length,
        tasksInProgress: inProgress.length,
        tasksFailed: failed.length,
        commits: logs.commits.length,
        linesAdded: logs.commits.reduce((a, c) => a + c.additions, 0),
        linesDeleted: logs.commits.reduce((a, c) => a + c.deletions, 0)
      },
      tasks: {
        completed,
        inProgress,
        failed
      },
      metrics: logs.metrics,
      highlights: this.extractHighlights(logs),
      recommendations: this.generateRecommendations(logs)
    };
  }

  extractHighlights(logs) {
    const highlights = [];

    // 高完成率
    const completionRate = logs.tasks.length > 0 ?
      (logs.tasks.filter(t => t.status === 'completed').length / logs.tasks.length) * 100 : 0;

    if (completionRate >= 80) {
      highlights.push(`✨ 高任务完成率: ${completionRate.toFixed(1)}%`);
    }

    // 性能改善
    if (logs.metrics.performance?.improved) {
      highlights.push('🚀 性能提升');
    }

    // 零错误
    if (!logs.issues || logs.issues.length === 0) {
      highlights.push('✅ 无错误报告');
    }

    return highlights;
  }

  generateRecommendations(logs) {
    const recommendations = [];

    // 未完成任务
    if (logs.tasks.filter(t => t.status === 'in_progress').length > 3) {
      recommendations.push({
        type: 'task_management',
        message: '考虑减少并行任务数量，专注完成当前任务'
      });
    }

    // 代码质量
    if (logs.metrics.codeQuality?.coverage < 70) {
      recommendations.push({
        type: 'quality',
        message: '增加测试覆盖率，当前覆盖率偏低'
      });
    }

    return recommendations;
  }

  async saveSummary(summary, date) {
    const summaryPath = `.ai-dev-logs/daily/summary-${date}.json`;
    await fs.writeFile(summaryPath, JSON.stringify(summary, null, 2));

    // 生成Markdown版本
    const markdown = this.toMarkdown(summary);
    const mdPath = `.ai-dev-logs/daily/summary-${date}.md`;
    await fs.writeFile(mdPath, markdown);
  }

  toMarkdown(summary) {
    return `# 每日总结 - ${summary.date.split('T')[0]}

## 📊 统计
- **完成任务**: ${summary.statistics.tasksCompleted}
- **进行中**: ${summary.statistics.tasksInProgress}
- **失败**: ${summary.statistics.tasksFailed}
- **提交数**: ${summary.statistics.commits}
- **代码变更**: +${summary.statistics.linesAdded} / -${summary.statistics.linesDeleted}

## ✨ 亮点
${summary.highlights.map(h => `- ${h}`).join('\n')}

## 💡 建议
${summary.recommendations.map(r => `- ${r.message}`).join('\n')}
`;
  }

  async fileExists(path) {
    try {
      await fs.access(path);
      return true;
    } catch {
      return false;
    }
  }

  async getGitCommits(date) {
    const { execSync } = require('child_process');
    try {
      const output = execSync(
        `git log --since="${date} 00:00" --until="${date} 23:59" --oneline --numstat`,
        { encoding: 'utf8' }
      );
      return this.parseGitLog(output);
    } catch {
      return [];
    }
  }

  parseGitLog(output) {
    // 简化的git日志解析
    const commits = [];
    const lines = output.split('\n');

    let currentCommit = null;
    for (const line of lines) {
      if (line.match(/^[a-f0-9]{7}/)) {
        if (currentCommit) commits.push(currentCommit);
        currentCommit = {
          hash: line.substring(0, 7),
          message: line.substring(8),
          additions: 0,
          deletions: 0
        };
      } else if (currentCommit && line.match(/^\d+\s+\d+/)) {
        const [additions, deletions] = line.split('\t');
        currentCommit.additions += parseInt(additions) || 0;
        currentCommit.deletions += parseInt(deletions) || 0;
      }
    }

    if (currentCommit) commits.push(currentCommit);
    return commits;
  }

  parseTasks(content) {
    // 简化的任务解析
    const tasks = [];
    const lines = content.split('\n');

    for (const line of lines) {
      if (line.includes('- [x]')) {
        tasks.push({ status: 'completed', title: line.replace('- [x]', '').trim() });
      } else if (line.includes('- [ ]')) {
        tasks.push({ status: 'pending', title: line.replace('- [ ]', '').trim() });
      }
    }

    return tasks;
  }
}

// 执行
if (require.main === module) {
  const generator = new DailySummaryGenerator();
  generator.generate().then(() => {
    console.log('✅ 每日总结已生成');
  }).catch(error => {
    console.error('❌ 生成失败:', error);
  });
}

module.exports = DailySummaryGenerator;
```

### 自动索引更新

```javascript
// update-index.js
const fs = require('fs').promises;
const path = require('path');

class IndexUpdater {
  async update() {
    const logsDir = '.ai-dev-logs';
    const index = await this.buildIndex(logsDir);
    await this.saveIndex(index);
    await this.generateQuickLinks(index);
  }

  async buildIndex(dir, index = {}) {
    index.files = index.files || [];
    index.features = index.features || [];
    index.tasks = index.tasks || [];
    index.lastUpdated = new Date().toISOString();

    const items = await fs.readdir(dir, { withFileTypes: true });

    for (const item of items) {
      const fullPath = path.join(dir, item.name);

      if (item.isDirectory()) {
        if (item.name === 'features') {
          const features = await this.indexFeatures(fullPath);
          index.features.push(...features);
        } else {
          await this.buildIndex(fullPath, index);
        }
      } else if (item.name.endsWith('.md')) {
        index.files.push({
          path: fullPath,
          name: item.name,
          modified: (await fs.stat(fullPath)).mtime
        });
      }
    }

    return index;
  }

  async indexFeatures(featuresDir) {
    const features = [];
    const items = await fs.readdir(featuresDir, { withFileTypes: true });

    for (const item of items) {
      if (item.isDirectory()) {
        const featurePath = path.join(featuresDir, item.name);
        const overview = path.join(featurePath, 'overview.md');

        if (await this.fileExists(overview)) {
          const content = await fs.readFile(overview, 'utf8');
          features.push({
            name: item.name,
            path: featurePath,
            status: this.extractStatus(content),
            progress: this.extractProgress(content)
          });
        }
      }
    }

    return features;
  }

  extractStatus(content) {
    const match = content.match(/状态[：:]\s*(.+)/);
    return match ? match[1].trim() : 'unknown';
  }

  extractProgress(content) {
    const completed = (content.match(/- \[x\]/g) || []).length;
    const total = (content.match(/- \[[\sx]\]/g) || []).length;
    return total > 0 ? Math.round((completed / total) * 100) : 0;
  }

  async saveIndex(index) {
    const indexPath = '.ai-dev-logs/index.json';
    await fs.writeFile(indexPath, JSON.stringify(index, null, 2));

    // 生成Markdown索引
    const markdown = this.toMarkdown(index);
    await fs.writeFile('.ai-dev-logs/index.md', markdown);
  }

  toMarkdown(index) {
    return `# AI 开发记录索引

最后更新: ${index.lastUpdated}

## 功能模块 (${index.features.length})

| 功能 | 状态 | 进度 | 路径 |
|-----|------|------|------|
${index.features.map(f =>
  `| ${f.name} | ${f.status} | ${f.progress}% | [查看](${f.path}) |`
).join('\n')}

## 最近更新的文件

${index.files
  .sort((a, b) => b.modified - a.modified)
  .slice(0, 10)
  .map(f => `- [${f.name}](${f.path}) - ${f.modified.toISOString()}`)
  .join('\n')}

## 快速链接

- [今日记录](daily/${new Date().toISOString().split('T')[0]}.md)
- [本周总结](weekly/current.md)
- [性能指标](metrics/latest.json)
- [仪表板](dashboard/index.html)
`;
  }

  async generateQuickLinks(index) {
    const links = {
      today: `daily/${new Date().toISOString().split('T')[0]}.md`,
      features: index.features.map(f => ({
        name: f.name,
        path: f.path,
        status: f.status
      })),
      reports: {
        daily: 'reports/daily/',
        weekly: 'reports/weekly/',
        monthly: 'reports/monthly/'
      }
    };

    await fs.writeFile(
      '.ai-dev-logs/quick-links.json',
      JSON.stringify(links, null, 2)
    );
  }

  async fileExists(path) {
    try {
      await fs.access(path);
      return true;
    } catch {
      return false;
    }
  }
}

// 执行
if (require.main === module) {
  const updater = new IndexUpdater();
  updater.update().then(() => {
    console.log('✅ 索引更新完成');
  }).catch(error => {
    console.error('❌ 更新失败:', error);
  });
}

module.exports = IndexUpdater;
```

### VSCode 任务配置

```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "AI Logs: 生成今日总结",
      "type": "shell",
      "command": "node",
      "args": [
        ".ai-dev-logs/scripts/daily-summary.js"
      ],
      "group": "none",
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    },
    {
      "label": "AI Logs: 更新索引",
      "type": "shell",
      "command": "node",
      "args": [
        ".ai-dev-logs/scripts/update-index.js"
      ],
      "group": "none"
    },
    {
      "label": "AI Logs: 收集指标",
      "type": "shell",
      "command": "node",
      "args": [
        ".ai-dev-logs/scripts/metrics-collector.js"
      ],
      "group": "none"
    },
    {
      "label": "AI Logs: 打开仪表板",
      "type": "shell",
      "command": "start",
      "windows": {
        "command": "start"
      },
      "linux": {
        "command": "xdg-open"
      },
      "osx": {
        "command": "open"
      },
      "args": [
        ".ai-dev-logs/dashboard/index.html"
      ],
      "group": "none"
    }
  ]
}
```

---

**子模块名称**：自动化与集成
**父模块**：dev-logs-core
**功能**：Git Hooks、CI/CD集成、自动化脚本
**适用场景**：需要自动化记录和持续集成的项目