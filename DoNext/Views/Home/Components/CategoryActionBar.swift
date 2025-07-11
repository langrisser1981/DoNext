//
//  CategoryActionBar.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 分類動作列
/// 提供分類的編輯和刪除功能，以 Overlay 形式顯示
struct CategoryActionBar: View {
    let category: Category
    let onEdit: (Category) -> Void
    let onDelete: (Category) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            ActionButton(
                icon: "pencil",
                title: "編輯",
                color: .blue
            ) {
                onEdit(category)
            }
            
            ActionButton(
                icon: "trash",
                title: "刪除",
                color: .red
            ) {
                onDelete(category)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }
}

/// 三角形指向箭頭
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// 動作按鈕
private struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .fill(color.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
        
        CategoryActionBar(
            category: Category(name: "工作", color: "#FF6B6B"),
            onEdit: { _ in },
            onDelete: { _ in },
            onDismiss: { }
        )
    }
    .frame(height: 200)
}