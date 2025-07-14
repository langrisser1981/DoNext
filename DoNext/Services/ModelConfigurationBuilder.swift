//
//  ModelConfigurationBuilder.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/14.
//

import SwiftData
import Foundation

/// ModelConfiguration 建構器
/// 使用 Builder Pattern 簡化 ModelConfiguration 的創建和配置
class ModelConfigurationBuilder {
    
    // MARK: - Properties
    
    private var schema: Schema
    private var isStoredInMemoryOnly: Bool = false
    private var cloudKitDatabase: ModelConfiguration.CloudKitDatabase? = nil
    private var url: URL? = nil
    
    // MARK: - Initialization
    
    /// 初始化建構器
    /// - Parameter schema: SwiftData 模型架構
    init(schema: Schema) {
        self.schema = schema
    }
    
    // MARK: - Builder Methods
    
    /// 設定是否僅儲存在記憶體中
    /// - Parameter inMemoryOnly: 是否僅在記憶體中儲存
    /// - Returns: 建構器實例，支援鏈式調用
    @discardableResult
    func inMemoryOnly(_ inMemoryOnly: Bool = true) -> ModelConfigurationBuilder {
        self.isStoredInMemoryOnly = inMemoryOnly
        return self
    }
    
    /// 啟用 CloudKit 同步
    /// - Parameter database: CloudKit 資料庫配置
    /// - Returns: 建構器實例，支援鏈式調用
    @discardableResult
    func withCloudKit(_ database: ModelConfiguration.CloudKitDatabase = .automatic) -> ModelConfigurationBuilder {
        self.cloudKitDatabase = database
        return self
    }
    
    
    /// 設定自定義 URL
    /// - Parameter url: 資料庫檔案的自定義位置
    /// - Returns: 建構器實例，支援鏈式調用
    @discardableResult
    func withCustomURL(_ url: URL) -> ModelConfigurationBuilder {
        self.url = url
        return self
    }
    
    // MARK: - Build Method
    
    /// 建構 ModelConfiguration
    /// - Returns: 配置完成的 ModelConfiguration
    func build() -> ModelConfiguration {
        if let cloudKitDatabase = cloudKitDatabase {
            // CloudKit 配置
            return ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: isStoredInMemoryOnly,
                cloudKitDatabase: cloudKitDatabase
            )
        } else if let url = url {
            // 自定義 URL 配置
            return ModelConfiguration(
                schema: schema,
                url: url
            )
        } else {
            // 基本配置
            return ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: isStoredInMemoryOnly
            )
        }
    }
}

// MARK: - Convenience Extensions

extension ModelConfigurationBuilder {
    
    /// 建立本地存儲配置
    /// - Parameter schema: SwiftData 模型架構
    /// - Returns: 配置為本地存儲的 ModelConfiguration
    static func localStorage(schema: Schema) -> ModelConfiguration {
        return ModelConfigurationBuilder(schema: schema)
            .inMemoryOnly(false)
            .build()
    }
    
    /// 建立 CloudKit 同步配置
    /// - Parameters:
    ///   - schema: SwiftData 模型架構
    ///   - database: CloudKit 資料庫配置
    /// - Returns: 配置為 CloudKit 同步的 ModelConfiguration
    static func cloudKitSync(schema: Schema, database: ModelConfiguration.CloudKitDatabase = .automatic) -> ModelConfiguration {
        return ModelConfigurationBuilder(schema: schema)
            .inMemoryOnly(false)
            .withCloudKit(database)
            .build()
    }
    
    /// 建立記憶體存儲配置（通常用於測試）
    /// - Parameter schema: SwiftData 模型架構
    /// - Returns: 配置為記憶體存儲的 ModelConfiguration
    static func inMemory(schema: Schema) -> ModelConfiguration {
        return ModelConfigurationBuilder(schema: schema)
            .inMemoryOnly(true)
            .build()
    }
}

// MARK: - Settings-based Factory

extension ModelConfigurationBuilder {
    
    /// 根據設定管理器創建配置
    /// - Parameters:
    ///   - schema: SwiftData 模型架構
    ///   - settingsManager: 設定管理器
    /// - Returns: 根據設定配置的 ModelConfiguration
    static func fromSettings(schema: Schema, settingsManager: SettingsManager) -> ModelConfiguration {
        #if CLOUDKIT_ENABLED
        if settingsManager.isCloudSyncEnabled && settingsManager.shouldShowCloudSyncOption {
            return cloudKitSync(schema: schema)
        } else {
            return localStorage(schema: schema)
        }
        #else
        return localStorage(schema: schema)
        #endif
    }
}