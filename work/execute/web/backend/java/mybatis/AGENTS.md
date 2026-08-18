# Java 後端 MyBatis 任務執行規範

## 1. 適用分支

1. Attempt 建立前，須以目標模組與本次流程為邊界，唯讀核對 TASK `決策` 已依使用者指定唯一固定純 MyBatis 或 MyBatis-Plus、判定證據、實際版本、設定及資料存取架構，且與專案現況一致；未指定、同時指定兩者、證據不足或現況衝突時回報規格不符，不得由 Execute 選擇技術或建立 Attempt。
2. 只套用共用規則及 TASK 指定的唯一技術分支；不得混用另一分支的相依、API、分頁契約、外掛或設定，亦不得遷移未觸及流程。
3. 嚴格遵循 TASK 固定的既有慣例、安全預設與核准例外；需要新增、升級或改變相依、外掛、設定、映射方式及資料存取架構時，依規格缺陷停止，不得由 Execute 補充。

## 2. 共用規則

1. 須核對 TASK 固定的實際 MyBatis core 版本、Spring 整合或 `SqlSession` 管理、Mapper 掃描、XML 資源、SQL 來源及交易參與方式符合專案現況；TASK 指定純 MyBatis 時只核對 MyBatis core 版本，指定 MyBatis-Plus 時另核對 MyBatis-Plus 版本與設定。任一缺漏或不符時回報規格不符，不得由 Execute 補充或替換。
2. 必須依 TASK 固定的既有 SQL 來源慣例使用註解、XML 或 provider，並實作 Mapper 介面與方法簽章、參數名稱／型別／綁定、回傳型別及欄位至屬性的結果映射；XML 的 namespace、statement ID、參數與結果契約須和 Mapper 一致。不得為方便改變 SQL 來源、建立重複 statement，或依執行結果自行推測與放寬契約。
3. `resultMap`／`resultType`、自動映射、null、alias、enum、`TypeHandler`、`jdbcType`、`notNullColumn`、column prefix、巢狀及建構子映射，只能依 TASK 固定的適用項目實作並直接測試；不得加入未核准的隱含轉換。
4. 查詢值必須依 TASK 使用 `#{}` 綁定；`${}` 不得接收不可信輸入。動態欄位、表名與排序只接受 TASK 固定的後端白名單；LIKE、空集合 `IN`、動態 `WHERE`／`SET` 必須符合固定的輸入與空值語意。原始 SQL 插值缺少 TASK 固定的原因、可信來源、白名單、邊界或驗證時立即停止。
5. 更新與刪除必須使用 TASK 固定的明確條件，並驗證實際影響筆數；不得執行未核准的全表操作或繞過既有防護。
6. 寫入流程必須依 TASK 實作主鍵來源、型別、產生策略及回填；`useGeneratedKeys`、`keyProperty`、`keyColumn` 或 MyBatis-Plus 對應設定、複合鍵、sequence 與批次回填須和指定技術及實際資料庫一致，並驗證寫入後主鍵值。
7. 單筆查詢必須遵循 TASK 固定的唯一性、缺少資料及選取規則，不得忽略重複結果或任意加入 `LIMIT 1`。分頁必須套用 TASK 固定的參數、回傳契約、單頁上限、溢出、包含唯一 tie-breaker 的穩定排序及總筆數語意，資料查詢成功不得取代 count 與邊界驗證。
8. 多筆或跨 Mapper 寫入必須使用 TASK 在已確認架構中固定的協調層交易邊界；四層架構使用業務 Service，其他架構使用 TASK 明列的責任層。大量寫入須依 TASK 的批次機制、資料量、批次大小、失敗、回滾、部分成功及主鍵回填行為執行，不得改為未受控迴圈逐筆寫入。
9. 分頁、租戶、邏輯刪除、資料權限、樂觀鎖及全表操作防護，只能依 TASK 固定的外掛／設定、版本、攔截器順序、作用範圍與排除條件執行；自訂 SQL 不得無意繞過。現況缺少或不符時回報規格不符，不得自行新增、停用、重排或替換。
10. 日期欄位須依 TASK 固定的語意、Java 型別與資料庫／JDBC 行為實作；`LocalDate`、`LocalDateTime`、純時間或含時區型別不得互相替換，並須執行適用的往返測試。
11. 必須執行 TASK 明列且直接覆蓋受影響 Mapper 的整合測試，並依影響驗證映射、Mapper XML 載入、動態 SQL、null／唯一性、主鍵回填、分頁／count、交易／回滾、批次、樂觀鎖、邏輯刪除、租戶、資料權限及外掛；測試數須大於 0。dialect 或資料庫特有行為須在 TASK 固定的目標資料庫或相容環境驗證，不得以其他資料庫、mock、零測試或單獨建置成功取代。

## 3. 純 MyBatis 規則

1. TASK 指定純 MyBatis 時，不得新增或使用 MyBatis-Plus 相依與 API。
2. 分頁須依 TASK 固定的 MyBatis 分頁機制、dialect、參數、回傳型別、count 查詢及攔截器設定實作與驗證；不得改用 MyBatis-Plus 的 `Page<T>`／`IPage<T>`。
3. 批次 executor 或手動 `SqlSession` 必須依 TASK 的 executor type、session／交易生命週期、flush、批次大小與錯誤處理執行；不得自行改變 executor、建立額外 session 或脫離固定交易邊界。

## 4. MyBatis-Plus 規則

1. TASK 指定 MyBatis-Plus 時，須依共用規則核對版本與設定，並確認持久層架構符合 TASK；適用時 Mapper 使用 `BaseMapper`。只有 TASK 選用 Persistence Service 層時才使用 `IService` 與 `ServiceImpl`；不得遷移至 `IRepository` 或新增未核准層級。
2. TASK 已採用 Persistence Service／`IService` 且查詢可清楚表達時，必須優先使用 `IService.lambdaQuery()`；只有 TASK 已固定複雜 join、聚合、特殊 SQL 或架構不適用的原因、邊界與測試時，才能使用自訂 Mapper／XML。四層架構不得省略業務 Service 或 Persistence Service，Controller 不得直接呼叫 Mapper；其他架構遵循 TASK 固定鏈路。
3. Controller、RPC 或前端不得傳入 `Wrapper` 或 SQL 片段；`last()`、`apply()`、`inSql()`、`exists()` 等 API 不得拼接不可信輸入，核准例外仍須完整符合共用 SQL 安全規則。
4. 不得以 `getOne(..., false)` 掩蓋資料重複。分頁查詢參數使用 `Page<T>`，回傳型別可宣告為 `IPage<T>`，並須驗證 TASK 固定的最大筆數、溢出、穩定排序與總筆數語意。
5. 邏輯刪除、租戶、資料權限、樂觀鎖、分頁及全表操作防護須依 TASK 固定的 MyBatis-Plus 設定與 InnerInterceptor 順序執行，並驗證產生條件、排除範圍、樂觀鎖衝突及實際影響筆數。
