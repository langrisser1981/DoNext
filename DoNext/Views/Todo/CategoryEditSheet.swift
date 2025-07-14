//
//  CategoryEditSheet.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI
import SwiftData

/// 分類編輯表單
/// 提供編輯分類的功能，包含名稱和顏色修改
struct CategoryEditSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let category: Category
    
    /// 表單狀態
    @State private var name: String
    @State private var selectedColor: CategoryColor
    
    init(category: Category) {
        self.category = category
        self._name = State(initialValue: category.name)
        self._selectedColor = State(initialValue: CategoryColor.fromHex(category.color) ?? .blue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                nameSection
                colorSection
            }
            .navigationTitle("編輯分類")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        saveCategory()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    /// 名稱輸入區域
    private var nameSection: some View {
        Section {
            TextField("輸入分類名稱", text: $name)
                .font(.body)
        } header: {
            Text("名稱")
        }
    }
    
    /// 顏色選擇區域
    private var colorSection: some View {
        Section {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                ForEach(CategoryColor.allCases, id: \.self) { color in
                    Button(action: {
                        selectedColor = color
                    }) {
                        Circle()
                            .fill(Color(hex: color.hexValue))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                            )
                            .scaleEffect(selectedColor == color ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: selectedColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("顏色")
        }
    }
    
    /// 儲存分類修改
    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        category.name = trimmedName
        category.color = selectedColor.hexValue
        
        if modelContext.updateCategory() {
            dismiss()
        }
    }
}

/// CategoryColor 擴展，支援從 Hex 轉換
extension CategoryColor {
    static func fromHex(_ hex: String) -> CategoryColor? {
        return CategoryColor.allCases.first { $0.hexValue == hex }
    }
}

#Preview {
    CategoryEditSheet(category: Category(name: "工作", color: "#FF6B6B"))
        .modelContainer(for: [Category.self], inMemory: true)
}