# codex-config

集中管理 Codex 的全域 AI 工作規範、分層工作流程與跨平台維護腳本。

## 功能

1. 提供共用的 `AGENTS.md` AI 工作規範。
2. 提供 `plan`、`task`、`execute` 三個 Codex 技能。
3. 依工作類型與技術領域載入分層 `AGENTS.md` 指令。
4. 將規範、技能與工作規則安裝至指定目錄。
5. 提供 Windows 與 macOS 的本機 Codex 工作階段清理腳本。

## 專案結構

```text
.
├── AGENTS.md
├── skills/
│   ├── plan/
│   ├── task/
│   └── execute/
├── work/
│   ├── plan/
│   ├── task/
│   └── execute/
└── os-scripts/
    ├── mac/
    │   ├── install-agents.command
    │   └── clean-codex-sessions.command
    └── windows/
        ├── install-agents.bat
        └── clean-codex-sessions.bat
```

## 核心元件

1. `AGENTS.md`：全域 AI 工作規範，包含需求釐清、執行授權、實作、驗證、Git 與安全規則。
2. `skills/plan`：載入用於建立、修改、檢視或執行計畫的分層規則。
3. `skills/task`：載入用於建立、修改、檢視或維護任務文件的分層規則。
4. `skills/execute`：載入用於執行指定 `TASK-*` 任務的分層規則。
5. `work/`：依技能、工作類型與技術領域存放可組合的 `AGENTS.md`。
6. `os-scripts/`：提供 Windows 與 macOS 的安裝及清理工具。

## 分層規則

三個技能都會由一般規則開始，再依名稱逐層載入更具體的規則。

例如：

```text
general
web
web/backend
web/backend/java
```

每一層會依序尋找：

```text
~/.codex/work/<skill>/<resolved-path>/AGENTS.md
<project-root>/work/<skill>/<resolved-path>/AGENTS.md
```

其中 `<skill>` 為 `plan`、`task` 或 `execute`。

同一層若同時存在使用者層級與專案層級規則，會先載入使用者層級，再載入專案層級；較後載入的同權限規則優先。

## 技能使用方式

### Plan

使用 `$plan` 載入計畫規則：

```text
$plan web backend java
```

解析順序如下：

```text
general
web
web/backend
web/backend/java
```

### Task

使用 `$task` 載入任務規劃規則：

```text
$task web backend java
```

載入規則本身不會建立、修改或執行任務，仍須由使用者明確提出要求並授權。

### Execute

使用 `$execute` 載入任務執行規則：

```text
$execute web backend java
```

執行任務時，使用者還必須指定：

1. `./tasks/<plan-name>.md` 任務文件。
2. 該文件內的一個 `TASK-*` 識別碼。

載入執行規則本身不代表已授權修改檔案或執行具副作用的操作。

## 安裝

安裝腳本會將以下內容複製至指定目錄：

1. `AGENTS.md`
2. `work/`
3. `skills/`

如果目標已有同名檔案或目錄，腳本會先要求確認。既有目錄會與來源內容合併，名稱相同的檔案會被覆寫。

### Windows

1. 雙擊 `os-scripts/windows/install-agents.bat`。
2. 輸入目標目錄。
3. 依提示確認是否建立目錄或覆寫既有內容。
4. 確認完成訊息後按任意鍵關閉視窗。

### macOS

1. 雙擊 `os-scripts/mac/install-agents.command`。
2. 若 macOS 阻止首次執行，請在 Finder 中對檔案按右鍵，選擇「打開」。
3. 輸入目標目錄。
4. 依提示確認是否建立目錄或覆寫既有內容。
5. 確認完成訊息後按 Enter 關閉視窗。

若腳本無法執行，可在終端機設定權限：

```bash
chmod +x os-scripts/mac/install-agents.command
```

## 清理本機 Codex 工作階段

> [!WARNING]
> 清理腳本會永久刪除本機 Codex 工作階段、封存工作階段、歷史紀錄與相關狀態資料。執行前請先關閉 Codex，並確認不需要保留這些資料。

### Windows

1. 關閉 Codex。
2. 雙擊 `os-scripts/windows/clean-codex-sessions.bat`。
3. 確認顯示的刪除範圍。
4. 輸入確認後執行清理。

### macOS

1. 關閉 Codex。
2. 雙擊 `os-scripts/mac/clean-codex-sessions.command`。
3. 確認顯示的刪除範圍。
4. 輸入 `y` 後執行清理。

若腳本無法執行，可設定權限：

```bash
chmod +x os-scripts/mac/clean-codex-sessions.command
```

## 注意事項

1. 安裝腳本不會修改來源檔案。
2. 安裝前請確認目標目錄內的既有規範與技能是否需要保留。
3. 安裝至 `~/.codex` 時，內容會成為使用者層級設定。
4. 安裝至專案根目錄時，內容會成為該專案的設定。
5. 清理腳本造成的資料刪除無法由腳本復原。
