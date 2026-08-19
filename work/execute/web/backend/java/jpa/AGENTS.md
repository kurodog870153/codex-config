# Java 後端 JPA 任務執行規範

1. Spring Data JPA／Jakarta Persistence／Hibernate 實作必須遵循下列規則：
    1. 唯讀確認 TASK 固定的 Spring Data JPA、Hibernate ORM、Persistence namespace、目標資料庫／dialect、建置工具、schema migration 機制、Repository 抽象及持久層架構符合專案現況；不得自行遷移 `javax.persistence` 與 `jakarta.persistence`、更換 provider 或改變資料存取架構。
    2. 核對 Hibernate Metamodel annotation processor 與實際 Hibernate 主版本相符：Hibernate 7 以上只使用 `org.hibernate.orm:hibernate-processor`，Hibernate 6 只使用 `org.hibernate.orm:hibernate-jpamodelgen`，Hibernate 5 只使用 `org.hibernate:hibernate-jpamodelgen`；processor 版本須與實際 `hibernate-core` 精確版本或 Hibernate BOM 對齊。座標、版本、Maven／Gradle 宣告位置、annotation processing、產生來源目錄、編譯整合或清理行為不符合 TASK 時，在寫入前回報規格不符，不得依賴 relocation、自行換版或補設定。
    3. 依 TASK 執行 processor 並確認目標 Entity 的 `*_` 靜態 Metamodel 已產生且參與編譯；Criteria／Specification 對已產生屬性須使用靜態 Metamodel，不得改用字串屬性路徑。產生檔不得手動修改，提交及輸出目錄政策嚴格依 TASK 與專案慣例執行。
    4. 嚴格依 TASK 實作 access type、Entity／table、主鍵與產生策略、欄位、null、長度、precision／scale、唯一性、預設值、複合主鍵、識別碼不可變性、`equals`／`hashCode`、enum、converter 與 schema 映射；不得依 JPA、Hibernate 或資料庫預設自行補足未固定契約。涉及 JPA 日期或時間欄位映射時，須遵循上層 Java 共通規則，並核對及依 TASK 固定的欄位語意、目標資料庫型別及既有映射實作 JPA 映射；含時區語意時，另須核對並依 TASK 固定的 JDBC／Hibernate 時區設定實作，且須執行適用的往返測試。TASK 必要內容缺漏時，在寫入前回報規格不符。
    5. 關聯必須依 TASK 固定 cardinality、擁有端、`mappedBy`／join column、可空性、集合、雙向同步、fetch plan、cascade 及 `orphanRemoval`；不得擴大 cascade、加入未核准的 `CascadeType.ALL`、把非私有擁有關聯設為 orphan removal，或以全域 EAGER 取代個別 fetch plan。
    6. Repository、Persistence Service、業務 Service 與 Controller 的呼叫鏈路須符合 TASK 及上層架構規則；四層架構不得由業務 Service 直接操作 Repository／`EntityManager`，亦不得由 Controller 直接觸及持久層。自訂 Repository／`EntityManager` 只依 TASK 固定的原因、邊界及測試實作。
    7. Derived query、Specification／Criteria、JPQL／HQL 及 native query 須依 TASK 選擇並使用參數綁定；動態欄位與排序只接受後端白名單，不得拼接不可信內容。native query 必須符合 TASK 固定的 dialect、SQL、結果映射、count query、限制條件及測試，不得為方便自行改用原生 SQL。
    8. 單筆查詢須遵循 TASK 固定的唯一性、缺少資料及 `Optional`／例外契約。分頁／Slice／scroll 須套用單頁上限、溢出、總筆數與包含唯一 tie-breaker 的穩定排序；collection fetch join、native query 或複雜 projection 的資料與 count 查詢須依 TASK 驗證，不能只因查詢成功就判定分頁正確。
    9. 交易邊界、`readOnly`、propagation、isolation、timeout、rollback 與延遲載入／DTO 轉換須嚴格依 TASK；四層架構由業務 Service 管理完整工作單元。不得以 Open Session in View、Repository 預設交易或額外 `save` 呼叫掩蓋未固定的交易及 fetch plan。
    10. 樂觀鎖須依 TASK 使用 `@Version` 並驗證衝突契約；悲觀鎖須依 TASK 的 lock mode、順序、timeout、死鎖／重試及交易邊界執行。不得省略 version、降低鎖定或自行加入較強鎖模式。
    11. 更新、刪除及 bulk DML 必須套用 TASK 固定條件並驗證實際影響筆數、`@Modifying`、flush／clear 與 persistence context 狀態；不得執行未核准的全表操作，亦不得無意繞過 version、Entity listener、audit、邏輯刪除、租戶或資料權限。
    12. 大量寫入須依 TASK 的 JDBC batch、主鍵策略、batch size、排序、定期 `flush`／`clear`、交易與記憶體邊界執行；不得只呼叫 `saveAll` 就宣稱批次完成，或改成未受控的逐筆寫入。須驗證失敗、回滾與部分成功行為。
    13. 嚴格依 TASK 的 fetch join、Entity Graph、projection、batch fetch 或 subselect 執行 fetch plan，並驗證 SQL／query count 上限及代表性資料；發現 N+1、未預期 EAGER、延遲載入越界或資料量超出固定邊界時，依通用規則停止，不得臨時全域改 fetch type。
    14. 除上層關聯式資料的 schema／migration 共通規則外，須依 TASK 實作 JPA 專屬的 Entity 映射與 schema validation，並確認 Entity、constraint、index、foreign key、sequence 與實際 schema 及核准 migration 一致；正式環境不得以未核准的 `ddl-auto=create`、`create-drop` 或 `update` 取代 migration。TASK 缺少適用的 comment 或 schema validation 契約時回報規格不符。
    15. 專案使用 auditing 或會寫入稽核欄位的 Entity listener 時，須依 TASK 固定的建立／更新者與時間來源、目前使用者傳遞及 bulk／native 行為執行並驗證；專案使用邏輯刪除、租戶或資料權限時，須依 TASK 固定的目前使用者、租戶或其他適用主體來源、查詢條件及 bulk／native 行為執行並驗證，只有相關行為需要取得或產生目前日期或時間時才核對並使用 TASK 固定的時間來源；Entity 不得直接讀取 Controller、HTTP Session 或安全框架上下文。
    16. 必須執行 TASK 明列的 processor、Metamodel、編譯及 JPA 整合測試，並覆蓋適用的映射、constraint、查詢、關聯、fetch／query count、分頁／count、交易／回滾、鎖、bulk persistence context、batch、audit／邏輯刪除／租戶及 migration；dialect、鎖、migration 或 native SQL 行為不得只以記憶體資料庫、mock、零測試或 `BUILD SUCCESS` 判定通過。
    17. 不得自行新增或升級 JPA、Hibernate、processor、測試框架、外掛、設定、migration 工具或替代驗證；任何缺漏、版本衝突、現況差異或必要額外檔案均依規格缺陷停止。
