#!/bin/bash

# DoNext 專案程式碼統計腳本
# 統計 Swift、SwiftUI 相關程式碼的行數和檔案數量

echo "🚀 DoNext 專案程式碼統計"
echo "=========================="
echo ""

# 設定顏色
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 專案根目錄
PROJECT_DIR="."

# 統計函數
count_files() {
    local pattern=$1
    local description=$2
    local files=$(find $PROJECT_DIR -name "$pattern" -type f | grep -v ".git" | grep -v "DerivedData" | grep -v ".build")
    local count=$(echo "$files" | grep -c "^" 2>/dev/null || echo "0")
    local lines=0
    
    if [ $count -gt 0 ]; then
        lines=$(echo "$files" | xargs wc -l 2>/dev/null | tail -n 1 | awk '{print $1}')
    fi
    
    printf "${CYAN}%-25s${NC}: ${GREEN}%3d files${NC}, ${YELLOW}%6d lines${NC}\n" "$description" "$count" "$lines"
    
    # 回傳行數用於總計
    echo $lines
}

# 列出檔案詳情函數
list_files() {
    local pattern=$1
    local description=$2
    find $PROJECT_DIR -name "$pattern" -type f | grep -v ".git" | grep -v "DerivedData" | grep -v ".build" | while read file; do
        local lines=$(wc -l < "$file" 2>/dev/null || echo "0")
        printf "  ${BLUE}%-50s${NC}: ${YELLOW}%4d lines${NC}\n" "$(basename "$file")" "$lines"
    done
}

echo "${PURPLE}📊 程式碼統計${NC}"
echo "----------------"

# 統計各類型檔案
swift_lines=$(count_files "*.swift" "Swift 檔案")
swiftui_lines=$(find $PROJECT_DIR -name "*.swift" -type f | grep -v ".git" | xargs grep -l "SwiftUI\|View\|@State\|@Binding" 2>/dev/null | wc -l | awk '{print $1}')
storyboard_lines=$(count_files "*.storyboard" "Storyboard 檔案")
xib_lines=$(count_files "*.xib" "XIB 檔案")

echo ""
echo "${PURPLE}📁 配置檔案${NC}"
echo "----------------"
plist_lines=$(count_files "*.plist" "Plist 檔案")
xcconfig_lines=$(count_files "*.xcconfig" "Xcconfig 檔案")
entitlements_lines=$(count_files "*.entitlements" "Entitlements 檔案")

echo ""
echo "${PURPLE}📖 文件檔案${NC}"
echo "----------------"
md_lines=$(count_files "*.md" "Markdown 檔案")
txt_lines=$(count_files "*.txt" "文字檔案")

echo ""
echo "${PURPLE}🧪 測試檔案${NC}"
echo "----------------"
test_swift_lines=$(find $PROJECT_DIR -path "*Test*" -name "*.swift" -type f | grep -v ".git" | wc -l | awk '{print $1}')
test_lines=$(find $PROJECT_DIR -path "*Test*" -name "*.swift" -type f | grep -v ".git" | xargs wc -l 2>/dev/null | tail -n 1 | awk '{print $1}' || echo "0")
printf "${CYAN}%-25s${NC}: ${GREEN}%3d files${NC}, ${YELLOW}%6d lines${NC}\n" "測試檔案" "$test_swift_lines" "$test_lines"

echo ""
echo "${PURPLE}🎨 資源檔案${NC}"
echo "----------------"
asset_count=$(find $PROJECT_DIR -name "*.xcassets" -type d | wc -l | awk '{print $1}')
printf "${CYAN}%-25s${NC}: ${GREEN}%3d folders${NC}\n" "Asset Catalogs" "$asset_count"

echo ""
echo "=========================="
echo "${RED}📈 總計統計${NC}"
echo "=========================="

# 計算總行數（排除測試檔案）
main_swift_lines=$(find $PROJECT_DIR -name "*.swift" -type f | grep -v ".git" | grep -v "Test" | xargs wc -l 2>/dev/null | tail -n 1 | awk '{print $1}' || echo "0")
main_swift_files=$(find $PROJECT_DIR -name "*.swift" -type f | grep -v ".git" | grep -v "Test" | wc -l | awk '{print $1}')

total_lines=$((main_swift_lines + plist_lines + md_lines))
total_files=$((main_swift_files + $(find $PROJECT_DIR -name "*.plist" -type f | wc -l | awk '{print $1}') + $(find $PROJECT_DIR -name "*.md" -type f | wc -l | awk '{print $1}')))

printf "${GREEN}主要程式碼檔案${NC}: ${YELLOW}%d files, %d lines${NC}\n" "$main_swift_files" "$main_swift_lines"
printf "${GREEN}總計 (含配置+文件)${NC}: ${YELLOW}%d files, %d lines${NC}\n" "$total_files" "$total_lines"

echo ""
echo "${PURPLE}📋 主要 Swift 檔案列表${NC}"
echo "------------------------"
find $PROJECT_DIR -name "*.swift" -type f | grep -v ".git" | grep -v "Test" | sort | while read file; do
    lines=$(wc -l < "$file" 2>/dev/null || echo "0")
    relative_path=$(echo "$file" | sed "s|$PROJECT_DIR/||")
    printf "${BLUE}%-60s${NC}: ${YELLOW}%4d lines${NC}\n" "$relative_path" "$lines"
done

echo ""
echo "${PURPLE}📊 程式碼複雜度分析${NC}"
echo "--------------------"

# 統計不同類型的 Swift 檔案
models_count=$(find $PROJECT_DIR -path "*/Models/*" -name "*.swift" | wc -l | awk '{print $1}')
views_count=$(find $PROJECT_DIR -path "*/Views/*" -name "*.swift" | wc -l | awk '{print $1}')
coordinators_count=$(find $PROJECT_DIR -path "*/Coordinators/*" -name "*.swift" | wc -l | awk '{print $1}')
services_count=$(find $PROJECT_DIR -path "*/Services/*" -name "*.swift" | wc -l | awk '{print $1}')

printf "${CYAN}Models 檔案${NC}: ${GREEN}%d files${NC}\n" "$models_count"
printf "${CYAN}Views 檔案${NC}: ${GREEN}%d files${NC}\n" "$views_count"
printf "${CYAN}Coordinators 檔案${NC}: ${GREEN}%d files${NC}\n" "$coordinators_count"
printf "${CYAN}Services 檔案${NC}: ${GREEN}%d files${NC}\n" "$services_count"

# 計算平均每檔案行數
if [ $main_swift_files -gt 0 ]; then
    avg_lines=$((main_swift_lines / main_swift_files))
    printf "${CYAN}平均每檔案行數${NC}: ${YELLOW}%d lines${NC}\n" "$avg_lines"
fi

echo ""
echo "${GREEN}✅ 統計完成！${NC}"
echo ""

# 產生 Git 統計
if command -v git &> /dev/null && [ -d ".git" ]; then
    echo "${PURPLE}📊 Git 統計${NC}"
    echo "------------"
    commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    printf "${CYAN}總提交數${NC}: ${YELLOW}%d commits${NC}\n" "$commit_count"
    
    # 最近的提交
    echo ""
    echo "${PURPLE}🕒 最近 5 次提交${NC}"
    echo "----------------"
    git log --oneline -5 2>/dev/null || echo "無法取得 Git 歷史"
fi

echo ""
echo "${BLUE}📅 統計時間: $(date '+%Y-%m-%d %H:%M:%S')${NC}"