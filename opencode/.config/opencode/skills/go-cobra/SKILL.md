---
name: go-cobra
user_invocable: true
description: >
  Go Cobra CLI 重構陷阱手冊。當你需要將 Cobra CLI 從 flat 結構重構為 subpackage 結構（解決 import cycle），
  或遇到 init 執行順序問題時使用。涵蓋 init cycle 問題、sync.Once 陷阱、parent-child command 組合的正確時機。
---

# Go Cobra — Subpackage 重構陷阱手冊

## 背景問題

當 CLI 成長到需要分組（`pipeline gen`、`topic list`）時，flat 結構（所有 command 在同一 package）會遇到命名衝突。拆分子 package 時，會碰到 **import cycle** 和 **init 執行順序** 兩個核心問題。

## 標準解法：Cobra 官方的 blank import + parent-in-subpackage

Cobra 官方推薦的目錄結構：

```
cli/
  root.go              # rootCmd 定義（不 import 任何 subpackage）
  root_cmd.go          # root-level commands（import cliutil）
  root_init.go         # init() 中呼叫 AddCommand

cliutil/
  config.go            # 共享狀態（config、command references）

cli/topic/
  root.go              # TopicCmd 定義 + init() 中 SetTopicCmd
  topic.go             # list/add/rm commands + Register()

cli/pipeline/
  root.go              # PipelineCmd 定義 + init() 中 SetPipelineCmd
  pipeline.go          # gen/serve commands + Register()

main.go
  cli.Execute()
```

**核心原則**：
1. `cli/` 不直接 import `cli/topic/` 等 subpackages（避免 cycle）
2. `cli/` 只做 blank import `_ "cli/topic"` 觸發 subpackage 的 `init()`
3. Parent command（如 `TopicCmd`）定義在 subpackage 內
4. Subpackage 的 `init()` 負責把自己註冊到共享狀態

## 陷阱 1：Import Cycle

### 症狀
```
import cycle not allowed
  know_daily/cli imports know_daily/cli/topic
  know_daily/cli/topic imports know_daily/cli
```

### 原因
嘗試在 `cli/` 中 import subpackage 拿 parent command，再由 subpackage import `cli/` 拿函式或型別。

### 解法：cliutil 中介層

所有共享狀態放在 `cliutil/`：
- `cliutil.SetTopicCmd(cmd)` — subpackage 呼叫
- `cliutil.TopicCmd()` — `cli/` 呼叫
- `cli/` **不 import** `cli/topic/`、`cli/pipeline/`、`cli/draft/`
- `cli/` 只做 blank import `_ "cli/topic"` 觸發 init

## 陷阱 2：Go init() 執行順序

### 症狀
所有 command 都正確設定，但 `root.Commands()` 回傳空（subcommands 消失）。

### 原因：Go init() 的 alphabet ordering

Go 對**同一 package 內多個檔案**的 `init()` 執行順序是**字母序**，不是 import 依賴圖。

正確順序：
1. `cliutil/` 所有檔案
2. `cli/` 的所有檔案（按字母：`root.go`、`root_cmd.go`、`root_init.go`）
3. `cli/topic/`、`cli/pipeline/`、`cli/draft/`

但當 `cli/root.go` 的 `init()` 呼叫 `GetRoot()` 試圖 flush 所有 subpackage 的註冊時，**問題來了**：

### 問題鏈

```
cli/root.go init()        ← 第3個執行
  → cliutil.SetRoot(root)
  → GetRoot()              ← 此時 flush，但只拿到 3 個 regFunc
    → regFunc[0] (draft)  → Cmd.AddCommand() ✓
    → regFunc[1] (topic)  → Cmd.AddCommand() ✓
    → regFunc[2] (pipeline) → Cmd.AddCommand() ✓

cli/root_cmd.go init()     ← 第4個執行（！晚了）
  → cliutil.SetImportCmd(importCmd)
  → cliutil.Register(root.AddCommand(importCmd,...)) ← 永遠進不了 GetRoot() 的 flush
```

結果：`topic`、`pipeline`、`draft` parent commands 有 subcommands（`list`/`gen` 等），但 **root Commands() = 0**。

### 解法：從 main() 呼叫 GetRoot()

```go
// main.go
func main() {
    _ = cliutil.GetRoot()  // 在所有 init() 跑完後，觸發 flush
    cli.Execute()
}
```

這樣確保所有 4 個 Register()（draft/topic/pipeline 的 + root_cmd 的）都在同一個 flush 中執行。

## 陷阱 3：sync.Once + GetRoot() Re-entrancy Deadlock

### 症狀
程式 hang 住，無輸出，無錯誤。

### 原因
`GetRoot()` 使用 `sync.Once` 確保只 flush 一次。如果 `cli/root.go` 的 `init()` 呼叫 `GetRoot()`，flush 中執行 `root_cmd.go` 的 registration，該 registration 又呼叫 `GetRoot()`，則：

```
GetRoot() 第1次:
  flushOnce.Do(flush)
    → flush() 執行中（mutex 被持有）
      → registration 函式執行
        → GetRoot() 第2次
          → flushOnce.Do(flush) 嘗試再次取得 mutex
          → DEADLOCK（sync.Once 內部用同一把 mutex）
```

### 解法
1. `cli/root.go` 的 `init()` **不呼叫** `GetRoot()`
2. 改由 `main()` 呼叫（見上）
3. Registration 函式中使用** package-level 變數** `root`，不要呼叫 `GetRoot()`

```go
// cli/root_cmd.go
func init() {
    cliutil.Register(func() {
        root.AddCommand(...)        // 用 root 變數，別用 GetRoot()
    })
}
```

## 陷阱 4：Build 成功但 CLI 輸出只有 Short description

### 症狀
`go build` 成功，但 `./cli --help` 只輸出 `每日百科策展系統`，沒有 Usage 和 Commands。

### 原因
通常是 `go run`  cache 了舊 binary，或執行了錯誤的 binary。永遠用 `go build -o <name> .` 並確認執行的是剛編譯的版本。

### 解法
```bash
go clean -cache && go build -o know_daily . && ./know_daily --help
```

## cliutil Register 機制的完整流程

```
1. cliutil.Register(f)          → 將 f 加入 regFuncs[]
2. cliutil.SetRoot(root)        → 只設定 root 指標，不執行 flush
3. main() 中 GetRoot()          → sync.Once.Do(flush) 只執行一次
   → 執行所有 regFuncs[]
     → draft.Registration: Cmd.AddCommand(listCmd, publishCmd)
     → topic.Registration: Cmd.AddCommand(listCmd, addCmd, rmCmd)
     → pipeline.Registration: Cmd.AddCommand(genCmd, serveCmd)
     → root_cmd.Registration: root.AddCommand(topicCmd, pipelineCmd, draftCmd, importCmd, historyCmd, rebuildCmd)
4. root.Execute()
```

## 實作 Checklist

- [ ] `cliutil/` 放置所有共享 command references（`SetXxxCmd`/`XxxCmd`）
- [ ] `cliutil.Register(f)` 佇列化所有需要執行的組裝函式
- [ ] `cli/` 的 `init()` 只呼叫 `SetRoot(root)` 和設定 flags，**不呼叫 GetRoot()**
- [ ] `main()` 第一行呼叫 `_ = cliutil.GetRoot()`
- [ ] Registration 函式中用 package-level `root` 變數，**不用** `GetRoot()`
- [ ] Subpackages 只做 blank import `_ "cli/topic"`（不直接 import `cli/`）
- [ ] `go build` + `go vet` clean
- [ ] `go clean -cache && go build -o <bin> .` 確認 binary 最新

## 不要做的事

- **不要**在 `cli/` 中直接 import subpackage 拿 command（造成 cycle）
- **不要**在 `cli/root.go` 的 `init()` 中呼叫 `GetRoot()`（造成 re-entrancy 或順序問題）
- **不要**在 registration 中呼叫 `GetRoot()`（造成 re-entrancy deadlock）
- **不要**假設 `init()` 按 import 依賴圖執行（同 package 多檔案是字母序）
