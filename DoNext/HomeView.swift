//
//  HomeView.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI
import SwiftData

/// 主頁面視圖
/// 包含待辦事項列表、分類標籤頁和新增待辦事項的浮動按鈕
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    
    @Query private var categories: [Category]
    @Query private var allTodos: [TodoItem]
    
    @State private var selectedCategoryIndex = 0
    @State private var showingNewTodoSheet = false
    @State private var showingNewCategorySheet = false
    @State private var searchText = ""
    
    /// 當前選中的分類
    private var selectedCategory: Category? {
        guard selectedCategoryIndex > 0 && selectedCategoryIndex <= categories.count else {
            return nil
        }
        return categories[selectedCategoryIndex - 1]
    }
    
    /// 根據選中分類和搜索條件過濾的待辦事項
    private var filteredTodos: [TodoItem] {
        var todos = selectedCategory?.todos ?? allTodos
        
        if !searchText.isEmpty {
            todos = todos.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        return todos.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索欄
                searchSection
                
                // 分類標籤頁
                categoryTabs
                
                // 待辦事項列表
                todoList
            }
            .navigationTitle("DoNext")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("登出", role: .destructive) {
                            signOut()
                        }
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
            }
        }
        .overlay(
            // 浮動新增按鈕
            floatingAddButton,
            alignment: .bottomTrailing
        )
        .sheet(isPresented: $showingNewTodoSheet) {
            TodoCreationSheet(selectedCategory: selectedCategory)
        }
        .sheet(isPresented: $showingNewCategorySheet) {
            CategoryCreationSheet()
        }
    }
    
    /// 搜索區域
    private var searchSection: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("搜索待辦事項", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("取消") {
                        searchText = ""
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
    
    /// 分類標籤頁
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 全部分類標籤
                CategoryTab(
                    title: "全部",
                    color: .blue,
                    isSelected: selectedCategoryIndex == 0,
                    count: allTodos.count
                ) {
                    selectedCategoryIndex = 0
                }
                
                // 各分類標籤
                ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                    CategoryTab(
                        title: category.name,
                        color: Color(hex: category.color),
                        isSelected: selectedCategoryIndex == index + 1,
                        count: category.todos.count
                    ) {
                        selectedCategoryIndex = index + 1
                    }
                }
                
                // 新增分類按鈕
                AddCategoryButton {
                    showingNewCategorySheet = true
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    /// 待辦事項列表
    private var todoList: some View {
        Group {
            if filteredTodos.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(filteredTodos) { todo in
                        TodoRowView(todo: todo) {
                            toggleTodoCompletion(todo)
                        }
                    }
                    .onDelete(perform: deleteTodos)
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    /// 空狀態視圖
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.6))
            
            Text("還沒有待辦事項")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("點擊右下角的 + 按鈕來新增您的第一個待辦事項")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    /// 浮動新增按鈕
    private var floatingAddButton: some View {
        Button(action: {
            showingNewTodoSheet = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
    
    /// 切換待辦事項完成狀態
    private func toggleTodoCompletion(_ todo: TodoItem) {
        withAnimation(.easeInOut(duration: 0.2)) {
            todo.toggleCompleted()
        }
    }
    
    /// 刪除待辦事項
    private func deleteTodos(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredTodos[index])
            }
        }
    }
    
    /// 登出
    private func signOut() {
        Task {
            do {
                try await appState.signOut()
            } catch {
                print("登出失敗: \(error)")
            }
        }
    }
}

/// 分類標籤
struct CategoryTab: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.2) : Color.gray.opacity(0.2))
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color : Color.clear)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : color, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 新增分類按鈕
struct AddCategoryButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 待辦事項行視圖
struct TodoRowView: View {
    let todo: TodoItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 完成狀態按鈕
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(todo.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 待辦事項內容
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    .strikethrough(todo.isCompleted)
                
                HStack(spacing: 8) {
                    // 分類標籤
                    if let category = todo.category {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: category.color))
                                .frame(width: 6, height: 6)
                            
                            Text(category.name)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // 提醒時間
                    if let reminderDate = todo.reminderDate {
                        HStack(spacing: 4) {
                            Image(systemName: "bell")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                            
                            Text(reminderDate, style: .time)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}



// MARK: - 預覽

#Preview {
    HomeView()
        .environmentObject(AppState())
        .modelContainer(for: [TodoItem.self, Category.self], inMemory: true)
}