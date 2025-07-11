//
//  HomeFloatingAddButton.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 首頁浮動新增按鈕元件
/// 提供快速新增待辦事項的浮動按鈕
struct HomeFloatingAddButton: View {
    let onAddTodo: () -> Void
    
    var body: some View {
        Button(action: onAddTodo) {
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
}

#Preview {
    HomeFloatingAddButton(onAddTodo: { })
}