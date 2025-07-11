#!/bin/bash

# DoNext 專案程式碼統計腳本 (簡化版)
echo "🚀 DoNext 專案程式碼統計"
echo "=========================="
echo ""

# 專案根目錄
PROJECT_DIR="."

# Swift 檔案統計 (排除測試)
echo "📊 主要程式碼統計"
echo "----------------"
swift_files=$(find $PROJECT_DIR -name "*.swift" -type f | grep -v ".git" | grep -v "Test" | wc -l)
swift_lines=$(find $PROJECT_DIR -name "*.swift" -type f | grep -v ".git" | grep -v "Test" | xargs wc -l 2>/dev/null | tail -n 1 | awk '{print $1}')

echo "Swift 檔案: $swift_files 個"
echo "Swift 程式碼: $swift_lines 行"
echo ""

# 測試檔案統計
echo "🧪 測試程式碼統計"
echo "----------------"
test_files=$(find $PROJECT_DIR -path "*Test*" -name "*.swift" -type f | grep -v ".git" | wc -l)
test_lines=$(find $PROJECT_DIR -path "*Test*" -name "*.swift" -type f | grep -v ".git" | xargs wc -l 2>/dev/null | tail -n 1 | awk '{print $1}' 2>/dev/null || echo "0")

echo "測試檔案: $test_files 個"
echo "測試程式碼: $test_lines 行"
echo ""

# 配置檔案統計
echo "📁 配置和文件"
echo "------------"
plist_files=$(find $PROJECT_DIR -name "*.plist" -type f | grep -v ".git" | wc -l)
md_files=$(find $PROJECT_DIR -name "*.md" -type f | grep -v ".git" | wc -l)
asset_folders=$(find $PROJECT_DIR -name "*.xcassets" -type d | wc -l)

echo "Plist 檔案: $plist_files 個"
echo "Markdown 檔案: $md_files 個"
echo "Asset Catalogs: $asset_folders 個"
echo ""

# 架構分析
echo "🏗️ 架構分析"
echo "----------"
models=$(find $PROJECT_DIR -path "*/Models/*" -name "*.swift" | wc -l)
views=$(find $PROJECT_DIR -path "*/Views/*" -name "*.swift" | wc -l)
coordinators=$(find $PROJECT_DIR -path "*/Coordinators/*" -name "*.swift" | wc -l)
services=$(find $PROJECT_DIR -path "*/Services/*" -name "*.swift" | wc -l)
viewmodels=$(find $PROJECT_DIR -path "*/ViewModels/*" -name "*.swift" | wc -l)

echo "Models: $models 個檔案"
echo "Views: $views 個檔案"
echo "Coordinators: $coordinators 個檔案"
echo "Services: $services 個檔案"
echo "ViewModels: $viewmodels 個檔案"
echo ""

# 總計
echo "📈 總計"
echo "------"
total_files=$((swift_files + test_files + plist_files + md_files))
total_lines=$((swift_lines + test_lines))
avg_lines=$((swift_lines / swift_files))

echo "總檔案數: $total_files 個"
echo "總程式碼行數: $total_lines 行"
echo "平均每個 Swift 檔案: $avg_lines 行"
echo ""

# Git 統計
if [ -d ".git" ]; then
    echo "📊 Git 統計"
    echo "----------"
    commits=$(git rev-list --count HEAD 2>/dev/null)
    echo "總提交數: $commits 次"
    echo ""
    
    echo "最近 3 次提交:"
    git log --oneline -3 2>/dev/null
    echo ""
fi

# 詳細檔案列表
echo "📋 主要檔案列表 (按行數排序)"
echo "---------------------------"
find $PROJECT_DIR -name "*.swift" -type f | grep -v ".git" | grep -v "Test" | while read file; do
    lines=$(wc -l < "$file" 2>/dev/null)
    basename=$(basename "$file")
    dirname=$(dirname "$file" | sed "s|$PROJECT_DIR/||")
    printf "%-50s %4d 行\n" "$dirname/$basename" "$lines"
done | sort -k2 -nr | head -15

echo ""
echo "📅 統計時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "✅ 統計完成！"