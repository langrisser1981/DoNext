//
//  CategoryCreationSheet.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI
import SwiftData

/// 分類創建表單
/// 提供新增分類的功能，包括名稱輸入和顏色選擇
struct CategoryCreationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // 表單狀態
    @State private var name = ""
    @State private var selectedColor = "#007AFF" // 預設藍色
    
    /// 預設可選顏色
    private let availableColors = [
        "#007AFF", // 藍色
        "#FF3B30", // 紅色
        "#FF9500", // 橙色
        "#FFCC00", // 黃色
        "#34C759", // 綠色
        "#5856D6", // 紫色
        "#FF2D92", // 粉色
        "#8E8E93", // 灰色
        "#AF52DE", // 紫紅色
        "#32D74B", // 青綠色
        "#FF6B35", // 橙紅色
        "#5AC8FA", // 青藍色
    ]
    
    /// 是否可以創建分類
    private var canCreateCategory: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 名稱輸入區段
                nameSection
                
                // 顏色選擇區段
                colorSection
                
                // 預覽區段
                previewSection
            }
            .navigationTitle("新增分類")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        createCategory()
                    }
                    .disabled(!canCreateCategory)
                }
            }
        }
    }
    
    /// 名稱輸入區段
    private var nameSection: some View {
        Section {
            TextField("請輸入分類名稱", text: $name)
                .textFieldStyle(PlainTextFieldStyle())
        } header: {
            Text("分類名稱")
        }
    }
    
    /// 顏色選擇區段
    private var colorSection: some View {
        Section {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                ForEach(availableColors, id: \.self) { colorHex in
                    ColorSelectionButton(
                        color: Color(hex: colorHex),
                        isSelected: selectedColor == colorHex
                    ) {
                        selectedColor = colorHex
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("選擇顏色")
        }
    }
    
    /// 預覽區段
    private var previewSection: some View {
        Section {
            HStack {
                Text("預覽")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 分類標籤預覽
                if !name.isEmpty {
                    CategoryPreview(name: name, color: selectedColor)
                } else {
                    Text("請輸入分類名稱")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
        } header: {
            Text("預覽效果")
        }
    }
    
    /// 創建分類
    private func createCategory() {
        let newCategory = Category(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            color: selectedColor
        )
        
        // 保存到 SwiftData
        modelContext.insert(newCategory)
        
        dismiss()
    }
}

/// 顏色選擇按鈕
/// 提供顏色選擇的圓形按鈕，支援選中狀態顯示
struct ColorSelectionButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .opacity(isSelected ? 1 : 0)
                )
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(isSelected ? 1 : 0)
                )
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 分類預覽
/// 顯示分類標籤的預覽效果
struct CategoryPreview: View {
    let name: String
    let color: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 8, height: 8)
            
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(hex: color).opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: color), lineWidth: 1)
        )
    }
}


// MARK: - 預覽

#Preview {
    CategoryCreationSheet()
        .modelContainer(for: [Category.self], inMemory: true)
}