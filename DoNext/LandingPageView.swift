//
//  LandingPageView.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI

/// 引導頁面視圖
/// 提供多頁面的應用程式介紹，包含頁面指示器和可配置的內容
struct LandingPageView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var currentPage = 0
    @State private var dragOffset: CGSize = .zero
    
    /// 引導頁面配置
    private let pages = OnboardingConfiguration.pages
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景漸層
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.3),
                        Color.purple.opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 頁面內容區域
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: geometry.size.height * 0.8)
                    
                    // 底部控制區域
                    VStack(spacing: 20) {
                        // 自定義頁面指示器
                        PageIndicator(
                            currentPage: currentPage,
                            totalPages: pages.count
                        )
                        
                        // 導航按鈕
                        NavigationButtons(
                            currentPage: currentPage,
                            totalPages: pages.count,
                            onNext: nextPage,
                            onPrevious: previousPage,
                            onSkip: skipOnboarding,
                            onGetStarted: completeOnboarding
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentPage)
    }
    
    /// 前往下一頁
    private func nextPage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentPage < pages.count - 1 {
                currentPage += 1
            }
        }
    }
    
    /// 前往上一頁
    private func previousPage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentPage > 0 {
                currentPage -= 1
            }
        }
    }
    
    /// 跳過引導流程
    private func skipOnboarding() {
        appCoordinator.completeOnboarding()
    }
    
    /// 完成引導流程
    private func completeOnboarding() {
        appCoordinator.completeOnboarding()
    }
}

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

// MARK: - 引導頁面配置

/// 引導頁面資料模型
/// 定義單一引導頁面的內容結構
struct OnboardingPage {
    /// 頁面標題
    let title: String
    
    /// 頁面描述
    let description: String
    
    /// 圖片名稱（可選）
    let imageName: String?
    
    /// 系統圖標名稱（可選，當沒有自定義圖片時使用）
    let systemImage: String?
    
    /// 初始化引導頁面
    /// - Parameters:
    ///   - title: 頁面標題
    ///   - description: 頁面描述
    ///   - imageName: 自定義圖片名稱
    ///   - systemImage: 系統圖標名稱
    init(title: String, description: String, imageName: String? = nil, systemImage: String? = nil) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.systemImage = systemImage
    }
}

/// 引導頁面配置
/// 包含所有引導頁面的內容配置
struct OnboardingConfiguration {
    /// 引導頁面列表
    /// 可以通過修改此陣列來自定義引導頁面的內容
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "歡迎使用 DoNext",
            description: "一個簡潔且強大的待辦事項管理應用程式，幫助您高效管理日常任務。",
            systemImage: "checkmark.circle.fill"
        ),
        OnboardingPage(
            title: "智能分類管理",
            description: "使用彩色分類標籤來組織您的待辦事項，讓任務管理更加直觀和有序。",
            systemImage: "folder.fill"
        ),
        OnboardingPage(
            title: "提醒與重複",
            description: "設定提醒時間和重複週期，確保重要任務不會被遺忘。",
            systemImage: "bell.fill"
        ),
        OnboardingPage(
            title: "雲端同步",
            description: "所有資料都會自動同步到 iCloud，讓您在任何設備上都能存取您的待辦事項。",
            systemImage: "icloud.fill"
        )
    ]
}

// MARK: - 預覽

#Preview {
    LandingPageView()
        .environmentObject(AppCoordinator())
}