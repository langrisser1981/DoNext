//
//  HomeView.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI
import SwiftData

/// 主頁面視圖 (Coordinator 版本)
/// 使用 HomeCoordinator 進行現代化的頁面導航管理
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppCoordinator.self) var appCoordinator
    
    private var homeCoordinator: HomeCoordinator? {
        appCoordinator.children.first { $0 is HomeCoordinator } as? HomeCoordinator
    }
    
    @Query private var categories: [Category]
    @Query private var allTodos: [TodoItem]
    
    @State private var selectedCategoryIndex = 0
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
                Button {
                    homeCoordinator?.showSettings()
                } label: {
                    Image(systemName: "person.circle")
                }
            }
        }
        .overlay(
            // 浮動新增按鈕
            floatingAddButton,
            alignment: .bottomTrailing
        )
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
                    homeCoordinator?.showCategoryCreation()
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
                        .onTapGesture {
                            homeCoordinator?.showTodoDetail(todo)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("刪除", role: .destructive) {
                                homeCoordinator?.showDeleteConfirmation(for: todo)
                            }
                        }
                    }
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
            homeCoordinator?.showTodoCreation(selectedCategory: selectedCategory)
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
}