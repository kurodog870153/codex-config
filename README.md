# codex-config

將此專案的 `AGENTS.md` 安裝至指定目錄，供其他專案使用相同的 AI 工作規範。

## 功能

1. 執行時要求輸入目標目錄。
2. 目標目錄不存在時，詢問是否建立。
3. 目標目錄已有 `AGENTS.md` 時，詢問是否覆寫。
4. 將腳本所在目錄的 `AGENTS.md` 複製到目標目錄。
5. 支援包含空格的目錄路徑。

## 檔案

1. `AGENTS.md`：要安裝的 AI 工作規範。
2. `install-agents.bat`：Windows 雙擊執行腳本。
3. `install-agents.command`：macOS 雙擊執行腳本。

請將 `AGENTS.md` 與對應平台的腳本放在同一個目錄中。

## Windows 使用方式

1. 雙擊 `install-agents.bat`。
2. 輸入要安裝 `AGENTS.md` 的目標目錄，例如：

   ```text
   C:\Users\username\Projects\my-project
   ```

3. 如果目錄不存在，按 `Y` 建立，或按 `N` 取消。
4. 如果目標目錄已有 `AGENTS.md`，按 `Y` 覆寫，或按 `N` 取消。
5. 確認成功訊息後，按任意鍵關閉視窗。

## macOS 使用方式

1. 雙擊 `install-agents.command`。
2. 如果 macOS 阻止首次執行，請在 Finder 中對檔案按右鍵，選擇「打開」，再確認執行。
3. 輸入要安裝 `AGENTS.md` 的目標目錄，例如：

   ```text
   ~/Projects/my-project
   ```

4. 如果目錄不存在，輸入 `y` 建立；輸入其他內容則取消。
5. 如果目標目錄已有 `AGENTS.md`，輸入 `y` 覆寫；輸入其他內容則取消。
6. 確認成功訊息後，按 Enter 鍵關閉視窗。

若腳本無法雙擊執行，可在終端機中設定執行權限後再開啟：

```bash
chmod +x install-agents.command
```

## 注意事項

1. 腳本只會複製 `AGENTS.md`，不會修改其內容。
2. 來源 `AGENTS.md` 不存在時，腳本會顯示錯誤並停止。
3. 建立目錄或複製檔案失敗時，請確認目標位置的寫入權限。
4. 覆寫既有 `AGENTS.md` 前，請確認不需要保留原有內容。
