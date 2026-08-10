# Java 後端任務規劃規範

1. 唯讀確認 Java 版本、模組、Wrapper、JUnit、Surefire／Failsafe、測試位置及既有命令；TASK 只保存確認事實與正式 `CMD/VAL`，有 Wrapper 時必須使用。
2. 僅當 TASK 新增或變更 Java／Spring、編譯 release、Wrapper、Maven／Gradle、依賴／外掛、JUnit、Surefire／Failsafe，或需求涉及版本相容性時，核准前依官方第一方資料固定唯一相容版本組合；來源不足、衝突或仍有候選時維持對話草案。其他 TASK 沿用可唯讀確認的既有固定版本，不另做相容性研究或建立 `版本基準`。
3. 前款適用時，版本使用精確值或由精確 parent、BOM、Wrapper 唯一推導，不得使用 `latest`、範圍或候選版本；以正式 `CMD/VAL` 驗證實際版本與完整建置測試，官方資料或單獨的 `BUILD SUCCESS` 不得取代驗證。
4. 需要 `版本基準` 時，只影響一個 TASK 則在該 TASK 使用 `版本基準：<元件=精確值或唯一推導來源>`；影響至少兩個 TASK 則在文件層以 `DECISION-*` 保存同一格式，並由各適用 TASK 使用 `版本基準：<DECISION-ID>` 引用。不得在其他文字另訂第二組版本值。
5. 每個 `版本基準` 須有唯一 `相容性依據`，逐項記錄官方第一方來源的可重現定位與支持結論；只有搜尋結果、來源名稱或無依據的「相容」不得核准。
6. 需要 `版本基準` 但靜態資訊不足時維持對話草案；可能產生建置輸出的 Maven／Gradle 預檢須先取得授權。
7. 使用 Spring Initializr 或其他專案產生器時，核准前須固定產生器版本與全部參數，並依目前實際回應或產物清單逐項核對 TASK 的「建立」路徑及必要建置設定；不得只依歷史範本或文件推測輸出。
8. CMD 依目標 shell 產生，PowerShell 使用參數陣列，zsh／bash 個別引用參數；Maven reactor 使用 `-am` 指定測試時先分析上游，只有上游需要時才加入 `failIfNoSpecifiedTests=false`。
9. VAL 必須確認目標模組實際執行、指定測試類被發現且測試數大於 0；不得只以 `BUILD SUCCESS` 判定通過。
10. 遵循既有分層；TASK 只記本次必要的責任、交易、模型轉換及核准例外。
11. MyBatis TASK 核准前必須固定唯一映射責任、null 行為、enum 轉換、alias、`notNullColumn` 及對應測試。
