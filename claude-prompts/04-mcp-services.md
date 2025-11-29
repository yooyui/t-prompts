# 模块：MCP 服务详细配置

## 服务优先级策略

### 三级优先级
1. **L1 本地服务**（最优先）
   - Serena、Filesystem、Memory
   - 无网络依赖，响应快速

2. **L2 缓存服务**（次优先）
   - 已缓存的查询结果
   - Memory 中的历史记录

3. **L3 远程服务**（必要时）
   - 通过 mcp-router 的远程服务
   - 需要网络连接

## 本地服务详情

### Serena（代码分析编辑）
**使用决策树**：
```
需要代码操作？
├─ 是：使用 Serena
│  ├─ 查看结构 → get_symbols_overview
│  ├─ 查找定义 → find_symbol
│  ├─ 查找引用 → find_referencing_symbols
│  ├─ 搜索模式 → search_for_pattern
│  └─ 修改代码 → replace_*/insert_*
└─ 否：考虑其他工具
```

**高级技巧**：
```python
# 1. 符号重构流程
find_symbol(name) →
find_referencing_symbols(symbol) →
replace_symbol_body(new_implementation)

# 2. 智能搜索
search_for_pattern(
    pattern="TODO|FIXME",
    paths_include_glob="src/**/*.ts",
    include_context_lines=2
)

# 3. 批量替换
replace_regex(
    pattern="old_name",
    replacement="new_name",
    allow_multiple_occurrences=True
)
```

### Filesystem（文件系统）
**适用场景**：
- 访问用户文档/桌面
- 读写配置文件
- 处理非代码文件

**路径配置**：
```json
{
  "filesystem": {
    "allowed_paths": [
      "~/Desktop",
      "~/Documents",
      "/project/path"
    ]
  }
}
```

### Memory（跨会话记忆）
**使用模式**：
```python
# 保存项目上下文
write_memory("project_context", {
    "tech_stack": ["React", "Node.js"],
    "conventions": {"naming": "camelCase"},
    "decisions": [...]
})

# 读取历史决策
decisions = read_memory("project_decisions")

# 构建知识库
write_memory(f"solution_{problem_hash}", solution)
```

## 远程服务详情

### Context7（文档查询）
**优化查询**：
```python
# 1. 先确定库ID
resolve_library_id("react")

# 2. 精确查询
get_library_docs(
    library_id="react",
    topic="hooks",
    tokens=3000  # 限制返回大小
)
```

### Sequential-Thinking（任务规划）
**使用场景**：
- 复杂任务分解
- 多步骤流程设计
- 依赖关系分析

**参数优化**：
```yaml
total_thoughts: 8    # 6-10之间
output_format: steps # 输出格式
include_risks: true  # 包含风险分析
```

### Chrome DevTools（性能分析）
**性能分析流程**：
```javascript
// 1. 连接到页面
connect_to_page(url)

// 2. 记录性能
start_performance_recording()
// 执行用户操作
stop_performance_recording()

// 3. 分析结果
analyze_performance_data()

// 4. 生成优化建议
generate_optimization_report()
```

**与 Playwright 对比**：
| 场景 | Chrome DevTools | Playwright |
|------|----------------|------------|
| 性能分析 | ✅ 最佳选择 | ❌ 基础支持 |
| 自动化测试 | ❌ 不适合 | ✅ 最佳选择 |
| 调试网络 | ✅ 详细信息 | ❌ 基础信息 |
| 跨浏览器 | ❌ 仅Chrome | ✅ 全浏览器 |

## 服务组合策略

### 文档查询链
```
1. Memory（检查缓存）
   ↓ 未命中
2. Context7（官方文档）
   ↓ 未找到
3. DDG-Search（网络搜索）
   ↓ 仍未找到
4. 请求用户澄清
```

### 代码分析链
```
1. Serena（本地分析）
   ↓ 需要更多上下文
2. Memory（历史记录）
   ↓ 需要外部信息
3. Context7（查询最佳实践）
```

### 性能优化链
```
1. Chrome DevTools（性能分析）
   ↓ 发现问题
2. Serena（定位代码）
   ↓ 需要方案
3. Sequential-Thinking（生成优化计划）
   ↓ 实施
4. Serena（修改代码）
```

## 错误处理

### 降级策略
```python
try:
    # L3: 尝试远程服务
    result = call_remote_service()
except ServiceUnavailable:
    try:
        # L2: 尝试缓存
        result = get_from_cache()
    except CacheMiss:
        # L1: 使用本地工具
        result = use_local_tool()
```

### 重试机制
```yaml
retry_policy:
  max_attempts: 3
  backoff_strategy: exponential
  initial_delay: 1s
  max_delay: 30s

rate_limits:
  429_too_many_requests:
    wait: 20s
    reduce_scope: true

  503_service_unavailable:
    wait: 5s
    fallback: true
```

## 性能优化

### 批量操作
```python
# ❌ 低效：多次调用
for file in files:
    serena.read_file(file)

# ✅ 高效：批量处理
serena.search_for_pattern(
    pattern="import",
    paths_include_glob="**/*.ts"
)
```

### 缓存策略
```python
# 实现简单缓存
cache = {}
cache_ttl = 300  # 5分钟

def cached_query(key, query_fn):
    if key in cache:
        if time.time() - cache[key]['time'] < cache_ttl:
            return cache[key]['data']

    result = query_fn()
    cache[key] = {'data': result, 'time': time.time()}
    return result
```

## 服务配置示例

### 最小配置
```json
{
  "mcpServers": {
    "serena": { "enabled": true },
    "filesystem": { "enabled": true },
    "memory": { "enabled": true }
  }
}
```

### 标准配置
```json
{
  "mcpServers": {
    "serena": { "enabled": true },
    "filesystem": { "enabled": true },
    "memory": { "enabled": true },
    "mcp-router": {
      "command": "npx",
      "args": ["-y", "@mcp_router/cli@latest", "connect"],
      "services": ["context7", "sequential-thinking"]
    }
  }
}
```

### 完整配置
```json
{
  "mcpServers": {
    "serena": {
      "enabled": true,
      "project_path": "./",
      "ignore_patterns": ["node_modules", "dist"]
    },
    "filesystem": {
      "enabled": true,
      "allowed_paths": ["~/Desktop", "~/Documents"]
    },
    "memory": {
      "enabled": true,
      "persistent": true,
      "max_size": "100MB"
    },
    "mcp-router": {
      "command": "npx",
      "args": ["-y", "@mcp_router/cli@latest", "connect"],
      "env": { "MCPR_TOKEN": "your_token" },
      "services": "all"
    }
  }
}
```

## 调用简报格式

每次调用MCP服务后附加：
```markdown
【MCP调用简报】
服务: Serena
操作: search_for_pattern
参数: pattern="TODO", paths="src/"
结果: 找到5个匹配
耗时: 120ms
状态: ✅ 成功
```

---
**模块类型**：服务配置
**适用场景**：需要使用外部服务时
**依赖**：根据具体服务而定