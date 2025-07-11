//
//  HomeCategoryTabs.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 分類位置追蹤 PreferenceKey
struct CategoryPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGPoint] = [:]
    
    static func reduce(value: inout [String: CGPoint], nextValue: () -> [String: CGPoint]) {
        value.merge(nextValue()) { $1 }
    }
}

/// 首頁分類標籤頁元件
/// 顯示所有分類標籤和新增分類按鈕
struct HomeCategoryTabs: View {
    let categories: [Category]
    @Binding var selectedIndex: Int
    let allTodosCount: Int
    let onCategorySelected: (Int) -> Void
    let onAddCategory: () -> Void
    let onCategoryLongPress: (Category) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 全部分類標籤
                CategoryTab(
                    title: "全部",
                    color: .blue,
                    isSelected: selectedIndex == 0,
                    count: allTodosCount,
                    action: {
                        onCategorySelected(0)
                    },
                    onLongPress: nil
                )
                
                // 各分類標籤
                ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                    CategoryTab(
                        title: category.name,
                        color: Color(hex: category.color),
                        isSelected: selectedIndex == index + 1,
                        count: category.todos.count,
                        action: {
                            onCategorySelected(index + 1)
                        },
                        onLongPress: {
                            onCategoryLongPress(category)
                        }
                    )
                }
                
                // 新增分類按鈕
                AddCategoryButton {
                    onAddCategory()
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Action Bar 邏輯已移至 HomeView 層級
}

#Preview {
    @State var selectedIndex = 0
    return HomeCategoryTabs(
        categories: [],
        selectedIndex: $selectedIndex,
        allTodosCount: 5,
        onCategorySelected: { _ in },
        onAddCategory: { },
        onCategoryLongPress: { _ in }
    )
}