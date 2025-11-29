# 模块：性能优化指南

## 性能指标体系

### 核心 Web Vitals
```javascript
// 性能指标目标
const performanceTargets = {
  FCP: 1800,   // First Contentful Paint < 1.8s
  LCP: 2500,   // Largest Contentful Paint < 2.5s
  FID: 100,    // First Input Delay < 100ms
  CLS: 0.1,    // Cumulative Layout Shift < 0.1
  TTFB: 600,   // Time to First Byte < 600ms
  TBT: 300,    // Total Blocking Time < 300ms
};

// 性能监控
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    // 记录性能数据
    analytics.track('web-vitals', {
      name: entry.name,
      value: entry.value,
      rating: getRating(entry.name, entry.value)
    });
  }
});

observer.observe({ entryTypes: ['web-vital'] });
```

### 自定义性能指标
```javascript
// 用户中心指标
const customMetrics = {
  timeToInteractive: 0,    // 可交互时间
  timeToFirstMeaningfulPaint: 0, // 首次有意义绘制
  longTaskCount: 0,        // 长任务数量
  resourceLoadTime: {},    // 资源加载时间
};

// 监控长任务
const longTaskObserver = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    customMetrics.longTaskCount++;
    console.warn('Long task detected:', entry.duration);
  }
});

longTaskObserver.observe({ entryTypes: ['longtask'] });
```

## 前端性能优化

### 资源加载优化
```html
<!-- 预连接 -->
<link rel="preconnect" href="https://api.example.com">
<link rel="dns-prefetch" href="https://cdn.example.com">

<!-- 预加载关键资源 -->
<link rel="preload" href="/fonts/main.woff2" as="font" crossorigin>
<link rel="preload" href="/css/critical.css" as="style">

<!-- 预获取 -->
<link rel="prefetch" href="/js/next-page.js">
```

### 代码分割
```javascript
// 路由级别代码分割
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./Dashboard'));
const Profile = lazy(() => import('./Profile'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/profile" element={<Profile />} />
      </Routes>
    </Suspense>
  );
}

// 条件加载
async function loadHeavyFeature() {
  const module = await import(
    /* webpackChunkName: "heavy-feature" */
    './HeavyFeature'
  );
  return module.default;
}
```

### 图片优化
```javascript
// 响应式图片
<picture>
  <source
    media="(max-width: 768px)"
    srcset="image-mobile.webp"
    type="image/webp"
  />
  <source
    media="(max-width: 768px)"
    srcset="image-mobile.jpg"
    type="image/jpeg"
  />
  <source
    srcset="image-desktop.webp"
    type="image/webp"
  />
  <img
    src="image-desktop.jpg"
    alt="Description"
    loading="lazy"
    decoding="async"
  />
</picture>

// 图片懒加载
const LazyImage = ({ src, alt }) => {
  const [imageSrc, setImageSrc] = useState('placeholder.jpg');
  const imgRef = useRef();

  useEffect(() => {
    const observer = new IntersectionObserver(
      entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            setImageSrc(src);
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.1 }
    );

    if (imgRef.current) {
      observer.observe(imgRef.current);
    }

    return () => observer.disconnect();
  }, [src]);

  return <img ref={imgRef} src={imageSrc} alt={alt} />;
};
```

### React 性能优化
```javascript
// Memo优化
const ExpensiveComponent = React.memo(({ data }) => {
  return <ComplexVisualization data={data} />;
}, (prevProps, nextProps) => {
  // 自定义比较逻辑
  return prevProps.data.id === nextProps.data.id;
});

// useMemo优化
const MemoizedComponent = ({ items, filter }) => {
  const filteredItems = useMemo(
    () => items.filter(item => item.type === filter),
    [items, filter]
  );

  return <ItemList items={filteredItems} />;
};

// useCallback优化
const CallbackComponent = ({ data }) => {
  const handleClick = useCallback((id) => {
    console.log('Clicked:', id);
  }, []); // 依赖为空，函数永不改变

  return data.map(item => (
    <Item key={item.id} onClick={handleClick} />
  ));
};

// 虚拟化长列表
import { FixedSizeList } from 'react-window';

const VirtualList = ({ items }) => (
  <FixedSizeList
    height={600}
    itemCount={items.length}
    itemSize={50}
    width='100%'
  >
    {({ index, style }) => (
      <div style={style}>
        {items[index].name}
      </div>
    )}
  </FixedSizeList>
);
```

## 后端性能优化

### 数据库优化
```sql
-- 索引优化
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_order_user_date ON orders(user_id, created_at);

-- 复合索引（注意顺序）
CREATE INDEX idx_composite ON table_name(column1, column2, column3);

-- 查询优化
-- 使用 EXPLAIN 分析查询
EXPLAIN SELECT * FROM users WHERE email = 'user@example.com';

-- 避免 SELECT *
SELECT id, name, email FROM users WHERE status = 'active';

-- 使用 LIMIT
SELECT * FROM large_table LIMIT 100 OFFSET 0;
```

### 缓存策略
```javascript
// Redis缓存层
class CacheService {
  constructor(redisClient) {
    this.redis = redisClient;
    this.defaultTTL = 3600; // 1小时
  }

  async get(key) {
    const cached = await this.redis.get(key);
    if (cached) {
      return JSON.parse(cached);
    }
    return null;
  }

  async set(key, value, ttl = this.defaultTTL) {
    await this.redis.setex(
      key,
      ttl,
      JSON.stringify(value)
    );
  }

  async invalidate(pattern) {
    const keys = await this.redis.keys(pattern);
    if (keys.length) {
      await this.redis.del(...keys);
    }
  }
}

// 缓存装饰器
function Cacheable(ttl = 3600) {
  return function(target, propertyName, descriptor) {
    const originalMethod = descriptor.value;

    descriptor.value = async function(...args) {
      const cacheKey = `${propertyName}:${JSON.stringify(args)}`;

      const cached = await cache.get(cacheKey);
      if (cached) return cached;

      const result = await originalMethod.apply(this, args);
      await cache.set(cacheKey, result, ttl);

      return result;
    };
  };
}

// 使用
class UserService {
  @Cacheable(7200)
  async getUserById(id) {
    return await db.query('SELECT * FROM users WHERE id = ?', [id]);
  }
}
```

### 异步处理
```javascript
// 队列处理
import Bull from 'bull';

const emailQueue = new Bull('email', {
  redis: { port: 6379, host: '127.0.0.1' }
});

// 生产者
async function sendEmailAsync(to, subject, body) {
  await emailQueue.add('send', { to, subject, body }, {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 2000
    }
  });
}

// 消费者
emailQueue.process('send', async (job) => {
  const { to, subject, body } = job.data;
  await emailService.send(to, subject, body);
});

// 批处理
class BatchProcessor {
  constructor(batchSize = 100, interval = 1000) {
    this.batch = [];
    this.batchSize = batchSize;
    this.interval = interval;
    this.startTimer();
  }

  add(item) {
    this.batch.push(item);
    if (this.batch.length >= this.batchSize) {
      this.flush();
    }
  }

  async flush() {
    if (this.batch.length === 0) return;

    const items = this.batch.splice(0);
    await this.processBatch(items);
  }

  async processBatch(items) {
    // 批量处理逻辑
    await db.bulkInsert(items);
  }

  startTimer() {
    setInterval(() => this.flush(), this.interval);
  }
}
```

## 网络优化

### HTTP/2 优化
```javascript
// 服务器推送
const http2 = require('http2');

server.on('stream', (stream, headers) => {
  if (headers[':path'] === '/index.html') {
    // 推送 CSS 和 JS
    stream.pushStream({ ':path': '/styles.css' }, (err, pushStream) => {
      pushStream.respond({ ':status': 200 });
      pushStream.end(cssContent);
    });
  }
});

// 多路复用配置
const server = http2.createSecureServer({
  maxConcurrentStreams: 100,
  peerMaxConcurrentStreams: 100
});
```

### CDN 配置
```javascript
// CDN URL 生成
function getCDNUrl(path, version) {
  const cdnDomains = [
    'cdn1.example.com',
    'cdn2.example.com',
    'cdn3.example.com'
  ];

  // 简单的负载均衡
  const hash = path.split('').reduce((a, b) => {
    return a + b.charCodeAt(0);
  }, 0);

  const domain = cdnDomains[hash % cdnDomains.length];
  return `https://${domain}/${path}?v=${version}`;
}

// 资源版本化
const assetManifest = {
  'app.js': 'app.123abc.js',
  'style.css': 'style.456def.css'
};
```

### 压缩优化
```javascript
// Gzip/Brotli 压缩
import compression from 'compression';

app.use(compression({
  level: 6,
  threshold: 1024, // 只压缩超过1KB的响应
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  }
}));

// 响应压缩策略
function shouldCompress(req, res) {
  const type = res.getHeader('Content-Type');
  const compressibleTypes = [
    'text/html',
    'text/css',
    'text/javascript',
    'application/json',
    'application/javascript',
    'image/svg+xml'
  ];

  return compressibleTypes.some(t => type.includes(t));
}
```

## 性能监控

### 前端监控
```javascript
// 性能数据收集
class PerformanceMonitor {
  constructor() {
    this.metrics = {};
    this.init();
  }

  init() {
    // 页面加载性能
    window.addEventListener('load', () => {
      const perfData = performance.getEntriesByType('navigation')[0];
      this.metrics.loadTime = perfData.loadEventEnd - perfData.fetchStart;
      this.metrics.domReady = perfData.domContentLoadedEventEnd - perfData.fetchStart;
      this.metrics.firstPaint = performance.getEntriesByName('first-paint')[0]?.startTime;
    });

    // 资源加载性能
    const observer = new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        this.metrics.resources = this.metrics.resources || {};
        this.metrics.resources[entry.name] = entry.duration;
      }
    });

    observer.observe({ entryTypes: ['resource'] });
  }

  report() {
    // 上报性能数据
    fetch('/api/metrics', {
      method: 'POST',
      body: JSON.stringify(this.metrics)
    });
  }
}
```

### 后端监控
```javascript
// APM 集成
import apm from 'elastic-apm-node';

const apm = require('elastic-apm-node').start({
  serviceName: 'my-app',
  secretToken: process.env.APM_TOKEN,
  serverUrl: process.env.APM_SERVER_URL
});

// 自定义性能追踪
app.use((req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;

    // 记录慢请求
    if (duration > 1000) {
      logger.warn('Slow request', {
        method: req.method,
        url: req.url,
        duration,
        statusCode: res.statusCode
      });
    }

    // 性能指标
    metrics.histogram('http_request_duration', duration, {
      method: req.method,
      route: req.route?.path,
      status: res.statusCode
    });
  });

  next();
});
```

## 性能预算

### 设置预算
```javascript
// webpack.config.js
module.exports = {
  performance: {
    hints: 'error',
    maxEntrypointSize: 250000,    // 250KB
    maxAssetSize: 100000,          // 100KB
    assetFilter: (assetFilename) => {
      return !assetFilename.match(/\.map$/);
    }
  }
};

// 性能预算配置
const performanceBudget = {
  bundles: {
    main: { maxSize: 150 },      // KB
    vendor: { maxSize: 200 },
    polyfills: { maxSize: 50 }
  },
  metrics: {
    FCP: { max: 1800 },           // ms
    LCP: { max: 2500 },
    TTI: { max: 3500 },
    TBT: { max: 300 }
  }
};
```

## 优化检查清单

### 前端优化
- [ ] 启用 Gzip/Brotli 压缩
- [ ] 配置浏览器缓存
- [ ] 实施代码分割
- [ ] 优化图片（WebP, 懒加载）
- [ ] 减少 JavaScript 执行时间
- [ ] 使用 CDN
- [ ] 最小化 CSS/JS
- [ ] 消除渲染阻塞资源
- [ ] 使用 Web Workers
- [ ] 实施资源提示

### 后端优化
- [ ] 数据库索引优化
- [ ] 实施缓存策略
- [ ] 使用连接池
- [ ] 异步处理耗时操作
- [ ] API 响应分页
- [ ] 启用 HTTP/2
- [ ] 负载均衡配置
- [ ] 数据库查询优化
- [ ] 减少 N+1 查询
- [ ] 使用消息队列

---
**模块类型**：性能调优
**适用场景**：性能分析、优化实施、监控配置
**配合模块**：testing, monitoring