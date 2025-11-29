# 模块：编程原则指南

## 一、核心设计原则

### KISS - 保持简单原则
**定义**：软件设计应该尽可能简单，避免不必要的复杂性

**实践对比**：
```javascript
// ❌ 过度复杂
class UserValidator {
  validate(user) {
    return this.validationChain
      .pipe(this.rules.get(user.type))
      .aggregate(this.errorAggregator)
      .transform(new ResultTransformer())
      .execute(user);
  }
}

// ✅ 简单直接
class UserValidator {
  validate(user) {
    const errors = [];
    if (!user.email?.includes('@')) errors.push('Invalid email');
    if (!user.name || user.name.length < 2) errors.push('Name too short');
    return { isValid: errors.length === 0, errors };
  }
}
```

### YAGNI - 你不会需要它
**定义**：不要添加当前不需要的功能

**实践对比**：
```javascript
// ❌ 为未来预留太多
class UserService {
  async loginWithEmail(email, password) {}
  async loginWithPhone(phone, code) {}      // 未来可能
  async loginWithOAuth(provider, token) {}  // 未来可能
  async loginWithBiometric(data) {}         // 未来可能
}

// ✅ 只实现当前需要的
class UserService {
  async login(email, password) {
    // 只实现当前需要的邮箱登录
  }
}
```

### DRY - 不要重复自己
**定义**：每一项知识都必须具有单一、无歧义、权威的表示

**实践对比**：
```javascript
// ❌ 重复的验证逻辑
class UserController {
  createUser(data) {
    if (!data.email?.includes('@')) throw new Error('Invalid email');
    if (data.password?.length < 8) throw new Error('Password too short');
  }
  updateUser(data) {
    if (!data.email?.includes('@')) throw new Error('Invalid email');
    if (data.password?.length < 8) throw new Error('Password too short');
  }
}

// ✅ 提取公共逻辑
class UserController {
  validate(data) {
    if (!data.email?.includes('@')) throw new Error('Invalid email');
    if (data.password?.length < 8) throw new Error('Password too short');
  }
  createUser(data) {
    this.validate(data);
  }
  updateUser(data) {
    this.validate(data);
  }
}
```

## 二、SOLID原则

### S - 单一职责原则 (SRP)
**定义**：一个类应该只有一个引起它变化的原因

```typescript
// ❌ 违反SRP：多个职责
class Employee {
  getName() {}           // 职责1：员工信息
  calculatePay() {}      // 职责2：薪资计算
  saveToDatabase() {}    // 职责3：数据持久化
  generateReport() {}    // 职责4：报表生成
}

// ✅ 遵循SRP：单一职责
class Employee {
  getName() {}
}
class PayrollCalculator {
  calculate(employee) {}
}
class EmployeeRepository {
  save(employee) {}
}
class ReportGenerator {
  generate(employee) {}
}
```

### O - 开闭原则 (OCP)
**定义**：对扩展开放，对修改关闭

```typescript
// ❌ 违反OCP：添加新类型需要修改代码
class DiscountCalculator {
  calculate(price, type) {
    if (type === 'student') return price * 0.8;
    if (type === 'senior') return price * 0.7;
    // 添加新类型需要修改此方法
  }
}

// ✅ 遵循OCP：通过扩展添加新功能
interface DiscountStrategy {
  calculate(price: number): number;
}

class StudentDiscount implements DiscountStrategy {
  calculate(price) { return price * 0.8; }
}

class SeniorDiscount implements DiscountStrategy {
  calculate(price) { return price * 0.7; }
}

class DiscountCalculator {
  constructor(private strategy: DiscountStrategy) {}
  calculate(price) { return this.strategy.calculate(price); }
}
```

### L - 里氏替换原则 (LSP)
**定义**：子类必须能够替换其基类

```typescript
// ❌ 违反LSP：Square改变了Rectangle的行为
class Rectangle {
  setWidth(w) { this.width = w; }
  setHeight(h) { this.height = h; }
}

class Square extends Rectangle {
  setWidth(w) {
    this.width = w;
    this.height = w;  // 破坏了Rectangle的契约
  }
}

// ✅ 遵循LSP：使用接口而非继承
interface Shape {
  getArea(): number;
}

class Rectangle implements Shape {
  constructor(private width: number, private height: number) {}
  getArea() { return this.width * this.height; }
}

class Square implements Shape {
  constructor(private side: number) {}
  getArea() { return this.side * this.side; }
}
```

### I - 接口隔离原则 (ISP)
**定义**：客户端不应该被迫依赖它们不使用的接口

```typescript
// ❌ 违反ISP：胖接口
interface Employee {
  work(): void;
  getSalary(): number;
  manageTeam(): void;    // 不是所有员工都需要
  conductReview(): void;  // 不是所有员工都需要
}

// ✅ 遵循ISP：细粒度接口
interface Worker {
  work(): void;
}
interface Payable {
  getSalary(): number;
}
interface Manager {
  manageTeam(): void;
  conductReview(): void;
}

class Developer implements Worker, Payable {
  work() {}
  getSalary() {}
}

class TeamLead implements Worker, Payable, Manager {
  work() {}
  getSalary() {}
  manageTeam() {}
  conductReview() {}
}
```

### D - 依赖倒置原则 (DIP)
**定义**：依赖抽象而非具体实现

```typescript
// ❌ 违反DIP：直接依赖具体类
class NotificationService {
  constructor() {
    this.emailSender = new EmailSender();  // 依赖具体实现
  }
}

// ✅ 遵循DIP：依赖抽象
interface MessageSender {
  send(message: string): void;
}

class EmailSender implements MessageSender {
  send(message) { /* 发送邮件 */ }
}

class SMSSender implements MessageSender {
  send(message) { /* 发送短信 */ }
}

class NotificationService {
  constructor(private sender: MessageSender) {}  // 依赖抽象
  notify(message) { this.sender.send(message); }
}
```

## 三、测试驱动开发（TDD）

### TDD核心循环

```typescript
// 1. 红灯：写失败的测试
test('should add two numbers', () => {
  expect(add(2, 3)).toBe(5);  // add函数还不存在
});

// 2. 绿灯：最小实现
function add(a, b) {
  return a + b;
}

// 3. 重构：优化代码
function add(...numbers) {
  return numbers.reduce((sum, n) => sum + n, 0);
}
```

### 测试最佳实践

**AAA模式**：
```typescript
test('should calculate discount', () => {
  // Arrange - 准备
  const price = 100;
  const discountRate = 0.1;

  // Act - 执行
  const result = calculateDiscount(price, discountRate);

  // Assert - 断言
  expect(result).toBe(90);
});
```

**测试金字塔**：
```
      /\
     /  \    E2E测试 (10%)
    /----\   集成测试 (20%)
   /------\  单元测试 (70%)
```

## 四、代码异味

### 常见代码异味
1. **长函数** - 超过20行
2. **大类** - 超过200行
3. **长参数列表** - 超过3个参数
4. **重复代码** - 相似代码出现3次以上
5. **散弹式修改** - 一个改动影响多处

### 重构示例
```javascript
// ❌ 长方法
function processOrder(order) {
  // 验证
  if (!order.id) throw new Error('...');
  if (!order.items) throw new Error('...');

  // 计算
  let total = 0;
  for (const item of order.items) {
    total += item.price * item.quantity;
  }

  // 保存
  database.save(order);

  // 通知
  emailService.send(order.customer.email, '...');

  return total;
}

// ✅ 提取方法
class OrderProcessor {
  process(order) {
    this.validate(order);
    const total = this.calculateTotal(order);
    this.save(order);
    this.notify(order);
    return total;
  }

  private validate(order) { /* ... */ }
  private calculateTotal(order) { /* ... */ }
  private save(order) { /* ... */ }
  private notify(order) { /* ... */ }
}
```

## 五、原则检查清单

### KISS/YAGNI/DRY
- [ ] 代码是否简单易懂？
- [ ] 是否存在未使用的功能？
- [ ] 是否有重复代码？

### SOLID原则
- [ ] 每个类是否只有单一职责？
- [ ] 添加新功能是否需要修改现有代码？
- [ ] 子类能否正确替换父类？
- [ ] 接口是否精简？
- [ ] 是否依赖抽象而非具体？

### 测试质量
- [ ] 是否先写测试？
- [ ] 测试覆盖率是否达标？
- [ ] 测试是否独立可重复？

### 代码质量
- [ ] 函数是否过长？
- [ ] 类是否过大？
- [ ] 是否存在代码异味？

## 六、实践建议

### 应用优先级
1. **最重要**：KISS、DRY、SRP
2. **重要**：YAGNI、OCP、DIP
3. **进阶**：LSP、ISP、TDD

### 渐进式改进
- 新代码：严格遵循所有原则
- 旧代码：逐步重构，优先处理高风险部分
- 团队协作：建立代码审查机制

### 平衡取舍
- 简单性 vs 灵活性
- 当前需求 vs 未来扩展
- 开发速度 vs 代码质量

---
**模块类型**：原则指导
**适用场景**：代码审查、重构、架构设计
**配合模块**：testing, code-review, workflow
**版本**：v2.1 - 精简版