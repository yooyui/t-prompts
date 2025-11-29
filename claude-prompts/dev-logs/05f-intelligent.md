# 子模块：智能记录功能

> 前置要求：`/load dev-logs-core`

## 自动生成摘要

```javascript
// AI 自动生成任务摘要
class TaskSummarizer {
  generateSummary(taskData) {
    return {
      title: this.extractTitle(taskData),
      duration: this.calculateDuration(taskData),
      changes: this.summarizeChanges(taskData),
      outcome: this.determineOutcome(taskData),
      nextSteps: this.suggestNextSteps(taskData)
    };
  }

  // 智能提取关键信息
  extractKeyPoints(logs) {
    const points = [];

    // 识别重要决策
    if (logs.includes('decided to') || logs.includes('chose')) {
      points.push({
        type: 'decision',
        content: this.extractDecision(logs)
      });
    }

    // 识别问题和解决方案
    if (logs.includes('error') || logs.includes('issue')) {
      points.push({
        type: 'problem',
        content: this.extractProblem(logs),
        solution: this.extractSolution(logs)
      });
    }

    // 识别性能改进
    if (logs.includes('optimized') || logs.includes('improved')) {
      points.push({
        type: 'optimization',
        content: this.extractOptimization(logs)
      });
    }

    // 识别学习点
    if (logs.includes('learned') || logs.includes('discovered')) {
      points.push({
        type: 'learning',
        content: this.extractLearning(logs)
      });
    }

    return points;
  }

  extractTitle(taskData) {
    // 从任务描述中智能提取标题
    const description = taskData.description || '';

    // 移除常见前缀
    let title = description.replace(/^(implement|create|add|fix|update|refactor)\s+/i, '');

    // 首字母大写
    title = title.charAt(0).toUpperCase() + title.slice(1);

    // 限制长度
    if (title.length > 50) {
      title = title.substring(0, 47) + '...';
    }

    return title;
  }

  calculateDuration(taskData) {
    const start = new Date(taskData.startTime);
    const end = new Date(taskData.endTime || Date.now());
    const duration = end - start;

    const hours = Math.floor(duration / (1000 * 60 * 60));
    const minutes = Math.floor((duration % (1000 * 60 * 60)) / (1000 * 60));

    if (hours > 0) {
      return `${hours}小时${minutes}分钟`;
    }
    return `${minutes}分钟`;
  }

  summarizeChanges(taskData) {
    const changes = [];

    if (taskData.filesAdded > 0) {
      changes.push(`新增 ${taskData.filesAdded} 个文件`);
    }

    if (taskData.filesModified > 0) {
      changes.push(`修改 ${taskData.filesModified} 个文件`);
    }

    if (taskData.linesAdded > 0 || taskData.linesDeleted > 0) {
      changes.push(`代码变更 +${taskData.linesAdded}/-${taskData.linesDeleted}`);
    }

    if (taskData.testsAdded > 0) {
      changes.push(`新增 ${taskData.testsAdded} 个测试`);
    }

    return changes.join(', ');
  }

  determineOutcome(taskData) {
    if (taskData.status === 'completed') {
      if (taskData.testsPass && taskData.coverage >= 80) {
        return '✨ 高质量完成';
      }
      return '✅ 成功完成';
    }

    if (taskData.status === 'failed') {
      return '❌ 未能完成';
    }

    if (taskData.status === 'blocked') {
      return '🚫 被阻塞';
    }

    return '🚧 进行中';
  }

  suggestNextSteps(taskData) {
    const suggestions = [];

    // 基于测试覆盖率
    if (taskData.coverage < 60) {
      suggestions.push('增加测试覆盖率');
    }

    // 基于代码复杂度
    if (taskData.complexity > 10) {
      suggestions.push('考虑重构以降低复杂度');
    }

    // 基于性能
    if (taskData.performanceIssues) {
      suggestions.push('进行性能优化');
    }

    // 基于文档
    if (!taskData.documentationUpdated) {
      suggestions.push('更新相关文档');
    }

    // 基于代码审查
    if (!taskData.reviewed) {
      suggestions.push('请求代码审查');
    }

    return suggestions;
  }

  extractDecision(logs) {
    const patterns = [
      /decided to (.+?)(?:\.|,|;|$)/i,
      /chose (.+?) (?:over|instead of)/i,
      /selected (.+?) for/i
    ];

    for (const pattern of patterns) {
      const match = logs.match(pattern);
      if (match) {
        return match[1].trim();
      }
    }

    return '决策详情未能提取';
  }

  extractProblem(logs) {
    const patterns = [
      /error:?\s*(.+?)(?:\.|$)/i,
      /issue:?\s*(.+?)(?:\.|$)/i,
      /problem:?\s*(.+?)(?:\.|$)/i
    ];

    for (const pattern of patterns) {
      const match = logs.match(pattern);
      if (match) {
        return match[1].trim();
      }
    }

    return '问题详情未能提取';
  }

  extractSolution(logs) {
    const patterns = [
      /fixed by (.+?)(?:\.|$)/i,
      /solved by (.+?)(?:\.|$)/i,
      /resolved:?\s*(.+?)(?:\.|$)/i
    ];

    for (const pattern of patterns) {
      const match = logs.match(pattern);
      if (match) {
        return match[1].trim();
      }
    }

    return '解决方案未能提取';
  }
}
```

## 智能分类和标签

```javascript
// 自动标签系统
class AutoTagger {
  constructor() {
    this.techPatterns = this.loadTechPatterns();
    this.typePatterns = this.loadTypePatterns();
  }

  loadTechPatterns() {
    return {
      'react': ['useState', 'useEffect', 'jsx', 'React', 'component'],
      'vue': ['v-model', 'computed', 'mounted', 'Vue', 'template'],
      'angular': ['@Component', 'NgModule', 'Observable', 'Angular'],
      'node': ['require', 'module.exports', 'npm', 'express', 'async/await'],
      'python': ['import', 'def', 'pip', 'class', '__init__'],
      'docker': ['dockerfile', 'container', 'image', 'docker-compose'],
      'kubernetes': ['kubectl', 'pod', 'deployment', 'service', 'k8s'],
      'database': ['SQL', 'query', 'table', 'index', 'migration'],
      'api': ['endpoint', 'REST', 'GraphQL', 'swagger', 'postman'],
      'testing': ['test', 'spec', 'jest', 'mocha', 'assert'],
      'security': ['auth', 'encryption', 'token', 'permission', 'CORS'],
      'performance': ['optimize', 'cache', 'lazy', 'throttle', 'debounce']
    };
  }

  loadTypePatterns() {
    return {
      'feature': ['implement', 'add', 'create', 'new feature'],
      'bugfix': ['fix', 'bug', 'error', 'issue', 'problem'],
      'refactor': ['refactor', 'restructure', 'reorganize', 'clean'],
      'optimization': ['optimize', 'improve', 'enhance', 'performance'],
      'documentation': ['document', 'readme', 'comment', 'jsdoc'],
      'test': ['test', 'spec', 'coverage', 'unit test'],
      'chore': ['update', 'upgrade', 'dependency', 'config']
    };
  }

  tagTask(taskContent) {
    const tags = new Set();

    // 技术栈标签
    const techStack = this.detectTechStack(taskContent);
    techStack.forEach(tech => tags.add(`tech:${tech}`));

    // 任务类型标签
    const taskType = this.classifyTaskType(taskContent);
    tags.add(`type:${taskType}`);

    // 复杂度标签
    const complexity = this.assessComplexity(taskContent);
    tags.add(`complexity:${complexity}`);

    // 影响范围标签
    const impact = this.assessImpact(taskContent);
    tags.add(`impact:${impact}`);

    // 优先级标签
    const priority = this.determinePriority(taskContent);
    tags.add(`priority:${priority}`);

    // 自定义标签
    const customTags = this.extractCustomTags(taskContent);
    customTags.forEach(tag => tags.add(tag));

    return Array.from(tags);
  }

  detectTechStack(content) {
    const detected = [];
    const lowerContent = content.toLowerCase();

    for (const [tech, keywords] of Object.entries(this.techPatterns)) {
      const score = keywords.reduce((acc, keyword) => {
        const regex = new RegExp(`\\b${keyword.toLowerCase()}\\b`, 'gi');
        const matches = lowerContent.match(regex) || [];
        return acc + matches.length;
      }, 0);

      if (score >= 2) {  // 至少匹配2个关键词
        detected.push(tech);
      }
    }

    return detected;
  }

  classifyTaskType(content) {
    const lowerContent = content.toLowerCase();
    let bestMatch = 'task';
    let highestScore = 0;

    for (const [type, keywords] of Object.entries(this.typePatterns)) {
      const score = keywords.reduce((acc, keyword) => {
        return acc + (lowerContent.includes(keyword) ? 1 : 0);
      }, 0);

      if (score > highestScore) {
        highestScore = score;
        bestMatch = type;
      }
    }

    return bestMatch;
  }

  assessComplexity(content) {
    const factors = {
      fileCount: (content.match(/\.(js|ts|py|java|cs)\b/g) || []).length,
      lineCount: (content.match(/\+\d+.*-\d+/g) || []).length,
      dependencies: (content.match(/import|require|using/g) || []).length,
      conditions: (content.match(/if|else|switch|case/g) || []).length,
      loops: (content.match(/for|while|foreach|map/g) || []).length
    };

    const score = Object.values(factors).reduce((a, b) => a + b, 0);

    if (score < 5) return 'low';
    if (score < 15) return 'medium';
    if (score < 30) return 'high';
    return 'very-high';
  }

  assessImpact(content) {
    const impactKeywords = {
      critical: ['production', 'security', 'data loss', 'breaking change'],
      high: ['api', 'database', 'authentication', 'performance'],
      medium: ['ui', 'feature', 'enhancement', 'refactor'],
      low: ['typo', 'comment', 'formatting', 'style']
    };

    const lowerContent = content.toLowerCase();

    for (const [level, keywords] of Object.entries(impactKeywords)) {
      if (keywords.some(keyword => lowerContent.includes(keyword))) {
        return level;
      }
    }

    return 'medium';
  }

  determinePriority(content) {
    const priorityIndicators = {
      'p0': ['urgent', 'critical', 'blocker', 'asap'],
      'p1': ['important', 'high priority', 'needed'],
      'p2': ['medium', 'normal', 'standard'],
      'p3': ['low', 'nice to have', 'future']
    };

    const lowerContent = content.toLowerCase();

    for (const [priority, indicators] of Object.entries(priorityIndicators)) {
      if (indicators.some(indicator => lowerContent.includes(indicator))) {
        return priority;
      }
    }

    return 'p2';  // 默认中等优先级
  }

  extractCustomTags(content) {
    const tags = [];
    const matches = content.matchAll(/#(\w+)/g);

    for (const match of matches) {
      tags.push(match[1].toLowerCase());
    }

    return tags;
  }
}
```

## 智能建议生成器

```javascript
class SmartSuggestions {
  generateSuggestions(context) {
    const suggestions = [];

    // 分析上下文
    const analysis = this.analyzeContext(context);

    // 基于分析生成建议
    suggestions.push(...this.getSuggestionsByType(analysis.type));
    suggestions.push(...this.getSuggestionsByStatus(analysis.status));
    suggestions.push(...this.getSuggestionsByMetrics(analysis.metrics));
    suggestions.push(...this.getSuggestionsByPatterns(analysis.patterns));

    // 排序和去重
    return this.rankAndFilter(suggestions);
  }

  analyzeContext(context) {
    return {
      type: context.taskType || 'general',
      status: context.status || 'in_progress',
      metrics: {
        coverage: context.coverage || 0,
        complexity: context.complexity || 0,
        performance: context.performance || {}
      },
      patterns: this.detectPatterns(context)
    };
  }

  getSuggestionsByType(type) {
    const suggestions = {
      feature: [
        { text: '考虑添加功能开关', priority: 2 },
        { text: '准备A/B测试', priority: 3 },
        { text: '更新用户文档', priority: 2 }
      ],
      bugfix: [
        { text: '添加回归测试', priority: 1 },
        { text: '检查相关功能', priority: 1 },
        { text: '更新changelog', priority: 3 }
      ],
      refactor: [
        { text: '运行性能基准测试', priority: 2 },
        { text: '确保测试覆盖', priority: 1 },
        { text: '逐步迁移策略', priority: 2 }
      ],
      optimization: [
        { text: '建立性能基线', priority: 1 },
        { text: '添加监控指标', priority: 2 },
        { text: '准备回滚方案', priority: 2 }
      ]
    };

    return suggestions[type] || [];
  }

  getSuggestionsByStatus(status) {
    const suggestions = {
      planning: [
        { text: '明确验收标准', priority: 1 },
        { text: '识别依赖项', priority: 1 },
        { text: '评估风险', priority: 2 }
      ],
      in_progress: [
        { text: '定期提交进度', priority: 2 },
        { text: '及时更新文档', priority: 3 },
        { text: '持续运行测试', priority: 2 }
      ],
      blocked: [
        { text: '寻求团队帮助', priority: 1 },
        { text: '考虑替代方案', priority: 1 },
        { text: '记录阻塞原因', priority: 2 }
      ],
      review: [
        { text: '准备演示材料', priority: 3 },
        { text: '整理关键决策', priority: 2 },
        { text: '收集反馈意见', priority: 2 }
      ]
    };

    return suggestions[status] || [];
  }

  getSuggestionsByMetrics(metrics) {
    const suggestions = [];

    if (metrics.coverage < 60) {
      suggestions.push({
        text: '测试覆盖率偏低，建议增加单元测试',
        priority: 1
      });
    }

    if (metrics.complexity > 15) {
      suggestions.push({
        text: '代码复杂度过高，考虑拆分函数',
        priority: 2
      });
    }

    if (metrics.performance.responseTime > 1000) {
      suggestions.push({
        text: '响应时间超过1秒，需要性能优化',
        priority: 1
      });
    }

    return suggestions;
  }

  getSuggestionsByPatterns(patterns) {
    const suggestions = [];

    if (patterns.includes('repeated_failures')) {
      suggestions.push({
        text: '检测到重复失败，建议根因分析',
        priority: 1
      });
    }

    if (patterns.includes('long_running')) {
      suggestions.push({
        text: '任务运行时间过长，考虑分解为子任务',
        priority: 2
      });
    }

    if (patterns.includes('frequent_changes')) {
      suggestions.push({
        text: '频繁修改同一区域，考虑架构重构',
        priority: 2
      });
    }

    return suggestions;
  }

  detectPatterns(context) {
    const patterns = [];

    // 检测重复失败
    if (context.failureCount > 3) {
      patterns.push('repeated_failures');
    }

    // 检测长时间运行
    if (context.duration > 3600000) {  // 超过1小时
      patterns.push('long_running');
    }

    // 检测频繁变更
    if (context.changeFrequency > 10) {
      patterns.push('frequent_changes');
    }

    // 检测代码异味
    if (context.codeSmells > 5) {
      patterns.push('code_smells');
    }

    return patterns;
  }

  rankAndFilter(suggestions) {
    // 按优先级排序
    suggestions.sort((a, b) => a.priority - b.priority);

    // 去重
    const seen = new Set();
    const unique = suggestions.filter(s => {
      if (seen.has(s.text)) {
        return false;
      }
      seen.add(s.text);
      return true;
    });

    // 限制数量
    return unique.slice(0, 5);
  }
}
```

## 智能任务关联

```javascript
class TaskRelationAnalyzer {
  findRelatedTasks(currentTask, allTasks) {
    const related = [];

    for (const task of allTasks) {
      if (task.id === currentTask.id) continue;

      const similarity = this.calculateSimilarity(currentTask, task);
      if (similarity > 0.3) {
        related.push({
          task,
          similarity,
          relationship: this.determineRelationship(currentTask, task)
        });
      }
    }

    return related.sort((a, b) => b.similarity - a.similarity);
  }

  calculateSimilarity(task1, task2) {
    const factors = {
      // 文件重叠
      fileOverlap: this.calculateFileOverlap(task1.files, task2.files) * 0.3,

      // 标签相似度
      tagSimilarity: this.calculateTagSimilarity(task1.tags, task2.tags) * 0.2,

      // 时间接近度
      timeProximity: this.calculateTimeProximity(task1.date, task2.date) * 0.2,

      // 内容相似度
      contentSimilarity: this.calculateContentSimilarity(task1.content, task2.content) * 0.3
    };

    return Object.values(factors).reduce((a, b) => a + b, 0);
  }

  calculateFileOverlap(files1 = [], files2 = []) {
    if (files1.length === 0 || files2.length === 0) return 0;

    const set1 = new Set(files1);
    const set2 = new Set(files2);
    const intersection = new Set([...set1].filter(x => set2.has(x)));

    return intersection.size / Math.min(set1.size, set2.size);
  }

  calculateTagSimilarity(tags1 = [], tags2 = []) {
    if (tags1.length === 0 || tags2.length === 0) return 0;

    const set1 = new Set(tags1);
    const set2 = new Set(tags2);
    const intersection = new Set([...set1].filter(x => set2.has(x)));

    return intersection.size / Math.max(set1.size, set2.size);
  }

  calculateTimeProximity(date1, date2) {
    const d1 = new Date(date1);
    const d2 = new Date(date2);
    const diff = Math.abs(d1 - d2);
    const daysDiff = diff / (1000 * 60 * 60 * 24);

    if (daysDiff < 1) return 1;
    if (daysDiff < 7) return 0.7;
    if (daysDiff < 30) return 0.3;
    return 0;
  }

  calculateContentSimilarity(content1, content2) {
    // 简单的词频相似度
    const words1 = this.extractWords(content1);
    const words2 = this.extractWords(content2);

    const commonWords = words1.filter(w => words2.includes(w));
    return commonWords.length / Math.max(words1.length, words2.length);
  }

  extractWords(content) {
    return content
      .toLowerCase()
      .match(/\b\w+\b/g)
      ?.filter(w => w.length > 3) || [];
  }

  determineRelationship(task1, task2) {
    // 依赖关系
    if (task1.dependencies?.includes(task2.id)) {
      return 'depends_on';
    }

    // 阻塞关系
    if (task1.blockedBy?.includes(task2.id)) {
      return 'blocked_by';
    }

    // 父子关系
    if (task1.parent === task2.id) {
      return 'child_of';
    }
    if (task2.parent === task1.id) {
      return 'parent_of';
    }

    // 相关任务
    return 'related';
  }
}
```

---

**子模块名称**：智能记录功能
**父模块**：dev-logs-core
**功能**：自动摘要、智能标签、建议生成、任务关联
**适用场景**：需要AI增强功能的高级项目