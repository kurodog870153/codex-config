# Java 後端任務執行規範

1. 執行前確認 TASK 固定的既有 Maven／Gradle 建置系統、目標 shell、工作目錄、模組、Java、JDK／toolchain、JUnit 及測試位置；不得切換建置系統或同時維護兩套設定。Maven 須確認適用的 Wrapper／執行檔，且不得因目標為子模組而要求該子模組自備 Wrapper；TASK 明列 `mvn`／`mvn.cmd` 絕對路徑時須依該路徑執行。Gradle 須確認建置檔與 Groovy／Kotlin DSL、Wrapper 根目錄或已預檢的系統 Gradle、模組或 project path、實際 task、參數／property 及測試篩選；適用的 Wrapper 存在時不得改用系統 Gradle。不符合 TASK 時，在 Attempt 建立前回報規格不符，執行中則以規格缺陷停止。
2. Attempt 建立前先依 task 規則判定是否需要版本基準。需要時，只接受目標 TASK `決策` 清單內包含版本基準與相容性依據的單一已確認項目，或其引用且包含相同內容的單一文件層 `DECISION-*`；缺少內容、引用不唯一、另有衝突版本，或使用 `版本基準`、`相容性依據` 等額外 TASK 欄位時，回報規格不符且不建立 Attempt。無需基準時沿用專案既有設定，不要求補充版本研究。
3. 有版本基準時，依其與 TASK 固定環境唯讀核對可直接解析的 `JAVA_HOME`、`java`／`javac` 路徑與版本、編譯 release、JDK／toolchain、Wrapper 設定、Maven／Gradle 執行檔及建置工具 distribution；指定環境不得改用系統 `PATH`。不得執行未列入 TASK 且可能初始化、下載或寫入資料的 Wrapper／建置命令；無法唯讀解析而只能由 TASK `CMD/VAL` 確認的版本，留待 Attempt 驗證。
4. 每個 `CMD-*` 使用 TASK 固定的環境；有版本基準時，另依 `CMD/VAL` 核對實際生效的 Java、編譯 release、Spring Boot／Framework、Maven／Gradle、JUnit 與 Surefire／Failsafe 版本。任一版本不符即停止並依通用規則分類，不得自行替換版本、安裝工具、改寫參數或改用其他命令。
5. 嚴格執行 `CMD-*`，不得自行改寫 Maven／Gradle 參數；使用者核准替代命令後，Attempt 必須保存完整實際命令及原因。
6. Maven 指定測試須確認目標模組實際執行、測試類被發現且測試數大於 0；`BUILD SUCCESS`、上游成功或零測試不能單獨判定 VAL 通過，`failIfNoSpecifiedTests=false` 只能由 TASK 的 `CMD-*` 明列。Gradle 驗證須確認 TASK 固定的 project path 與 task 實際執行、指定測試被發現且測試數大於 0；只有整體成功、task 被略過／無來源／快取命中，或零測試均不能單獨判定 VAL 通過。
7. 涉及關聯式資料存取的 TASK 在 Attempt 建立前，須以目標模組與本次流程為邊界，唯讀交叉確認建置相依及實際程式用法，核對 TASK `決策` 已唯一固定 JPA 或 MyBatis／MyBatis-Plus、實際版本、適用 namespace／provider、目標模組及資料存取架構；兩者並存時只接受與目標流程實際鏈路相符的選擇。TASK 未固定、證據只包含未使用相依、兩者皆適用、皆未使用、現況與 TASK 衝突或仍無法唯一判定時，回報規格不符且不建立 Attempt，不得由 Execute 選擇、加入或切換技術。Execute 必須載入與 TASK `決策` 一致的唯一技術分支：JPA 使用 `java/jpa`，MyBatis／MyBatis-Plus 使用 `java/mybatis`；未載入技術分支、同時載入兩個分支，或載入分支與 TASK `決策` 不符時，回報規格不符且不建立 Attempt。
8. 不得自行新增依賴、測試框架、外掛、設定或替代驗證。
9. Attempt 建立前須唯讀確認 TASK 固定的 Lombok 依賴、有效版本、annotation processor 設定及目標檔案既有用法；專案已具備 Lombok 依賴與有效 annotation processor 設定，且 TASK 核准的 Lombok 用法符合必要行為、公開 API、框架契約及適用限制時，須優先依 TASK 使用 Lombok 減少樣板程式碼，不得改以手寫重複程式碼取代。適用的 `lombok.config` 存在時亦須確認，文件規範與既有設定任一方禁止時即回報規格不符。
10. `lombok.config` 原則上為選用；沒有時不需建立且不構成規格不符。唯一例外為 TASK 核准搭配 Jackson 3 或同時支援 Jackson 2 與 Jackson 3 的 `@Jacksonized`，此時適用的 Lombok 設定須包含 TASK 固定的 `lombok.jacksonized.jacksonVersion`；TASK 未列入所需設定變更且既有設定不符時，回報規格不符。既有 `lombok.config` 不得僅因本規範修改，亦不得自行補設定或忽略限制。
11. 只能使用 TASK 已核准的 Lombok 註解、位置、參數及產生行為；不得加入白名單外註解、擴大類別層級註解、替換建構方式或自行核准例外。
12. 新增 Lombok 依賴、變更版本、annotation processor、建置設定或日誌依賴，只有 TASK 明列時才能執行；需要額外變更時立即停止。
13. 修改既有類別時須確認其受影響的 Lombok 用法符合 TASK；未觸及的既有違規不主動修改。合規所需檔案未列入 TASK 時回報規格不符。
14. Entity、公開 API、跨模組 API、Builder、相等性、`toString`、`@With` 及 Jackson 序列化行為，須嚴格依 TASK 已固定的欄位、簽章、可見性及例外執行，不得依 Lombok 預設自行推導。
15. 必須執行 TASK 明列的註解檢查、編譯及相關測試；需要直接行為測試的項目不得只以編譯成功或 `BUILD SUCCESS` 判定通過。
16. 專案已使用 Swagger／OpenAPI 時，新增或修改 Controller API 必須依 TASK 與既有套件、版本及註解風格，為 Controller 類別與端點、每個參數、各 HTTP 回應，以及 response DTO 與欄位加上 Swagger／OpenAPI 註解並執行 TASK 固定的驗證；TASK 未固定所需註解或驗證方式時，須回報規格不符並停止，且不得自行新增或升級 Swagger／OpenAPI 依賴。
17. 涉及關聯式資料存取時，Attempt 建立前須唯讀核對 TASK 固定的目標資料庫與適用 dialect、既有 schema，以及受影響的資料表、欄位型別、constraint、index、foreign key 與 sequence；現況與 TASK 不一致時回報規格不符。查詢、寫入、映射及 schema migration 必須與實際 schema 一致；涉及 schema 變更時，只能使用 TASK 固定且專案既有適用的單一 migration／初始化機制、檔案與執行順序，不得自行新增、替換或混用其他機制。必須執行 TASK 固定的一致性、升級與必要回復或補償驗證；dialect、constraint、index、migration 或其他資料庫特有行為須在目標資料庫或 TASK 固定的相容環境驗證，不得以其他資料庫、mock、零測試或單獨的建置成功取代。
