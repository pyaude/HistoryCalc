# HistoryCalc — 开发计划

## 总体策略

采用**渐进式开发**，分 4 个阶段。每个阶段可独立验证，降低风险。

---

## 阶段 1：计算引擎核心

**目标**：实现完整的标准计算逻辑，纯 Dart，可独立测试。

### 任务清单

- [ ] 创建 `lib/core/calculator/calculator.dart`
  - 实现 `Calculator` 类，管理表达式字符串和状态
  - 支持数字输入、运算符输入、小数点、退格、清除
  - 支持 `=` 求值（按输入顺序计算）
  - 支持 `√`、`x²`、`%`、`±` 操作
- [ ] 编写单元测试 `test/core/calculator/calculator_test.dart`
  - 覆盖：四则运算、连续运算、平方根、平方、百分比、正负号、小数、边界情况

### 产出物
- `lib/core/calculator/calculator.dart`
- `test/core/calculator/calculator_test.dart`

---

## 阶段 2：状态管理 + 历史记录持久化

**目标**：用 Riverpod 管理计算器状态，实现历史记录的存储与加载。

### 任务清单

- [ ] 添加 `hive` 和 `hive_flutter` 依赖到 `pubspec.yaml`
- [ ] 创建 `lib/core/storage/history_storage.dart`
  - 初始化 Hive
  - 定义 `HistoryEntry` 数据模型（表达式、结果、时间戳）
  - 实现保存/加载/清空历史记录，最多 10 条
- [ ] 创建 `lib/core/providers/calculator_provider.dart`
  - `StateNotifier` 管理计算器当前表达式、结果、历史记录列表
  - 暴露方法：`input(String)`, `clear()`, `evaluate()`, `insertFromHistory(double)`
- [ ] 编写测试验证状态逻辑

### 产出物
- `lib/core/storage/history_storage.dart`
- `lib/core/providers/calculator_provider.dart`
- 更新 `pubspec.yaml`

---

## 阶段 3：UI 实现

**目标**：构建完整的计算器界面和底部历史抽屉。

### 任务清单

- [ ] 重构 `lib/presentation/screens/home_screen.dart` → `calculator_screen.dart`
  - 顶部：表达式显示 + 结果预览
  - 中部：4×n 计算器按键网格
  - 底部栏：历史记录按钮
- [ ] 创建 `lib/presentation/widgets/`
  - `calc_button.dart` — 单个计算器按键组件
  - `calc_display.dart` — 表达式/结果显示区
  - `history_drawer.dart` — 底部历史抽屉（可展开/收起）
- [ ] 创建 `lib/presentation/screens/calculator_screen.dart` 组装所有组件
- [ ] 更新 `main.dart` 路由

### 产出物
- `lib/presentation/widgets/calc_button.dart`
- `lib/presentation/widgets/calc_display.dart`
- `lib/presentation/widgets/history_drawer.dart`
- `lib/presentation/screens/calculator_screen.dart`

---

## 阶段 4：集成 + 打磨

**目标**：全流程串联，UI 精调，测试验证。

### 任务清单

- [ ] 端到端集成测试
- [ ] 暗色主题 UI 细节调整（按键颜色、圆角、间距、阴影）
- [ ] 键盘按压动效
- [ ] 历史记录空状态处理
- [ ] 最终在 Android 和 Web 上验证

---

## 项目文件结构（最终目标）

```
lib/
├── main.dart
├── core/
│   ├── calculator/
│   │   └── calculator.dart          # 纯计算逻辑
│   ├── providers/
│   │   └── calculator_provider.dart # Riverpod 状态管理
│   ├── storage/
│   │   └── history_storage.dart     # Hive 持久化
│   └── theme/
│       ├── app_theme.dart           # 暗色主题
│       └── app_colors.dart          # 颜色常量
└── presentation/
    ├── screens/
    │   └── calculator_screen.dart   # 主页面
    └── widgets/
        ├── calc_button.dart         # 按键组件
        ├── calc_display.dart        # 显示区组件
        └── history_drawer.dart      # 底部历史抽屉
```

---

## 里程碑

| 阶段 | 预估 | 验证方式 |
|------|------|----------|
| 1 — 计算引擎 | 先 | `dart test` 全绿 |
| 2 — 状态+存储 | 次 | `dart test` + 手动验证持久化 |
| 3 — UI | 再 | 热重载可见完整界面 |
| 4 — 集成打磨 | 后 | 真机/Web 全流程测试 |
