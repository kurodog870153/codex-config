# Java 後端任務執行規範

1. 執行前確認 TASK 固定的 Maven Wrapper／Maven 執行檔、目標 shell、模組、JUnit 及測試位置；不得因目標為子模組而要求該子模組自備或使用 Wrapper，TASK 明列 `mvn`／`mvn.cmd` 絕對路徑時須依該路徑執行。不符合 TASK 時，在 Attempt 建立前回報規格不符，執行中則以規格缺陷停止。
2. Attempt 建立前先依 task 規則判定是否需要 `版本基準`。需要時，只接受目標 TASK 內的基準，或其以 `版本基準：<DECISION-ID>` 引用的單一文件層 `DECISION-*`；缺少基準、引用不唯一、缺少 `相容性依據` 或其他文字另訂衝突版本時，回報規格不符且不建立 Attempt。無需基準時沿用專案既有設定，不要求補充版本研究。
3. 有 `版本基準` 時，依其與 TASK 固定環境唯讀核對可直接解析的 `JAVA_HOME`、`java`／`javac` 路徑與版本、編譯 release、Wrapper 設定、Maven 執行檔及建置工具 distribution；指定環境不得改用系統 `PATH`。不得執行未列入 TASK 且可能初始化、下載或寫入資料的 Wrapper／建置命令；無法唯讀解析而只能由 TASK `CMD/VAL` 確認的版本，留待 Attempt 驗證。
4. 每個 `CMD-*` 使用 TASK 固定的環境；有 `版本基準` 時，另依 `CMD/VAL` 核對實際生效的 Java、編譯 release、Spring Boot／Framework、Maven／Gradle、JUnit 與 Surefire／Failsafe 版本。任一版本不符即停止並依通用規則分類，不得自行替換版本、安裝工具、改寫參數或改用其他命令。
5. 嚴格執行 `CMD-*`，不得自行改寫 Maven／Gradle 參數；使用者核准替代命令後，Attempt 必須保存完整實際命令及原因。
6. Maven 指定測試須確認目標模組實際執行、測試類被發現且測試數大於 0；`BUILD SUCCESS`、上游成功或零測試不能單獨判定 VAL 通過，`failIfNoSpecifiedTests=false` 只能由 TASK 的 `CMD-*` 明列。
7. MyBatis／MyBatis-Plus 實作必須遵循下列規則：
    1. 嚴格遵循 TASK 已固定的映射責任、null、enum、alias、`notNullColumn` 與測試。
    2. 唯讀確認既有 MyBatis-Plus 版本與持久層架構符合 TASK；適用時 Mapper 優先使用 `BaseMapper`，Persistence Service 優先使用 `IService` 與 `ServiceImpl`，不得為套用本規範遷移既有架構或改用 `IRepository`。
    3. Persistence Service 查詢優先使用 `IService.lambdaQuery()`；新增或修改流程不得省略業務 Service 或 Persistence Service，也不得由 Controller 直接呼叫 Mapper。未觸及的既有純 Mapper 流程不主動重構。自訂 Mapper／XML 只能依 TASK 已固定的原因、邊界與測試實作。
    4. 不得由 Controller、RPC 或前端接收 `Wrapper` 或 SQL 片段；動態欄位與排序欄位只接受後端白名單，`last()`、`apply()`、`inSql()`、`exists()` 等 API 不得拼接不可信輸入。
    5. 更新與刪除必須使用 TASK 固定的明確條件，並驗證實際影響筆數；不得執行未核准的全表更新或刪除，專案已有防護外掛時不得繞過。
    6. 單筆查詢必須遵循 TASK 固定的唯一性或選取規則，不得以 `getOne(..., false)` 或任意 `LIMIT 1` 掩蓋重複資料。分頁查詢參數使用 `Page<T>`，回傳型別可宣告為 `IPage<T>`，並套用 TASK 固定的最大筆數、溢出行為與穩定排序。
    7. 多筆或跨 Mapper 寫入必須使用 TASK 固定的業務 Service 交易邊界；大量寫入使用既有版本支援的批次 API，不得改成迴圈逐筆寫入，並須驗證失敗、回滾與部分成功行為。
    8. 邏輯刪除、租戶、資料權限與樂觀鎖條件不得被自訂 SQL 繞過；依 TASK 驗證產生條件、樂觀鎖衝突及實際影響筆數。
    9. 只有 TASK 已固定例外原因、資料量邊界、替代方案及驗證時，才能偏離前述優先原則或分頁要求。
    10. 涉及資料庫日期欄位映射時，依 TASK 固定的欄位語意與驗證實作：僅表示日期且不含時間與時區者使用 `java.time.LocalDate`；表示日期與時間且不含時區者使用 `java.time.LocalDateTime`。實際資料庫欄位型別須依目標資料庫、schema 與既有映射確認；純時間或含時區語意不適用本規則。
8. 不得自行新增依賴、測試框架、外掛、設定或替代驗證。
9. Attempt 建立前須唯讀確認 TASK 固定的 Lombok 依賴、有效版本、annotation processor 設定及目標檔案既有用法；專案已具備 Lombok 依賴與有效 annotation processor 設定，且 TASK 核准的 Lombok 用法符合必要行為、公開 API、框架契約及適用限制時，須優先依 TASK 使用 Lombok 減少樣板程式碼，不得改以手寫重複程式碼取代。適用的 `lombok.config` 存在時亦須確認，文件規範與既有設定任一方禁止時即回報規格不符。
10. `lombok.config` 原則上為選用；沒有時不需建立且不構成規格不符。唯一例外為 TASK 核准搭配 Jackson 3 或同時支援 Jackson 2 與 Jackson 3 的 `@Jacksonized`，此時適用的 Lombok 設定須包含 TASK 固定的 `lombok.jacksonized.jacksonVersion`；TASK 未列入所需設定變更且既有設定不符時，回報規格不符。既有 `lombok.config` 不得僅因本規範修改，亦不得自行補設定或忽略限制。
11. 只能使用 TASK 已核准的 Lombok 註解、位置、參數及產生行為；不得加入白名單外註解、擴大類別層級註解、替換建構方式或自行核准例外。
12. 新增 Lombok 依賴、變更版本、annotation processor、建置設定或日誌依賴，只有 TASK 明列時才能執行；需要額外變更時立即停止。
13. 修改既有類別時須確認其受影響的 Lombok 用法符合 TASK；未觸及的既有違規不主動修改。合規所需檔案未列入 TASK 時回報規格不符。
14. Entity、公開 API、跨模組 API、Builder、相等性、`toString`、`@With` 及 Jackson 序列化行為，須嚴格依 TASK 已固定的欄位、簽章、可見性及例外執行，不得依 Lombok 預設自行推導。
15. 必須執行 TASK 明列的註解檢查、編譯及相關測試；需要直接行為測試的項目不得只以編譯成功或 `BUILD SUCCESS` 判定通過。
16. 專案已使用 Swagger／OpenAPI 時，新增或修改 Controller API 必須依 TASK 與既有套件、版本及註解風格，為 Controller 類別與端點、每個參數、各 HTTP 回應，以及 response DTO 與欄位加上 Swagger／OpenAPI 註解並執行 TASK 固定的驗證；TASK 未固定所需註解或驗證方式時，須回報規格不符並停止，且不得自行新增或升級 Swagger／OpenAPI 依賴。
