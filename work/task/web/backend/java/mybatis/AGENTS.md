# Java 後端 MyBatis 任務規劃規範

## 1. 適用分支

1. MyBatis／MyBatis-Plus TASK 核准前，須以目標模組與本次流程為邊界，唯讀確認實際存在且適用的 MyBatis／MyBatis-Plus 相依與設定、Mapper 介面／註解、Mapper XML、`SqlSession`、`BaseMapper` 及持久層架構等證據，逐項列出並請使用者明確指定純 MyBatis 或 MyBatis-Plus；不得由 AI 設定預設優先順序，確認前維持對話草案。
2. 正式 TASK 必須在 `決策` 固定使用者指定的純 MyBatis 或 MyBatis-Plus、目標模組、判定證據、實際版本、設定與資料存取架構；使用者指定技術不代表授權新增、升級或遷移相依、外掛、設定及既有流程。
3. 每個 TASK 套用本規範的共用規則及使用者指定的唯一技術分支；不得同時套用純 MyBatis 與 MyBatis-Plus 專屬規則。專案兩者並存時仍以本次目標流程為範圍，未觸及流程不主動重構。
4. 專案既有且有效的慣例優先；沒有明確慣例時套用本規範的安全預設。偏離安全預設時，TASK 須固定原因、適用邊界、替代方案及直接驗證。

## 2. 共用規則

1. TASK 必須固定實際 MyBatis core 版本、Spring 整合或 `SqlSession` 管理方式、Mapper 掃描、XML 資源位置、既有 SQL 來源慣例及交易參與方式；使用者指定純 MyBatis 時只固定 MyBatis core 版本，指定 MyBatis-Plus 時另固定 MyBatis-Plus 版本與適用設定。
2. 每個資料存取 TASK 必須依專案既有慣例固定註解、XML 或 provider 映射方式、Mapper 介面與方法簽章、參數名稱／型別／綁定方式、回傳型別，以及欄位至屬性的結果映射；使用 XML 時，namespace、statement ID、參數與結果契約必須和 Mapper 一致。只有既有 SQL 來源方式無法正確表達需求時才能規劃其他方式，並固定原因、邊界及測試。
3. TASK 實際涉及時，另須固定 `resultMap`／`resultType`、自動映射、null 行為、alias、enum 轉換、`TypeHandler`、`jdbcType`、`notNullColumn`、column prefix、巢狀或建構子映射及對應測試；未涉及項目不得要求逐項記錄。
4. 查詢值預設使用 `#{}` 綁定；`${}` 不得接收不可信輸入。動態欄位、表名與排序只能來自後端白名單；LIKE 跳脫、空集合 `IN`、動態 `WHERE`／`SET` 須固定輸入邊界、空值語意及測試。確需原始 SQL 插值時，TASK 須固定原因、可信來源、白名單、適用邊界及直接驗證。
5. 更新與刪除須固定明確條件、目標範圍及預期影響筆數，預設禁止全表更新或刪除；確有必要時須固定原因、保護措施及驗證。
6. 新增或修改寫入流程時，TASK 須沿用並固定主鍵來源與型別、產生策略及回填行為；依所選技術固定 `useGeneratedKeys`、`keyProperty`、`keyColumn` 或 MyBatis-Plus 對應設定。複合鍵、sequence 與批次主鍵回填僅在適用時固定契約及測試。
7. 單筆查詢須固定唯一性、找不到資料的行為或明確選取規則，不得以忽略重複結果或任意 `LIMIT 1` 掩蓋資料異常。分頁須固定所選技術的參數與回傳契約、單頁最大筆數、溢出行為、包含唯一 tie-breaker 的穩定排序及總筆數語意。
8. 多筆或跨 Mapper 寫入須在 TASK 已確認架構的協調層固定交易邊界；四層架構使用業務 Service，其他架構使用 TASK 明列的責任層。大量寫入須固定既有版本支援的批次機制、資料量與批次大小、失敗、回滾、部分成功及主鍵回填行為，不得以未受控迴圈逐筆寫入取代批次機制。
9. TASK 觸及分頁、租戶、邏輯刪除、資料權限、樂觀鎖或全表操作防護時，須固定實際外掛／設定、版本適用性、攔截器順序、作用範圍、排除條件及整合測試；自訂 SQL 不得無意繞過適用條件。未觸及功能不得為套用本規範新增外掛或改變既有設定。
10. 涉及資料庫日期欄位映射時，TASK 須依欄位語意固定 Java 型別與驗證：僅表示日期且不含時間與時區者使用 `java.time.LocalDate`；表示日期與時間且不含時區者使用 `java.time.LocalDateTime`。純時間或含時區語意須另行固定型別、資料庫／JDBC 行為及往返測試。
11. 每個 TASK 必須規劃直接覆蓋受影響 Mapper 的整合測試；映射、Mapper XML 載入、動態 SQL、null／唯一性、主鍵回填、分頁／count、交易／回滾、批次、樂觀鎖、邏輯刪除、租戶、資料權限及外掛行為依實際影響追加。dialect 或資料庫特有行為須在上層規則固定的目標資料庫或相容環境驗證，測試數必須大於 0。

## 3. 純 MyBatis 規則

1. 使用者指定純 MyBatis 時，不得新增或改用 MyBatis-Plus 相依與 API。
2. 分頁須固定既有 MyBatis 分頁機制、dialect、參數、回傳型別、count 查詢及攔截器設定；不得套用 MyBatis-Plus 的 `Page<T>`／`IPage<T>` 契約。
3. 使用批次 executor 或手動管理 `SqlSession` 時，TASK 須固定 executor type、session／交易生命週期、flush 時機、批次大小、錯誤處理及驗證；未採用時不得為套用本規範新增。

## 4. MyBatis-Plus 規則

1. 使用者指定 MyBatis-Plus 時，TASK 須依共用規則固定版本與設定，並固定持久層架構；符合既有架構與版本基準時，Mapper 優先繼承 `BaseMapper`。只有 TASK 選用 Persistence Service 層時，其介面才優先繼承 `IService`、實作優先繼承 `ServiceImpl`；不得為套用本規範遷移至 `IRepository` 或新增層級。
2. TASK 已採用 Persistence Service／`IService`，且查詢可清楚表達時，優先規劃使用 `IService.lambdaQuery()`；複雜 join、聚合、特殊 SQL 或既有架構不適用時，才能依 TASK 固定的原因、邊界與測試使用自訂 Mapper／XML。四層架構不得省略業務 Service 或 Persistence Service，Controller 不得直接呼叫 Mapper；其他架構遵循 TASK 固定的責任與鏈路。
3. Controller、RPC 或前端不得傳入 `Wrapper` 或 SQL 片段；`last()`、`apply()`、`inSql()`、`exists()` 等可接收 SQL 內容的 API 不得拼接不可信輸入，例外仍須符合共用 SQL 安全規則。
4. 單筆查詢不得以 `getOne(..., false)` 掩蓋資料重複。分頁查詢參數使用 `Page<T>`，回傳型別可宣告為 `IPage<T>`，並固定與驗證共用分頁規則要求的最大筆數、溢出、穩定排序及總筆數語意。
5. 使用邏輯刪除、租戶、資料權限、樂觀鎖、分頁或全表操作防護時，須依共用外掛規則固定 MyBatis-Plus 實際設定與 InnerInterceptor 順序，並驗證產生條件、排除範圍、樂觀鎖衝突及實際影響筆數。
