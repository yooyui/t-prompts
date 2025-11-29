# 模块：编程原则完整版

## 一、核心设计原则

### KISS (Keep It Simple, Stupid) - 保持简单原则

**定义**：软件设计应该尽可能简单，避免不必要的复杂性。

**实践指南**：
```javascript
// ❌ 过度复杂
class UserValidator {
  private validationRules: Map<string, ValidationRule[]>;
  private validationChain: ValidationChain;
  private errorAggregator: ErrorAggregator;

  validate(user: User): ValidationResult {
    return this.validationChain
      .pipe(this.validationRules.get(user.type))
      .aggregate(this.errorAggregator)
      .transform(new ResultTransformer())
      .execute(user);
  }
}

// ✅ 简单直接
class UserValidator {
  validate(user: User): ValidationResult {
    const errors = [];

    if (!user.email || !user.email.includes('@')) {
      errors.push('Invalid email');
    }

    if (!user.name || user.name.length < 2) {
      errors.push('Name too short');
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }
}
```

**检查清单**：
- [ ] 新手能在5分钟内理解这段代码吗？
- [ ] 能用更少的代码实现相同功能吗？
- [ ] 是否存在不必要的抽象层？
- [ ] 调试时能快速定位问题吗？

### YAGNI (You Aren't Gonna Need It) - 你不会需要它

**定义**：不要添加当前不需要的功能，即使你认为将来可能需要。

**实践指南**：
```javascript
// ❌ 违反 YAGNI：为未来预留太多
class UserService {
  // 当前只需要邮箱登录
  async loginWithEmail(email: string, password: string) {}

  // 这些都是"可能将来会用"的功能
  async loginWithPhone(phone: string, code: string) {}
  async loginWithOAuth(provider: string, token: string) {}
  async loginWithFingerprint(data: BiometricData) {}
  async loginWithFaceID(data: FaceData) {}
  async loginWithQRCode(code: string) {}
}

// ✅ 遵循 YAGNI：只实现当前需要的
class UserService {
  async login(email: string, password: string) {
    // 只实现当前需要的邮箱登录
  }
}

// 将来需要时再添加：
// class OAuthService { ... }
// class BiometricAuthService { ... }
```

**应用时机**：
- 产品需求不明确时
- MVP开发阶段
- 迭代开发过程中
- 重构遗留代码时

### DRY (Don't Repeat Yourself) - 不要重复自己

**定义**：系统中的每一项知识都必须具有单一、无歧义、权威的表示。

**实践指南**：
```javascript
// ❌ 违反 DRY：重复的验证逻辑
class UserController {
  createUser(data) {
    if (!data.email || !data.email.includes('@')) {
      throw new Error('Invalid email');
    }
    if (!data.password || data.password.length < 8) {
      throw new Error('Password too short');
    }
    // 创建用户...
  }

  updateUser(data) {
    if (!data.email || !data.email.includes('@')) {
      throw new Error('Invalid email');
    }
    if (!data.password || data.password.length < 8) {
      throw new Error('Password too short');
    }
    // 更新用户...
  }
}

// ✅ 遵循 DRY：提取公共逻辑
class ValidationRules {
  static email(value: string) {
    if (!value || !value.includes('@')) {
      throw new Error('Invalid email');
    }
  }

  static password(value: string) {
    if (!value || value.length < 8) {
      throw new Error('Password too short');
    }
  }
}

class UserController {
  private validate(data) {
    ValidationRules.email(data.email);
    ValidationRules.password(data.password);
  }

  createUser(data) {
    this.validate(data);
    // 创建用户...
  }

  updateUser(data) {
    this.validate(data);
    // 更新用户...
  }
}
```

**DRY的三个层次**：
1. **代码级别**：避免复制粘贴
2. **知识级别**：单一数据源
3. **流程级别**：统一业务流程

## 二、SOLID原则完整实践

### 单一职责原则 (SRP) - Single Responsibility Principle

**定义**：一个类应该只有一个引起它变化的原因。

**深度实践**：
```typescript
// ❌ 违反SRP：Employee类承担了太多职责
class Employee {
  constructor(
    private name: string,
    private salary: number
  ) {}

  // 职责1：员工信息管理
  getName() { return this.name; }
  setName(name: string) { this.name = name; }

  // 职责2：薪资计算
  calculatePay() {
    return this.salary * this.getWorkHours();
  }

  // 职责3：工时统计
  getWorkHours() {
    // 从考勤系统获取工时
  }

  // 职责4：数据持久化
  save() {
    database.save(this);
  }

  // 职责5：报表生成
  generateReport() {
    return `Employee Report for ${this.name}`;
  }
}

// ✅ 遵循SRP：每个类只有单一职责
class Employee {
  constructor(
    private name: string,
    private id: string
  ) {}

  getName() { return this.name; }
  getId() { return this.id; }
}

class PayrollCalculator {
  calculate(employee: Employee, hours: number, rate: number) {
    return hours * rate;
  }
}

class TimeTracker {
  getWorkHours(employeeId: string): number {
    // 从考勤系统获取工时
  }
}

class EmployeeRepository {
  save(employee: Employee) {
    database.save(employee);
  }

  findById(id: string): Employee {
    return database.find(id);
  }
}

class ReportGenerator {
  generateEmployeeReport(employee: Employee, payroll: number) {
    return `Report for ${employee.getName()}: $${payroll}`;
  }
}
```

### 开闭原则 (OCP) - Open/Closed Principle

**定义**：软件实体应该对扩展开放，对修改关闭。

**深度实践**：
```typescript
// ❌ 违反OCP：添加新的折扣类型需要修改现有代码
class DiscountCalculator {
  calculate(price: number, type: string): number {
    if (type === 'student') {
      return price * 0.8;
    } else if (type === 'senior') {
      return price * 0.7;
    } else if (type === 'vip') {
      return price * 0.6;
    } else if (type === 'employee') {  // 需要修改这个方法添加新类型
      return price * 0.5;
    }
    return price;
  }
}

// ✅ 遵循OCP：通过策略模式实现扩展
interface DiscountStrategy {
  calculate(price: number): number;
}

class StudentDiscount implements DiscountStrategy {
  calculate(price: number): number {
    return price * 0.8;
  }
}

class SeniorDiscount implements DiscountStrategy {
  calculate(price: number): number {
    return price * 0.7;
  }
}

class VIPDiscount implements DiscountStrategy {
  calculate(price: number): number {
    return price * 0.6;
  }
}

// 添加新的折扣类型无需修改现有代码
class EmployeeDiscount implements DiscountStrategy {
  calculate(price: number): number {
    return price * 0.5;
  }
}

class DiscountCalculator {
  constructor(private strategy: DiscountStrategy) {}

  calculate(price: number): number {
    return this.strategy.calculate(price);
  }
}

// 使用
const calculator = new DiscountCalculator(new StudentDiscount());
const finalPrice = calculator.calculate(100);  // 80
```

### 里氏替换原则 (LSP) - Liskov Substitution Principle

**定义**：派生类必须能够替换其基类而不影响程序的正确性。

**深度实践**：
```typescript
// ❌ 违反LSP：Square改变了Rectangle的行为契约
class Rectangle {
  constructor(
    protected width: number,
    protected height: number
  ) {}

  setWidth(width: number) {
    this.width = width;
  }

  setHeight(height: number) {
    this.height = height;
  }

  getArea(): number {
    return this.width * this.height;
  }
}

class Square extends Rectangle {
  constructor(side: number) {
    super(side, side);
  }

  // 违反LSP：改变了父类的行为契约
  setWidth(width: number) {
    this.width = width;
    this.height = width;  // 强制保持正方形
  }

  setHeight(height: number) {
    this.width = height;
    this.height = height;  // 强制保持正方形
  }
}

// 使用时会出现问题
function testRectangle(rect: Rectangle) {
  rect.setWidth(5);
  rect.setHeight(4);
  console.assert(rect.getArea() === 20);  // Square会失败！
}

// ✅ 遵循LSP：重新设计继承关系
interface Shape {
  getArea(): number;
}

class Rectangle implements Shape {
  constructor(
    private width: number,
    private height: number
  ) {}

  getArea(): number {
    return this.width * this.height;
  }
}

class Square implements Shape {
  constructor(private side: number) {}

  getArea(): number {
    return this.side * this.side;
  }
}

// 或者使用更好的设计
abstract class Shape {
  abstract getArea(): number;
  abstract getPerimeter(): number;
}

class Rectangle extends Shape {
  constructor(
    private readonly width: number,
    private readonly height: number
  ) {
    super();
  }

  getArea(): number {
    return this.width * this.height;
  }

  getPerimeter(): number {
    return 2 * (this.width + this.height);
  }
}

class Square extends Shape {
  constructor(private readonly side: number) {
    super();
  }

  getArea(): number {
    return this.side * this.side;
  }

  getPerimeter(): number {
    return 4 * this.side;
  }
}
```

### 接口隔离原则 (ISP) - Interface Segregation Principle

**定义**：客户端不应该被迫依赖它们不使用的接口。

**深度实践**：
```typescript
// ❌ 违反ISP：臃肿的接口
interface Employee {
  // 工作相关
  work(): void;
  getProjects(): Project[];
  submitTimesheet(): void;

  // 薪资相关
  getSalary(): number;
  requestRaise(): void;

  // 管理相关
  manageTeam(): void;
  conductReview(): void;
  approveExpenses(): void;

  // 个人信息
  getName(): string;
  getAddress(): string;
  updateProfile(): void;
}

// 问题：开发者不需要管理功能，但被迫实现
class Developer implements Employee {
  work() { /* 编码 */ }
  getProjects() { /* 返回项目 */ }
  submitTimesheet() { /* 提交工时 */ }
  getSalary() { /* 获取薪资 */ }
  requestRaise() { /* 申请加薪 */ }

  // 被迫实现不需要的方法
  manageTeam() {
    throw new Error('Developers do not manage teams');
  }
  conductReview() {
    throw new Error('Developers do not conduct reviews');
  }
  approveExpenses() {
    throw new Error('Developers cannot approve expenses');
  }

  getName() { /* 返回姓名 */ }
  getAddress() { /* 返回地址 */ }
  updateProfile() { /* 更新资料 */ }
}

// ✅ 遵循ISP：细分接口
interface Worker {
  work(): void;
  getProjects(): Project[];
  submitTimesheet(): void;
}

interface Payable {
  getSalary(): number;
  requestRaise(): void;
}

interface Manager {
  manageTeam(): void;
  conductReview(): void;
  approveExpenses(): void;
}

interface Person {
  getName(): string;
  getAddress(): string;
  updateProfile(): void;
}

// 开发者只实现需要的接口
class Developer implements Worker, Payable, Person {
  work() { /* 编码 */ }
  getProjects() { /* 返回项目 */ }
  submitTimesheet() { /* 提交工时 */ }
  getSalary() { /* 获取薪资 */ }
  requestRaise() { /* 申请加薪 */ }
  getName() { /* 返回姓名 */ }
  getAddress() { /* 返回地址 */ }
  updateProfile() { /* 更新资料 */ }
}

// 经理实现所有接口
class Manager implements Worker, Payable, Manager, Person {
  // 实现所有接口的方法...
}
```

### 依赖倒置原则 (DIP) - Dependency Inversion Principle

**定义**：
1. 高层模块不应该依赖低层模块，两者都应该依赖抽象
2. 抽象不应该依赖细节，细节应该依赖抽象

**深度实践**：
```typescript
// ❌ 违反DIP：高层模块直接依赖低层模块
class EmailSender {
  send(message: string) {
    // 使用SMTP发送邮件
    console.log(`Sending email: ${message}`);
  }
}

class SMSSender {
  send(message: string) {
    // 使用SMS网关发送短信
    console.log(`Sending SMS: ${message}`);
  }
}

// 高层模块直接依赖具体实现
class NotificationService {
  private emailSender: EmailSender;
  private smsSender: SMSSender;

  constructor() {
    this.emailSender = new EmailSender();  // 直接依赖具体类
    this.smsSender = new SMSSender();      // 直接依赖具体类
  }

  notify(message: string, type: string) {
    if (type === 'email') {
      this.emailSender.send(message);
    } else if (type === 'sms') {
      this.smsSender.send(message);
    }
  }
}

// ✅ 遵循DIP：依赖抽象而非具体
interface MessageSender {
  send(message: string): Promise<void>;
}

class EmailSender implements MessageSender {
  async send(message: string): Promise<void> {
    // 实现邮件发送
    console.log(`Email: ${message}`);
  }
}

class SMSSender implements MessageSender {
  async send(message: string): Promise<void> {
    // 实现短信发送
    console.log(`SMS: ${message}`);
  }
}

// 新增推送通知，无需修改NotificationService
class PushNotificationSender implements MessageSender {
  async send(message: string): Promise<void> {
    // 实现推送通知
    console.log(`Push: ${message}`);
  }
}

// 高层模块依赖抽象
class NotificationService {
  constructor(
    private readonly senders: Map<string, MessageSender>  // 依赖抽象
  ) {}

  async notify(message: string, channels: string[]): Promise<void> {
    const promises = channels.map(channel => {
      const sender = this.senders.get(channel);
      if (sender) {
        return sender.send(message);
      }
      return Promise.reject(`Unknown channel: ${channel}`);
    });

    await Promise.all(promises);
  }
}

// 依赖注入
const senders = new Map<string, MessageSender>([
  ['email', new EmailSender()],
  ['sms', new SMSSender()],
  ['push', new PushNotificationSender()]
]);

const notificationService = new NotificationService(senders);
```

## 三、测试驱动开发（TDD）完整实践

### TDD核心循环

#### 第一步：红灯（编写失败的测试）
```typescript
// calculator.test.ts
describe('Calculator', () => {
  describe('add', () => {
    it('should add two positive numbers', () => {
      const calculator = new Calculator();
      expect(calculator.add(2, 3)).toBe(5);
    });

    it('should handle negative numbers', () => {
      const calculator = new Calculator();
      expect(calculator.add(-1, -1)).toBe(-2);
    });

    it('should handle zero', () => {
      const calculator = new Calculator();
      expect(calculator.add(0, 5)).toBe(5);
    });

    it('should throw error for non-numbers', () => {
      const calculator = new Calculator();
      expect(() => calculator.add('2', 3)).toThrow('Invalid input');
    });
  });

  describe('divide', () => {
    it('should divide two numbers', () => {
      const calculator = new Calculator();
      expect(calculator.divide(10, 2)).toBe(5);
    });

    it('should throw error when dividing by zero', () => {
      const calculator = new Calculator();
      expect(() => calculator.divide(10, 0)).toThrow('Division by zero');
    });

    it('should handle decimals', () => {
      const calculator = new Calculator();
      expect(calculator.divide(1, 3)).toBeCloseTo(0.333, 3);
    });
  });
});
```

#### 第二步：绿灯（编写最小代码通过测试）
```typescript
// calculator.ts (最小实现)
class Calculator {
  add(a: any, b: any): number {
    if (typeof a !== 'number' || typeof b !== 'number') {
      throw new Error('Invalid input');
    }
    return a + b;
  }

  divide(a: number, b: number): number {
    if (b === 0) {
      throw new Error('Division by zero');
    }
    return a / b;
  }
}
```

#### 第三步：重构（改进代码保持测试通过）
```typescript
// calculator.ts (重构后)
class Calculator {
  private validateNumbers(...args: any[]): void {
    args.forEach(arg => {
      if (typeof arg !== 'number' || !isFinite(arg)) {
        throw new InvalidInputError(`Invalid input: ${arg}`);
      }
    });
  }

  add(...numbers: number[]): number {
    this.validateNumbers(...numbers);
    return numbers.reduce((sum, num) => sum + num, 0);
  }

  subtract(a: number, b: number): number {
    this.validateNumbers(a, b);
    return a - b;
  }

  multiply(...numbers: number[]): number {
    this.validateNumbers(...numbers);
    return numbers.reduce((product, num) => product * num, 1);
  }

  divide(dividend: number, divisor: number): number {
    this.validateNumbers(dividend, divisor);

    if (divisor === 0) {
      throw new DivisionByZeroError();
    }

    return dividend / divisor;
  }
}

// 自定义错误类
class InvalidInputError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'InvalidInputError';
  }
}

class DivisionByZeroError extends Error {
  constructor() {
    super('Cannot divide by zero');
    this.name = 'DivisionByZeroError';
  }
}
```

### TDD最佳实践

#### 1. 测试命名规范
```typescript
describe('UserService', () => {
  // 使用嵌套describe组织测试
  describe('register', () => {
    // should + 期望行为 + when + 条件
    it('should create new user when email is unique', async () => {
      // ...
    });

    it('should throw ConflictError when email already exists', async () => {
      // ...
    });

    it('should send welcome email when registration succeeds', async () => {
      // ...
    });

    it('should rollback transaction when email sending fails', async () => {
      // ...
    });
  });
});
```

#### 2. AAA模式（Arrange-Act-Assert）
```typescript
it('should calculate total with discount', () => {
  // Arrange（准备）
  const items = [
    { price: 100, quantity: 2 },
    { price: 50, quantity: 3 }
  ];
  const discountRate = 0.1;
  const calculator = new PriceCalculator();

  // Act（执行）
  const total = calculator.calculateTotal(items, discountRate);

  // Assert（断言）
  expect(total).toBe(315);  // (200 + 150) * 0.9
});
```

#### 3. 测试替身（Test Doubles）
```typescript
describe('OrderService', () => {
  let orderService: OrderService;
  let mockPaymentGateway: jest.Mocked<PaymentGateway>;
  let mockInventory: jest.Mocked<Inventory>;
  let mockEmailService: jest.Mocked<EmailService>;

  beforeEach(() => {
    // 创建模拟对象
    mockPaymentGateway = {
      charge: jest.fn(),
      refund: jest.fn()
    };

    mockInventory = {
      checkAvailability: jest.fn(),
      reserve: jest.fn(),
      release: jest.fn()
    };

    mockEmailService = {
      sendOrderConfirmation: jest.fn()
    };

    orderService = new OrderService(
      mockPaymentGateway,
      mockInventory,
      mockEmailService
    );
  });

  it('should process order successfully', async () => {
    // Arrange
    const order = {
      items: [{ productId: '123', quantity: 2 }],
      total: 100,
      customerId: 'customer-1'
    };

    mockInventory.checkAvailability.mockResolvedValue(true);
    mockInventory.reserve.mockResolvedValue(true);
    mockPaymentGateway.charge.mockResolvedValue({
      transactionId: 'txn-123',
      status: 'success'
    });

    // Act
    const result = await orderService.processOrder(order);

    // Assert
    expect(result.status).toBe('confirmed');
    expect(mockInventory.checkAvailability).toHaveBeenCalledWith('123', 2);
    expect(mockInventory.reserve).toHaveBeenCalledWith('123', 2);
    expect(mockPaymentGateway.charge).toHaveBeenCalledWith(100, 'customer-1');
    expect(mockEmailService.sendOrderConfirmation).toHaveBeenCalled();
  });

  it('should rollback when payment fails', async () => {
    // Arrange
    mockInventory.checkAvailability.mockResolvedValue(true);
    mockInventory.reserve.mockResolvedValue(true);
    mockPaymentGateway.charge.mockRejectedValue(new Error('Payment failed'));

    // Act & Assert
    await expect(orderService.processOrder(order))
      .rejects
      .toThrow('Payment failed');

    // Verify rollback
    expect(mockInventory.release).toHaveBeenCalledWith('123', 2);
    expect(mockEmailService.sendOrderConfirmation).not.toHaveBeenCalled();
  });
});
```

## 四、代码异味（Code Smells）详解

### 常见代码异味及重构方法

#### 1. 长方法（Long Method）
```typescript
// ❌ 代码异味：方法太长
function processOrder(order: Order) {
  // 验证订单
  if (!order.id) {
    throw new Error('Order ID required');
  }
  if (!order.items || order.items.length === 0) {
    throw new Error('Order must have items');
  }
  if (!order.customer) {
    throw new Error('Customer required');
  }

  // 计算总价
  let subtotal = 0;
  for (const item of order.items) {
    subtotal += item.price * item.quantity;
  }

  // 应用折扣
  let discount = 0;
  if (order.customer.type === 'vip') {
    discount = subtotal * 0.2;
  } else if (order.customer.type === 'regular') {
    discount = subtotal * 0.1;
  }

  // 计算税费
  const taxRate = 0.1;
  const tax = (subtotal - discount) * taxRate;

  // 计算运费
  let shipping = 0;
  if (subtotal < 100) {
    shipping = 10;
  }

  // 计算最终价格
  const total = subtotal - discount + tax + shipping;

  // 保存订单
  database.save({
    ...order,
    subtotal,
    discount,
    tax,
    shipping,
    total,
    status: 'processed',
    processedAt: new Date()
  });

  // 发送邮件
  emailService.send(
    order.customer.email,
    'Order Confirmation',
    `Your order ${order.id} has been processed. Total: ${total}`
  );

  return total;
}

// ✅ 重构：提取方法
class OrderProcessor {
  process(order: Order): ProcessedOrder {
    this.validateOrder(order);

    const pricing = this.calculatePricing(order);
    const processedOrder = this.createProcessedOrder(order, pricing);

    this.saveOrder(processedOrder);
    this.notifyCustomer(processedOrder);

    return processedOrder;
  }

  private validateOrder(order: Order): void {
    if (!order.id) throw new Error('Order ID required');
    if (!order.items?.length) throw new Error('Order must have items');
    if (!order.customer) throw new Error('Customer required');
  }

  private calculatePricing(order: Order): Pricing {
    const subtotal = this.calculateSubtotal(order.items);
    const discount = this.calculateDiscount(subtotal, order.customer);
    const tax = this.calculateTax(subtotal - discount);
    const shipping = this.calculateShipping(subtotal);
    const total = subtotal - discount + tax + shipping;

    return { subtotal, discount, tax, shipping, total };
  }

  private calculateSubtotal(items: OrderItem[]): number {
    return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  }

  private calculateDiscount(subtotal: number, customer: Customer): number {
    const discountRates = {
      vip: 0.2,
      regular: 0.1,
      new: 0
    };
    return subtotal * (discountRates[customer.type] || 0);
  }

  private calculateTax(amount: number): number {
    const TAX_RATE = 0.1;
    return amount * TAX_RATE;
  }

  private calculateShipping(subtotal: number): number {
    const FREE_SHIPPING_THRESHOLD = 100;
    const STANDARD_SHIPPING = 10;
    return subtotal >= FREE_SHIPPING_THRESHOLD ? 0 : STANDARD_SHIPPING;
  }
}
```

#### 2. 重复代码（Duplicated Code）
```typescript
// ❌ 代码异味：重复的验证逻辑
class UserController {
  async createUser(req: Request) {
    // 重复的验证逻辑
    if (!req.body.email) {
      return { error: 'Email is required' };
    }
    if (!req.body.email.includes('@')) {
      return { error: 'Invalid email format' };
    }
    if (!req.body.password) {
      return { error: 'Password is required' };
    }
    if (req.body.password.length < 8) {
      return { error: 'Password too short' };
    }
    // 创建用户...
  }

  async updateUser(req: Request) {
    // 重复的验证逻辑
    if (!req.body.email) {
      return { error: 'Email is required' };
    }
    if (!req.body.email.includes('@')) {
      return { error: 'Invalid email format' };
    }
    if (!req.body.password) {
      return { error: 'Password is required' };
    }
    if (req.body.password.length < 8) {
      return { error: 'Password too short' };
    }
    // 更新用户...
  }
}

// ✅ 重构：提取验证器
class Validator {
  static rules = {
    email: [
      { test: (v: any) => !!v, message: 'Email is required' },
      { test: (v: string) => v.includes('@'), message: 'Invalid email format' }
    ],
    password: [
      { test: (v: any) => !!v, message: 'Password is required' },
      { test: (v: string) => v.length >= 8, message: 'Password too short' }
    ]
  };

  static validate(data: any, fields: string[]): ValidationResult {
    const errors: string[] = [];

    for (const field of fields) {
      const rules = this.rules[field];
      const value = data[field];

      for (const rule of rules) {
        if (!rule.test(value)) {
          errors.push(rule.message);
          break;
        }
      }
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }
}

class UserController {
  async createUser(req: Request) {
    const validation = Validator.validate(req.body, ['email', 'password']);
    if (!validation.isValid) {
      return { errors: validation.errors };
    }
    // 创建用户...
  }

  async updateUser(req: Request) {
    const validation = Validator.validate(req.body, ['email', 'password']);
    if (!validation.isValid) {
      return { errors: validation.errors };
    }
    // 更新用户...
  }
}
```

## 五、综合实践示例

### 完整的用户注册功能（应用所有原则）

```typescript
// ========== 领域模型 ==========
// 应用SRP：每个类一个职责
class User {
  constructor(
    public readonly id: string,
    public readonly email: Email,
    public readonly hashedPassword: string,
    public readonly createdAt: Date
  ) {}
}

class Email {
  constructor(private readonly value: string) {
    if (!this.isValid(value)) {
      throw new InvalidEmailError(value);
    }
  }

  private isValid(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  toString(): string {
    return this.value;
  }
}

// ========== 应用层接口（依赖倒置）==========
interface UserRepository {
  save(user: User): Promise<User>;
  findByEmail(email: Email): Promise<User | null>;
}

interface PasswordHasher {
  hash(password: string): Promise<string>;
  verify(password: string, hash: string): Promise<boolean>;
}

interface EmailService {
  sendWelcomeEmail(email: Email, name: string): Promise<void>;
}

interface IdGenerator {
  generate(): string;
}

// ========== 应用服务 ==========
class UserRegistrationService {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly passwordHasher: PasswordHasher,
    private readonly emailService: EmailService,
    private readonly idGenerator: IdGenerator
  ) {}

  async register(command: RegisterUserCommand): Promise<User> {
    // 验证邮箱唯一性
    const email = new Email(command.email);
    const existingUser = await this.userRepository.findByEmail(email);

    if (existingUser) {
      throw new EmailAlreadyExistsError(email.toString());
    }

    // 创建用户
    const hashedPassword = await this.passwordHasher.hash(command.password);
    const user = new User(
      this.idGenerator.generate(),
      email,
      hashedPassword,
      new Date()
    );

    // 保存用户
    const savedUser = await this.userRepository.save(user);

    // 发送欢迎邮件（异步，不影响注册流程）
    this.sendWelcomeEmailAsync(email, command.name);

    return savedUser;
  }

  private async sendWelcomeEmailAsync(email: Email, name: string): Promise<void> {
    try {
      await this.emailService.sendWelcomeEmail(email, name);
    } catch (error) {
      // 记录错误但不影响注册
      console.error('Failed to send welcome email:', error);
    }
  }
}

// ========== 基础设施实现 ==========
class PostgresUserRepository implements UserRepository {
  constructor(private readonly db: Database) {}

  async save(user: User): Promise<User> {
    const query = `
      INSERT INTO users (id, email, password, created_at)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `;

    const result = await this.db.query(query, [
      user.id,
      user.email.toString(),
      user.hashedPassword,
      user.createdAt
    ]);

    return this.mapToUser(result.rows[0]);
  }

  async findByEmail(email: Email): Promise<User | null> {
    const query = 'SELECT * FROM users WHERE email = $1';
    const result = await this.db.query(query, [email.toString()]);

    if (result.rows.length === 0) {
      return null;
    }

    return this.mapToUser(result.rows[0]);
  }

  private mapToUser(row: any): User {
    return new User(
      row.id,
      new Email(row.email),
      row.password,
      row.created_at
    );
  }
}

class BcryptPasswordHasher implements PasswordHasher {
  private readonly SALT_ROUNDS = 12;

  async hash(password: string): Promise<string> {
    return bcrypt.hash(password, this.SALT_ROUNDS);
  }

  async verify(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }
}

class SendGridEmailService implements EmailService {
  constructor(private readonly apiKey: string) {}

  async sendWelcomeEmail(email: Email, name: string): Promise<void> {
    // SendGrid implementation
  }
}

class UUIDGenerator implements IdGenerator {
  generate(): string {
    return uuid.v4();
  }
}

// ========== 测试（TDD）==========
describe('UserRegistrationService', () => {
  let service: UserRegistrationService;
  let mockUserRepo: jest.Mocked<UserRepository>;
  let mockPasswordHasher: jest.Mocked<PasswordHasher>;
  let mockEmailService: jest.Mocked<EmailService>;
  let mockIdGenerator: jest.Mocked<IdGenerator>;

  beforeEach(() => {
    mockUserRepo = createMock<UserRepository>();
    mockPasswordHasher = createMock<PasswordHasher>();
    mockEmailService = createMock<EmailService>();
    mockIdGenerator = createMock<IdGenerator>();

    service = new UserRegistrationService(
      mockUserRepo,
      mockPasswordHasher,
      mockEmailService,
      mockIdGenerator
    );
  });

  describe('register', () => {
    it('should successfully register a new user', async () => {
      // Arrange
      const command = {
        email: 'test@example.com',
        password: 'SecurePass123',
        name: 'Test User'
      };

      mockUserRepo.findByEmail.mockResolvedValue(null);
      mockPasswordHasher.hash.mockResolvedValue('hashed_password');
      mockIdGenerator.generate.mockReturnValue('user-123');
      mockUserRepo.save.mockImplementation(async (user) => user);

      // Act
      const result = await service.register(command);

      // Assert
      expect(result).toMatchObject({
        id: 'user-123',
        email: expect.objectContaining({ value: 'test@example.com' })
      });
      expect(mockUserRepo.save).toHaveBeenCalledTimes(1);
      expect(mockEmailService.sendWelcomeEmail).toHaveBeenCalledTimes(1);
    });

    it('should throw error when email already exists', async () => {
      // Arrange
      mockUserRepo.findByEmail.mockResolvedValue(new User(
        'existing-user',
        new Email('test@example.com'),
        'hashed',
        new Date()
      ));

      // Act & Assert
      await expect(service.register(command))
        .rejects
        .toThrow(EmailAlreadyExistsError);

      expect(mockUserRepo.save).not.toHaveBeenCalled();
    });

    it('should not fail registration if email sending fails', async () => {
      // Arrange
      mockUserRepo.findByEmail.mockResolvedValue(null);
      mockEmailService.sendWelcomeEmail.mockRejectedValue(
        new Error('Email service down')
      );

      // Act
      const result = await service.register(command);

      // Assert
      expect(result).toBeDefined();
      // 注册成功即使邮件发送失败
    });
  });
});
```

---
**模块类型**：原则指导（完整版）
**适用场景**：代码审查、重构、架构设计、新项目开发、团队培训
**前置知识**：基础编程概念、面向对象编程
**配合模块**：testing, code-review, workflow
**更新版本**：v2.0 - 包含完整示例和深度实践