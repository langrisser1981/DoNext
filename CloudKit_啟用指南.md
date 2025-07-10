# CloudKit 啟用指南

本專案包含完整的 iCloud CloudKit 同步功能代碼，但為了支援免費 Apple Developer 帳號，預設為停用狀態。

## 前置條件

要啟用 CloudKit 功能，您需要：

1. **付費 Apple Developer 帳號** ($99/年)
2. **在 Apple Developer Console 中設定 CloudKit**
3. **修改專案配置**

## 啟用步驟

### 1. 恢復 CloudKit Entitlements

編輯 `DoNext/DoNext.entitlements` 檔案，取消註釋 CloudKit 相關設定：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-only</key>
    <true/>
    <!-- 取消註釋以下設定 -->
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.lenny.DoNext</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
    <key>com.apple.developer.ubiquity-kvstore-identifier</key>
    <string>$(TeamIdentifierPrefix)com.lenny.DoNext</string>
</dict>
</plist>
```

### 2. 啟用編譯標誌

在 Xcode 中：

1. 選擇專案 **DoNext.xcodeproj**
2. 選擇 **DoNext** target
3. 切換到 **Build Settings** 標籤
4. 搜尋 **"Swift Compiler - Custom Flags"**
5. 在 **Active Compilation Conditions** 中新增：`CLOUDKIT_ENABLED`

或者手動編輯 `.xcconfig` 檔案：

```
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG CLOUDKIT_ENABLED
```

### 3. 在 Apple Developer Console 設定

1. 登入 [Apple Developer Console](https://developer.apple.com/)
2. 前往 **Certificates, Identifiers & Profiles**
3. 選擇您的 App ID
4. 啟用 **CloudKit** 服務
5. 配置 CloudKit Container（使用 `iCloud.com.lenny.DoNext`）

### 4. 更新 Bundle ID（可選）

如果需要，更新 CloudKit container identifier 以符合您的 Team ID：

在 `CloudKitManager.swift` 中更新：
```swift
private let container = CKContainer(identifier: "iCloud.YOUR_BUNDLE_ID")
```

## 驗證啟用

啟用後，專案會：

1. ✅ 正常編譯和運行
2. ✅ 在設定頁面顯示 iCloud 同步選項
3. ✅ 支援跨裝置資料同步
4. ✅ 顯示同步狀態指示器

## 疑難排解

### 編譯錯誤
- 確認已添加 `CLOUDKIT_ENABLED` 編譯標誌
- 檢查 entitlements 設定是否正確

### CloudKit 無法使用
- 確認使用付費開發者帳號
- 檢查 App ID 是否啟用 CloudKit 服務
- 確認裝置已登入 iCloud

### 同步問題
- 檢查網路連線
- 確認多個裝置使用相同 Apple ID
- 查看設定頁面的同步狀態

## 當前狀態

**免費開發者帳號模式**：
- ✅ 編譯成功
- ✅ 所有功能正常（僅本地存儲）
- ❌ CloudKit 同步停用
- ❌ 設定中不顯示 iCloud 選項

**付費開發者帳號模式**（啟用 `CLOUDKIT_ENABLED`）：
- ✅ 編譯成功
- ✅ 完整 CloudKit 同步功能
- ✅ 跨裝置資料同步
- ✅ 設定中顯示 iCloud 選項