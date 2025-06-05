#!/bin/bash

FOUND_FILE="branches_with_change.txt"
NOT_FOUND_FILE="branches_without_change.txt"

# 检查是否提供了 Change-ID 参数
if [ $# -ne 1 ]; then
    echo "Usage: $0 <Change-ID>"
    exit 1
fi
CHANGE_ID=$1

echo "Searching for Change-ID: $CHANGE_ID"

echo "Fetching latest remote information..."
git fetch --all > /dev/null 2>&1

echo "Getting all remote branches..."
REMOTE_BRANCHES=$(git branch -avv | grep -v HEAD | grep remotes/ | awk '{print $1}')

# 清空结果文件
> $FOUND_FILE
> $NOT_FOUND_FILE

# 计数器
TOTAL=0
FOUND=0
NOT_FOUND=0

# 遍历所有远程分支
for branch in $REMOTE_BRANCHES; do
    TOTAL=$((TOTAL + 1))
    echo -ne "Checking branch $TOTAL: $branch\r"
    
    # 使用 git log 查找 Change-ID
    if git log $branch --grep "$CHANGE_ID" | grep -q "$CHANGE_ID"; then
        echo "$branch" >> $FOUND_FILE
        FOUND=$((FOUND + 1))
    else
        echo "$branch" >> $NOT_FOUND_FILE
        NOT_FOUND=$((NOT_FOUND + 1))
    fi
done

echo -e "\n\nSearch completed!"
echo "Total branches checked: $TOTAL"
echo "Branches with Change-ID: $FOUND (see $FOUND_FILE)"
echo "Branches without Change-ID: $NOT_FOUND (see $NOT_FOUND_FILE)"

# 显示包含 Change-ID 的分支
echo -e "\nBranches containing the Change-ID:"
cat $FOUND_FILE
echo -e "\nResults saved to $FOUND_FILE and $NOT_FOUND_FILE"
