# Java 後端任務執行規範

1. 執行前確認 Wrapper、目標 shell、模組、JUnit 及測試位置符合 TASK；不一致在 Attempt 建立前回報規格不符，執行中則以規格缺陷停止。
2. Attempt 建立前先依 task 規則判定是否需要 `版本基準`。需要時，只接受目標 TASK 內的基準，或其以 `版本基準：<DECISION-ID>` 引用的單一文件層 `DECISION-*`；缺少基準、引用不唯一、缺少 `相容性依據` 或其他文字另訂衝突版本時，回報規格不符且不建立 Attempt。無需基準時沿用專案既有設定，不要求補充版本研究。
3. 有 `版本基準` 時，依其與 TASK 固定環境唯讀核對可直接解析的 `JAVA_HOME`、`java`／`javac` 路徑與版本、編譯 release、Wrapper 設定及建置工具 distribution；指定環境不得改用系統 `PATH`。不得執行未列入 TASK 且可能初始化、下載或寫入資料的 Wrapper／建置命令；無法唯讀解析而只能由 TASK `CMD/VAL` 確認的版本，留待 Attempt 驗證。
4. 每個 `CMD-*` 使用 TASK 固定的環境；有 `版本基準` 時，另依 `CMD/VAL` 核對實際生效的 Java、編譯 release、Spring Boot／Framework、Maven／Gradle、JUnit 與 Surefire／Failsafe 版本。任一版本不符即停止並依通用規則分類，不得自行替換版本、安裝工具、改寫參數或改用其他命令。
5. 嚴格執行 `CMD-*`，不得自行改寫 Maven／Gradle 參數；使用者核准替代命令後，Attempt 必須保存完整實際命令及原因。
6. Maven 指定測試須確認目標模組實際執行、測試類被發現且測試數大於 0；`BUILD SUCCESS`、上游成功或零測試不能單獨判定 VAL 通過，`failIfNoSpecifiedTests=false` 只能由 TASK 的 `CMD-*` 明列。
7. MyBatis 實作必須遵循 TASK 已固定的映射責任、null、enum、alias、`notNullColumn` 與測試。
8. 不得自行新增依賴、測試框架、外掛、設定或替代驗證。
