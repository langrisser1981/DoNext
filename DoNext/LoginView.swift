//
//  LoginView.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI

/// 登入視圖
/// 提供 Apple Sign-In 和 Google Sign-In 的登入選項
struct LoginView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // 頂部 Logo 區域
                    logoSection
                        .frame(height: geometry.size.height * 0.4)
                    
                    // 登入選項區域
                    loginOptionsSection
                        .frame(minHeight: geometry.size.height * 0.6)
                }
            }
            .background(backgroundGradient)
            .ignoresSafeArea()
        }
        .alert("登入失敗", isPresented: $showAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    /// 背景漸層
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.1),
                Color.purple.opacity(0.1),
                Color.white
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Logo 區域
    private var logoSection: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // App Logo
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
            
            // App 名稱
            Text("DoNext")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // 副標題
            Text("讓待辦事項管理變得簡單")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    /// 登入選項區域
    private var loginOptionsSection: some View {
        VStack(spacing: 30) {
            // 歡迎文字
            VStack(spacing: 8) {
                Text("歡迎回來")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("選擇您喜歡的登入方式")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // 登入按鈕群組
            VStack(spacing: 16) {
                // Apple Sign-In 按鈕
                AppleSignInButton {
                    signInWithApple()
                }
                .disabled(isLoading)
                
                // Google Sign-In 按鈕
                GoogleSignInButton {
                    signInWithGoogle()
                }
                .disabled(isLoading)
            }
            .padding(.horizontal, 40)
            
            // 載入指示器
            if isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .padding(.top, 20)
            }
            
            Spacer()
            
            // 隱私政策和使用條款
            VStack(spacing: 8) {
                Text("繼續使用即表示您同意我們的")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Button("隱私政策") {
                        // TODO: 開啟隱私政策
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    
                    Text("和")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("使用條款") {
                        // TODO: 開啟使用條款
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color.white)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    /// 使用 Apple Sign-In 登入
    private func signInWithApple() {
        Task {
            await performSignIn(strategy: AppleSignInStrategy())
        }
    }
    
    /// 使用 Google Sign-In 登入
    private func signInWithGoogle() {
        Task {
            await performSignIn(strategy: GoogleSignInStrategy())
        }
    }
    
    /// 執行登入流程
    /// - Parameter strategy: 登入策略
    private func performSignIn(strategy: AuthenticationStrategy) async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            appCoordinator.setAuthStrategy(strategy)
            try await appCoordinator.signIn()
        } catch {
            await MainActor.run {
                isLoading = false
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
}

/// Apple Sign-In 按鈕
/// 模擬 Apple Sign-In 按鈕的外觀和行為
struct AppleSignInButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "applelogo")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                
                Text("使用 Apple 登入")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.black)
            .cornerRadius(25)
        }
        .buttonStyle(LoginButtonStyle())
    }
}

/// Google Sign-In 按鈕
/// 模擬 Google Sign-In 按鈕的外觀和行為
struct GoogleSignInButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Google Logo (使用系統圖標模擬)
                Image(systemName: "globe")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.red)
                
                Text("使用 Google 登入")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(25)
        }
        .buttonStyle(LoginButtonStyle())
    }
}

/// 登入按鈕樣式
/// 為登入按鈕提供統一的互動效果
struct LoginButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}


// MARK: - 預覽

#Preview {
    LoginView()
        .environmentObject(AppCoordinator())
}