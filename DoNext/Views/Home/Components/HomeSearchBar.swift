//
//  HomeSearchBar.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 首頁搜索欄元件
/// 提供待辦事項搜索功能的獨立元件
struct HomeSearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
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
}

#Preview {
    @State var searchText = ""
    return HomeSearchBar(searchText: $searchText)
}