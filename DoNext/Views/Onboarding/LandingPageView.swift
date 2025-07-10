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
    @Environment(AppCoordinator.self) var appCoordinator
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

#Preview {
    LandingPageView()
        .environment(AppCoordinator())
}