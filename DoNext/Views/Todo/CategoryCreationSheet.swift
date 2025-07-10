//
//  CategoryCreationSheet.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI
import SwiftData

/// 分類創建表單
/// 提供新增分類的功能，包含名稱和顏色選擇
struct CategoryCreationSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    /// 表單狀態
    @State private var name = ""
    @State private var selectedColor = CategoryColor.allCases.first!
    
    var body: some View {
        NavigationView {
            Form {
                nameSection
                colorSection
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
    
    /// 儲存分類
    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newCategory = Category(name: trimmedName, color: selectedColor.hexValue)
        modelContext.insert(newCategory)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("儲存分類失敗: \(error)")
        }
    }
}

/// 分類顏色選項
enum CategoryColor: CaseIterable {
    case red, orange, yellow, green, blue, purple, pink, brown, gray, black
    
    var hexValue: String {
        switch self {
        case .red: return "#FF6B6B"
        case .orange: return "#FF8E53"
        case .yellow: return "#FFD93D"
        case .green: return "#6BCF7F"
        case .blue: return "#4D96FF"
        case .purple: return "#9775FA"
        case .pink: return "#FF8CC8"
        case .brown: return "#A0522D"
        case .gray: return "#8E8E93"
        case .black: return "#1C1C1E"
        }
    }
}

#Preview {
    CategoryCreationSheet()
        .modelContainer(for: [Category.self], inMemory: true)
}