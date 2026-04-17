#!/bin/bash

# 1. 取得目標 Session (優先使用目前的 tmux session)
TARGET_SESSION=${TMUX_PANE:+$(tmux display-message -p '#S')}
TARGET_SESSION=${TARGET_SESSION:-$(tmux ls -F '#S' | head -n 1)}

# 如果根本沒在運行 tmux，直接回傳失敗
if [ -z "$TARGET_SESSION" ]; then
    exit 1
fi

# 2. 取得所有連線中的 TTY 並去掉 /dev/ 前綴
# 使用 mapfile (bash 4+) 或傳統迴圈讀取
TTY_LIST=$(tmux list-clients -t "$TARGET_SESSION" -F "#{client_tty}" | sed 's|/dev/||')

# 3. 檢查來源
for tty in $TTY_LIST; do
    # 擷取 who 輸出中括號內的內容 (連線來源)
    # 例如: (100.99.227.35) 或 (tmux(2178066).%22)
    origin=$(who | grep "$tty" | awk -F'[()]' '{print $2}')

    # 判斷邏輯：
    # 如果來源「存在」且「不是 : 開頭」且「不是 tmux 開頭」
    # 則認定為遠端 SSH 連線
    if [[ -n "$origin" && ! "$origin" =~ ^: && ! "$origin" =~ ^tmux ]]; then
        # 發現 SSH 連線，以狀態碼 0 (成功) 離開
        exit 0
    fi
done

# 跑完迴圈都沒發現 SSH 來源，以狀態碼 1 (失敗) 離開
exit 1
