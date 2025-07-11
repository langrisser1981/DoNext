# DoNext - iOS Task Management App

一款使用 SwiftUI 和 SwiftData 構建的現代化 iOS 任務管理應用程式，採用 Coordinator 模式和組件化設計。

## 🏗️ 專案架構

### 核心設計模式

#### 1. Coordinator Pattern (協調者模式)
負責管理應用程式的導航流程，提供清晰的導航層級和職責分離。

```
AppCoordinator (根協調者)
├── 管理應用程式整體狀態 (onboarding, login, authenticated)
├── 處理全域 Sheet 和 Alert 顯示
├── 管理子協調者生命周期
└── HomeCoordinator (功能協調者)
    ├── 管理主頁面相關導航
    ├── 處理 Todo 詳情、建立、編輯
    ├── 處理分類管理操作
    └── 與 AppCoordinator 協調全域操作
```

#### 2. MVVM + Component Architecture
- **Model**: SwiftData 模型 (TodoItem, Category)
- **View**: SwiftUI 組件化視圖
- **ViewModel**: 業務邏輯處理 (Observable classes)
- **Components**: 可重用的 UI 組件

#### 3. Services Layer (服務層)
提供業務邏輯和外部服務的抽象層。

```
Services/
├── NotificationManager    # 本地通知管理
├── CloudKitManager       # iCloud 同步管理
├── SettingsManager       # 應用設定持久化
└── AuthenticationStrategy # 認證策略
```

## 📱 應用程式流程

### 啟動流程
```
DoNextApp 
├── 創建 ModelContainer (SwiftData)
├── 初始化 AppCoordinator
├── 檢查 onboarding 完成狀態
└── 導航到對應狀態
    ├── .onboarding → LandingPageView
    ├── .login → LoginView
    └── .authenticated → HomeView (with HomeCoordinator)
```

### 主要導航流程

#### 1. Todo 操作流程
```
HomeView
├── 點擊 Todo → HomeCoordinator.showTodoDetail()
├── 新增 Todo → HomeCoordinator.showTodoCreation()
├── 編輯 Todo → TodoDetailView → HomeCoordinator.showTodoEdit()
└── 刪除 Todo → HomeCoordinator.showDeleteConfirmation()
    └── AppCoordinator.presentAlert(.deleteConfirmation)
```

#### 2. 分類操作流程
```
HomeCategoryTabs
├── 長按分類 → showActionBarForCategory() 
│   └── CategoryActionBar
│       ├── 編輯 → HomeCoordinator.showCategoryEdit()
│       └── 刪除 → HomeCoordinator.showCategoryDeleteConfirmation()
├── 新增分類 → HomeCoordinator.showCategoryCreation()
└── 邊緣滑動 → handleSwipeGesture() → 切換分類
```

#### 3. Sheet 管理流程
```
AppCoordinator.presentSheet()
├── .todoCreation → TodoCreationSheet
├── .todoEdit → TodoEditSheet
├── .categoryCreation → CategoryCreationSheet
├── .categoryEdit → CategoryEditSheet
├── .todoDetail → TodoDetailView
└── .settings → SettingsView
```

## 🎯 手勢系統設計

### 手勢分離策略
為了避免手勢衝突，實現了分層的手勢處理系統：

#### 1. TodoItem 層級
- **右滑刪除**: 使用原生 `swipeActions`，穩定可靠
- **點擊查看**: `onTapGesture` 進入詳情頁面
- **完成切換**: 勾選按鈕操作

#### 2. 整體畫面層級 (HomeView)
- **邊緣滑動**: 從螢幕邊緣開始的手勢切換分類
- **手勢檢測**: 使用 `GeometryReader` 精確計算邊緣區域

```swift
// 邊緣滑動檢測邏輯
let screenWidth = geometry.size.width
let edgeThreshold: CGFloat = 50
let isFromLeftEdge = startLocation.x <= edgeThreshold
let isFromRightEdge = startLocation.x >= screenWidth - edgeThreshold
```

#### 3. 分類標籤層級
- **長按手勢**: 觸發 Action Bar 顯示
- **一般點擊**: 切換分類

## 🧩 組件架構

### 組件化設計原則
1. **單一職責**: 每個組件只負責一個功能
2. **可重用性**: 組件可在不同場景重用
3. **組合優於繼承**: 通過組件組合構建複雜 UI
4. **明確的資料流**: 使用 @Binding 和 callback 傳遞資料

### 主要組件結構

#### Home 相關組件
```
HomeView
├── HomeSearchBar (搜尋功能)
├── HomeCategoryTabs (分類導航)
│   ├── CategoryTab (個別分類標籤)
│   └── AddCategoryButton (新增分類按鈕)
├── HomeTodoListContainer (Todo 列表容器)
│   ├── TodoRowView (個別 Todo 項目)
│   └── HomeEmptyState (空狀態顯示)
├── HomeFloatingAddButton (浮動新增按鈕)
├── HomeToolbarContent (工具列內容)
└── CategoryActionBar (分類操作列 - Overlay)
```

#### Todo 表單組件
```
TodoCreationSheet / TodoEditSheet
├── TodoFormTitleSection (標題輸入)
├── TodoFormCategorySection (分類選擇)
├── TodoFormReminderSection (提醒設定)
├── TodoFormRepeatSection (重複選項)
└── TodoFormToolbarContent (表單工具列)
```

#### Settings 組件
```
SettingsView
├── SettingsAccountSection (帳號管理)
├── SettingsCloudSyncSection (同步設定)
└── SettingsOtherSection (其他設定)
```

## 📊 資料流向

### SwiftData 模型關聯
```
TodoItem (多對一) ← → Category (一對多)
├── TodoItem.category: Category?
└── Category.todos: [TodoItem]
```

### 狀態管理
```
環境注入 (@Environment)
├── AppCoordinator (導航狀態)
├── CloudKitManager (同步狀態)
├── NotificationManager (通知管理)
├── SettingsManager (應用設定)
└── ModelContext (SwiftData 上下文)

本地狀態 (@State)
├── HomeView: selectedCategoryIndex, searchText, actionBar狀態
├── Form Views: 表單輸入狀態
└── Component States: 各組件內部狀態
```

## 🔄 典型操作流程

### 1. 新增 Todo
```
User 點擊浮動按鈕
→ HomeCoordinator.showTodoCreation()
→ AppCoordinator.presentSheet(.todoCreation)
→ TodoCreationSheet 顯示
→ User 填寫表單並儲存
→ SwiftData 儲存到 ModelContext
→ NotificationManager 排程通知
→ Sheet 關閉，回到 HomeView
→ @Query 自動更新 UI
```

### 2. 編輯分類
```
User 長按分類標籤
→ CategoryTab 觸發 onLongPress
→ HomeView.showActionBarForCategory()
→ CategoryActionBar 顯示
→ User 點擊編輯按鈕
→ HomeCoordinator.showCategoryEdit()
→ AppCoordinator.presentSheet(.categoryEdit)
→ CategoryEditSheet 顯示 (預填資料)
→ User 修改並儲存
→ SwiftData 更新 Category
→ Sheet 關閉，Action Bar 消失
→ @Query 自動更新 UI
```

### 3. 邊緣滑動切換分類
```
User 從螢幕邊緣滑動
→ HomeView 的 GeometryReader 檢測手勢
→ 驗證是否來自邊緣區域
→ 驗證滑動方向和距離
→ handleSwipeGesture() 計算目標分類
→ 更新 selectedCategoryIndex
→ withAnimation 執行切換動畫
→ HomeCategoryTabs 更新選中狀態
→ HomeTodoListContainer 更新顯示內容
```

## 🛠️ 開發最佳實踐

### 導航管理
- 所有導航操作通過 Coordinator 進行
- 使用 `presentSheet()` 和 `presentAlert()` 管理 Modal 顯示
- 避免直接在 View 中處理導航邏輯

### 狀態管理
- 使用 `@Environment` 注入服務和協調者
- 本地狀態使用 `@State` 和 `@Binding`
- 複雜狀態考慮使用 `@Observable` classes

### 組件設計
- 組件應該無狀態或最小狀態
- 使用 callback 模式傳遞事件
- 通過 `@Binding` 共享可變狀態

### 手勢處理
- 使用分層手勢處理避免衝突
- 優先使用原生手勢 (如 `swipeActions`)
- 自定義手勢需要仔細測試邊界條件

### 資料持久化
- 使用 SwiftData 的 `@Model` 定義資料模型
- 通過 `@Query` 進行響應式資料查詢
- 在適當的地方調用 `modelContext.save()`

## 🚀 未來擴展

### 架構擴展點
1. **新增功能模組**: 按照現有的 Coordinator + Components 模式
2. **多平台支援**: 利用組件化設計適配 macOS 和 visionOS
3. **網路服務**: 在 Services 層添加 API 客戶端
4. **資料同步**: 擴展 CloudKitManager 實現完整同步
5. **插件系統**: 利用 Strategy 模式支援第三方擴展

這個架構提供了良好的可維護性、可測試性和可擴展性，遵循 SwiftUI 和 iOS 開發的最佳實踐。