# 模块：代码审查标准与最佳实践

## 代码审查流程

### 审查前准备
```markdown
## PR 提交清单
- [ ] 代码已自测
- [ ] 单元测试已编写
- [ ] 测试全部通过
- [ ] 代码已格式化
- [ ] 无 lint 错误
- [ ] 文档已更新
- [ ] commit 信息清晰
```

### 审查优先级
```yaml
priority_levels:
  P0_blocking:     # 必须修复
    - 安全漏洞
    - 数据丢失风险
    - 性能严重退化
    - 破坏性变更

  P1_important:    # 应该修复
    - 逻辑错误
    - 代码质量问题
    - 测试缺失
    - 文档不全

  P2_suggested:    # 建议改进
    - 代码风格
    - 命名规范
    - 重构建议
    - 优化机会

  P3_nitpick:      # 细节问题
    - 拼写错误
    - 格式问题
    - 注释完善
```

## 审查维度

### 1. 功能正确性
```javascript
// 审查点：业务逻辑是否正确
// ❌ 问题代码
function calculateDiscount(price, customerType) {
  if (customerType === 'VIP') {
    return price * 0.8;  // 问题：未处理 price 为负数的情况
  }
  return price;
}

// ✅ 改进建议
function calculateDiscount(price, customerType) {
  if (price < 0) {
    throw new Error('Price cannot be negative');
  }

  const discounts = {
    'VIP': 0.2,
    'PREMIUM': 0.1,
    'REGULAR': 0
  };

  const discountRate = discounts[customerType] || 0;
  return price * (1 - discountRate);
}
```

### 2. 代码质量
```javascript
// 可读性检查
// ❌ 难以理解
function p(u, t) {
  return u.r === 'a' || (u.vip && t > 100);
}

// ✅ 清晰易读
function canAccessPremiumFeature(user, transactionAmount) {
  const isAdmin = user.role === 'admin';
  const isVipWithHighTransaction = user.isVip && transactionAmount > 100;

  return isAdmin || isVipWithHighTransaction;
}

// 复杂度检查
// ❌ 圈复杂度过高
function processOrder(order) {
  if (order) {
    if (order.items) {
      if (order.items.length > 0) {
        if (order.status === 'pending') {
          if (order.payment) {
            if (order.payment.verified) {
              // 处理订单
            }
          }
        }
      }
    }
  }
}

// ✅ 提前返回降低复杂度
function processOrder(order) {
  if (!order?.items?.length) {
    throw new Error('Invalid order');
  }

  if (order.status !== 'pending') {
    throw new Error('Order already processed');
  }

  if (!order.payment?.verified) {
    throw new Error('Payment not verified');
  }

  // 处理订单
}
```

### 3. 性能影响
```javascript
// 性能审查
// ❌ N+1 查询问题
async function getUsersWithPosts() {
  const users = await User.findAll();

  for (const user of users) {
    user.posts = await Post.findByUserId(user.id); // N+1 问题
  }

  return users;
}

// ✅ 使用联表查询
async function getUsersWithPosts() {
  return await User.findAll({
    include: [{
      model: Post,
      as: 'posts'
    }]
  });
}

// ❌ 不必要的计算
function Component({ data }) {
  // 每次渲染都重新计算
  const processedData = data.map(item => ({
    ...item,
    computed: heavyComputation(item)
  }));

  return <List data={processedData} />;
}

// ✅ 使用缓存
function Component({ data }) {
  const processedData = useMemo(
    () => data.map(item => ({
      ...item,
      computed: heavyComputation(item)
    })),
    [data]
  );

  return <List data={processedData} />;
}
```

### 4. 安全性
```javascript
// 安全审查重点
// ❌ SQL注入风险
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ 参数化查询
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [userId]);

// ❌ XSS风险
element.innerHTML = userInput;

// ✅ 安全处理
element.textContent = userInput;
// 或使用消毒库
element.innerHTML = DOMPurify.sanitize(userInput);
```

### 5. 可维护性
```javascript
// 可维护性检查
// ❌ 魔法数字
if (user.age > 18 && user.score > 60) {
  // ...
}

// ✅ 命名常量
const ADULT_AGE = 18;
const PASSING_SCORE = 60;

if (user.age > ADULT_AGE && user.score > PASSING_SCORE) {
  // ...
}

// ❌ 重复代码
function validateEmail(email) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}

function validateUserEmail(user) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(user.email);
}

// ✅ DRY原则
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function isValidEmail(email) {
  return EMAIL_REGEX.test(email);
}

function validateUserEmail(user) {
  return isValidEmail(user.email);
}
```

## 审查评论模板

### 建设性反馈
```markdown
## 问题指出
❌ "这代码写得太烂了"
✅ "这段代码可能存在性能问题，建议考虑使用缓存"

## 提供示例
❌ "这里不对"
✅ "这里可能存在 N+1 查询问题，建议改为：
\`\`\`javascript
// 示例代码
\`\`\`
"

## 解释原因
❌ "不要用 var"
✅ "建议使用 const/let 替代 var，因为 var 存在变量提升和作用域问题"
```

### 评论标记
```markdown
# 使用前缀标记评论类型

🚫 [BLOCKING]: 必须修复才能合并
⚠️ [WARNING]: 潜在问题，强烈建议修复
💡 [SUGGESTION]: 改进建议
❓ [QUESTION]: 需要澄清的问题
✅ [PRAISE]: 做得好的地方
📝 [NOTE]: 备注说明
🎨 [STYLE]: 代码风格问题
```

## 自动化审查工具

### ESLint 配置
```javascript
// .eslintrc.js
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react/recommended',
    'plugin:security/recommended'
  ],
  rules: {
    'complexity': ['error', 10],           // 圈复杂度
    'max-depth': ['error', 4],              // 最大嵌套深度
    'max-lines': ['error', 300],            // 文件最大行数
    'max-lines-per-function': ['error', 50], // 函数最大行数
    'max-params': ['error', 3],             // 最大参数数量
    'no-console': 'warn',
    'no-debugger': 'error',
    'no-unused-vars': 'error',
    'prefer-const': 'error'
  }
};
```

### Pre-commit Hooks
```json
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.{js,ts,tsx}": [
      "eslint --fix",
      "prettier --write",
      "jest --findRelatedTests"
    ],
    "*.{json,md}": [
      "prettier --write"
    ]
  }
}
```

### SonarQube 规则
```yaml
# sonar-project.properties
sonar.projectKey=my-project
sonar.sources=src
sonar.tests=tests
sonar.javascript.lcov.reportPaths=coverage/lcov.info

# 质量门禁
sonar.qualitygate.wait=true
```

## 代码度量标准

### 复杂度指标
```yaml
metrics:
  cyclomatic_complexity:
    good: < 5
    acceptable: 5-10
    needs_refactoring: > 10

  cognitive_complexity:
    good: < 7
    acceptable: 7-15
    needs_refactoring: > 15

  nesting_depth:
    good: < 3
    acceptable: 3-4
    needs_refactoring: > 4
```

### 质量指标
| 指标 | 优秀 | 良好 | 需改进 |
|------|------|------|--------|
| 代码覆盖率 | > 90% | 70-90% | < 70% |
| 重复率 | < 3% | 3-5% | > 5% |
| 技术债务比 | < 5% | 5-10% | > 10% |
| 代码异味密度 | < 5 | 5-10 | > 10 |

## 审查清单

### 通用检查项
```markdown
## 代码审查清单

### 功能性
- [ ] 功能是否正确实现
- [ ] 边界条件是否处理
- [ ] 错误处理是否完善
- [ ] 是否有遗漏的场景

### 可读性
- [ ] 命名是否清晰
- [ ] 逻辑是否易懂
- [ ] 注释是否充分
- [ ] 是否遵循团队规范

### 性能
- [ ] 是否有不必要的循环
- [ ] 是否有重复计算
- [ ] 数据库查询是否优化
- [ ] 是否有内存泄漏风险

### 安全性
- [ ] 输入是否验证
- [ ] 是否有注入风险
- [ ] 敏感信息是否保护
- [ ] 权限是否正确控制

### 测试
- [ ] 测试是否充分
- [ ] 测试是否有意义
- [ ] 边界条件是否覆盖
- [ ] 异常情况是否测试

### 文档
- [ ] README 是否更新
- [ ] API 文档是否完整
- [ ] 注释是否准确
- [ ] 变更日志是否记录
```

### 特定技术栈检查

#### React 审查
```markdown
- [ ] 组件是否合理拆分
- [ ] props 类型是否定义
- [ ] 是否有不必要的重渲染
- [ ] hooks 使用是否正确
- [ ] 依赖数组是否完整
```

#### Node.js 审查
```markdown
- [ ] 异步错误是否处理
- [ ] 是否有回调地狱
- [ ] 流是否正确关闭
- [ ] 中间件顺序是否正确
- [ ] 环境变量是否使用
```

## 审查报告模板

```markdown
# 代码审查报告

## 基本信息
- **PR #**: 123
- **作者**: @developer
- **审查者**: @reviewer
- **日期**: 2024-11-08

## 总体评价
⭐⭐⭐⭐☆ (4/5)

## 优点
- ✅ 测试覆盖充分
- ✅ 代码结构清晰
- ✅ 文档更新及时

## 必须修复 (Blocking)
1. 🚫 SQL注入风险 (line 45)
2. 🚫 缺少错误处理 (line 78)

## 建议改进 (Non-blocking)
1. 💡 可以使用缓存优化性能
2. 💡 建议提取公共逻辑

## 问题讨论
1. ❓ 为什么选择这个算法？
2. ❓ 是否考虑过并发情况？

## 最终意见
**需要修改** - 修复安全问题后可以合并
```

## 审查文化建设

### 最佳实践
1. **及时审查**：24小时内响应
2. **小批量**：PR 不超过 400 行
3. **专注重点**：优先关注逻辑和安全
4. **建设性**：提供解决方案
5. **学习机会**：分享知识和经验

### 团队约定
```markdown
## 代码审查约定

1. 每个 PR 至少需要 1 个审查者
2. 关键模块需要 2 个审查者
3. 自己不能批准自己的 PR
4. 有阻塞问题必须修复
5. 非阻塞问题可以创建 issue 后续处理
```

---
**模块类型**：质量保证
**适用场景**：PR审查、代码质量评估、团队协作
**配合模块**：principles, testing, security