# codex-config

集中管理 Codex 的全域 AI 工作規範、分層工作流程與跨平台維護腳本。

## 功能

1. 提供共用的 `AGENTS.md` AI 工作規範。
2. 提供 `plan`、`task`、`execute` 三個 Codex 技能。
3. 依工作類型與技術領域載入分層 `AGENTS.md` 指令。
4. 使用獨立安裝器安裝全域規範、個別技能與對應的工作規則。
5. 動態列出技能的可選工作規則，不需在新增規則後修改安裝器。
6. 安裝個人或專案層級的本機 Marketing plugin 與 marketplace entry。
7. 提供 Windows 與 macOS 的本機 Codex 資料清理腳本。

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
├── plugins/
│   └── marketing/
└── os-scripts/
    ├── mac/
    │   ├── install-global-agents.command
    │   ├── install-plan.command
    │   ├── install-task.command
    │   ├── install-execute.command
    │   ├── install-marketing-plugin.command
    │   └── clean-codex-data.command
    └── windows/
        ├── install-global-agents.bat
        ├── install-plan.bat
        ├── install-task.bat
        ├── install-execute.bat
        ├── install-marketing-plugin.bat
        └── clean-codex-data.bat
```

## 核心元件

1. `AGENTS.md`：全域 AI 工作規範，包含需求釐清、執行授權、實作、驗證、Git 與安全規則。
2. `skills/plan`：載入用於建立、修改、檢視或執行計畫的分層規則。
3. `skills/task`：載入用於建立、修改、檢視或維護任務文件的分層規則。
4. `skills/execute`：載入用於執行指定 `TASK-*` 任務的分層規則。
5. `work/`：依技能、工作類型與技術領域存放可組合的 `AGENTS.md`。
6. `plugins/marketing`：提供品牌管理、行銷文案、行銷圖片與完整創意流程。
7. `os-scripts/`：提供 Windows 與 macOS 的獨立安裝及清理工具。

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

每項功能都有獨立的 macOS 與 Windows 安裝器。除個人層級的 Marketing plugin 外，安裝器會要求輸入目標根目錄。

若目標已有同名內容，安裝器會先要求確認，再合併目錄並覆寫名稱相同的檔案。

### 全域規範

`install-global-agents` 只安裝專案根目錄的 `AGENTS.md`：

1. macOS：`os-scripts/mac/install-global-agents.command`
2. Windows：`os-scripts/windows/install-global-agents.bat`
3. 來源：本專案的 `./AGENTS.md`
4. 目標：`<目標根目錄>/AGENTS.md`

### 技能與工作規則

三個技能分別使用以下安裝器：

1. Plan：`install-plan.command` 或 `install-plan.bat`
2. Task：`install-task.command` 或 `install-task.bat`
3. Execute：`install-execute.command` 或 `install-execute.bat`

每個技能安裝器必定安裝：

1. `skills/<skill>/`
2. `work/<skill>/general/AGENTS.md`

安裝器會動態掃描 `work/<skill>/**/AGENTS.md`，並以編號列出 general 以外的規則：

1. 輸入以空白分隔的編號可複選，例如 `1 3 5`。
2. 輸入 `all` 可安裝全部可選規則。
3. 直接按 Enter 則只安裝 skill 與 general。
4. 選擇深層規則時，會自動包含所有實際存在的上層規則。
5. 未來新增 `AGENTS.md` 後，不需修改安裝器。

例如選擇 `web/backend/java` 時，若以下規則都存在，會一併安裝：

```text
web
web/backend
web/backend/java
```

若某個上層沒有 `AGENTS.md`，安裝器不會建立不存在的規則。

### Marketing plugin

使用以下安裝器安裝完整的 `plugins/marketing`：

1. macOS：`os-scripts/mac/install-marketing-plugin.command`
2. Windows：`os-scripts/windows/install-marketing-plugin.bat`

執行時可選擇：

1. 個人層級：
   1. Plugin 安裝至 `~/.codex/plugins/marketing`。
   2. Marketplace 使用 `~/.agents/plugins/marketplace.json`。
   3. 新 marketplace 使用 `personal`／`Personal`。
2. 專案層級：
   1. Plugin 安裝至 `<專案根目錄>/plugins/marketing`。
   2. Marketplace 使用 `<專案根目錄>/.agents/plugins/marketplace.json`。
   3. Marketplace 名稱由專案資料夾名稱正規化產生。

安裝器會保留既有 marketplace 的名稱、顯示名稱、其他 plugin entry 與順序，只新增或更新 `marketing` entry。目標 plugin manifest 會加入 cachebuster，來源 manifest 不會被修改。

檔案準備完成後，可選擇立即執行 Codex CLI 安裝或重新安裝。專案層級會先註冊 marketplace；完成後請開啟新的對話，讓 Codex 載入更新後的 plugin。

完整的 plugin 安裝與 marketplace 規格請參考 [OpenAI Plugins 文件](https://developers.openai.com/plugins/build/plugins)。

### 執行安裝器

#### Windows

1. 雙擊要安裝之功能的 `.bat`。
2. 依提示選擇功能選項並輸入目標目錄。
3. 確認完成訊息後按任意鍵關閉視窗。

#### macOS

1. 雙擊要安裝之功能的 `.command`。
2. 若 macOS 阻止首次執行，請在 Finder 中對檔案按右鍵，選擇「打開」。
3. 依提示選擇功能選項並輸入目標目錄。
4. 確認完成訊息後按 Enter 關閉視窗。

若腳本無法執行，可在終端機設定權限：

```bash
chmod +x os-scripts/mac/install-*.command
```

## 清理本機 Codex 資料

> [!WARNING]
> 清理腳本會永久刪除本機 Codex 工作階段、封存工作階段、產生的圖片、歷史紀錄與相關狀態資料。執行前請先關閉 Codex，並確認不需要保留這些資料。

### Windows

1. 關閉 Codex。
2. 雙擊 `os-scripts/windows/clean-codex-data.bat`。
3. 確認顯示的刪除範圍。
4. 輸入確認後執行清理。

### macOS

1. 關閉 Codex。
2. 雙擊 `os-scripts/mac/clean-codex-data.command`。
3. 確認顯示的刪除範圍。
4. 輸入 `y` 後執行清理。

若腳本無法執行，可設定權限：

```bash
chmod +x os-scripts/mac/clean-codex-data.command
```

## 注意事項

1. 獨立安裝器不會修改來源規範、技能、工作規則或 plugin。
2. 安裝前請確認目標目錄內的既有規範與技能是否需要保留。
3. 安裝至 `~/.codex` 時，內容會成為使用者層級設定。
4. 安裝至專案根目錄時，內容會成為該專案的設定。
5. 要安裝舊版整合安裝器的全部內容，請分別執行 global、plan、task、execute 安裝器，並在三個技能安裝器中選擇 `all`。
6. Marketing plugin 的 cachebuster 只會修改安裝目標副本。
7. 清理腳本造成的資料刪除無法由腳本復原。
