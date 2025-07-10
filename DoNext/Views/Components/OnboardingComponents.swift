//
//  OnboardingComponents.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI

/// 單一引導頁面視圖
/// 顯示單頁的引導內容，包含圖片、標題和說明文字
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 圖片區域
            if let imageName = page.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 280, maxHeight: 280)
                    .cornerRadius(20)
            } else {
                // 預設圖片或系統圖標
                Image(systemName: page.systemImage ?? "star.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .frame(width: 120, height: 120)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
            }
            
            // 文字內容區域
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

/// 頁面指示器
/// 顯示當前頁面位置和總頁面數的視覺指示器
struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }
}

/// 導航按鈕組
/// 提供前進、後退、跳過和開始使用的按鈕
struct NavigationButtons: View {
    let currentPage: Int
    let totalPages: Int
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onSkip: () -> Void
    let onGetStarted: () -> Void
    
    var body: some View {
        HStack {
            // 左側按鈕
            if currentPage > 0 {
                Button("上一頁", action: onPrevious)
                    .foregroundColor(.secondary)
            } else {
                Button("跳過", action: onSkip)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 右側按鈕
            if currentPage < totalPages - 1 {
                Button("下一頁", action: onNext)
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
            } else {
                Button("開始使用", action: onGetStarted)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentPage)
    }
}