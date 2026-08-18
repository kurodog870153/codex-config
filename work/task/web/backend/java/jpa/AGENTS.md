# Java 後端 JPA 任務規劃規範

1. Spring Data JPA／Jakarta Persistence／Hibernate TASK 核准前必須固定下列事項；專案既有且有效的慣例優先，沒有明確慣例時套用本項安全預設，偏離時須固定原因、邊界及驗證：
    1. 唯讀確認目標模組的 Spring Data JPA、Hibernate ORM、Persistence namespace、目標資料庫／dialect、建置工具、schema migration 機制、Repository 抽象及持久層架構；版本或 namespace 不一致時維持草案，不得自行遷移 `javax.persistence` 與 `jakarta.persistence`。
    2. JPA 必須搭配 Hibernate Metamodel annotation processor，並依實際 Hibernate 主版本固定唯一座標：Hibernate 7 以上使用 `org.hibernate.orm:hibernate-processor`，Hibernate 6 使用 `org.hibernate.orm:hibernate-jpamodelgen`，Hibernate 5 使用 `org.hibernate:hibernate-jpamodelgen`；processor 版本須與實際 `hibernate-core` 精確版本或管理該版本的 Hibernate BOM 對齊，不得使用 `latest`、版本範圍、不同主版本或只因 Maven relocation 成功就視為相容。
    3. TASK 須依既有 Maven／Gradle 設定固定 processor 的宣告位置、annotation processing 啟用方式、產生來源目錄、編譯整合及清理行為；缺少 processor 或有效設定時，必須將所需建置檔列入 TASK 並另行取得授權，不得只加入一般 runtime／implementation 相依或由 Execute 臨時補設定。
    4. VAL 須確認 processor 實際執行、目標 Entity 的 `*_` 靜態 Metamodel 已產生且參與編譯，測試數大於 0；Criteria／Specification 對已產生屬性優先使用靜態 Metamodel，不得以字串屬性路徑取代。產生檔不得手動修改，是否提交及輸出目錄沿用專案既有慣例，沒有慣例時須在 TASK 固定。
    5. Entity 映射須固定 access type、Entity／table 名稱、主鍵與產生策略、欄位名稱、null、長度、precision／scale、唯一性、預設值、識別碼不可變性及 schema 對應；複合主鍵另固定 `@EmbeddedId` 或 `@IdClass`、值相等性及查詢測試。`equals`／`hashCode` 須固定代理、未持久化與持久化狀態行為，不得只依可變欄位或資料庫產生 ID 推導。
    6. enum 預設使用明確 `EnumType.STRING` 或已確認 converter，不得依 ordinal；日期、時間與時區依欄位語意、目標資料庫型別及既有映射固定，僅日期使用 `LocalDate`、無時區日期時間使用 `LocalDateTime`，含時區語意須另行固定型別、JDBC／Hibernate 時區設定及往返測試。
    7. 每個關聯須固定 cardinality、擁有端、`mappedBy`／join column、可空性、集合型別、雙向同步方式、fetch plan、cascade、`orphanRemoval` 及生命週期測試。沒有既有慣例時關聯優先明確 LAZY，並由個別查詢使用 fetch join、Entity Graph 或 projection 取得必要資料；`CascadeType.ALL` 預設禁止，cascade 採最小集合，`orphanRemoval` 只用於父實體私有擁有的子實體。
    8. Repository 須沿用專案既有抽象、命名及責任邊界；四層架構只由 Persistence Service 呼叫 Repository，業務 Service 不得直接操作 Repository／`EntityManager`。只有既有 Repository 抽象無法表達需求時，才能規劃自訂 Repository／`EntityManager`，並固定原因、邊界及測試。
    9. 簡單條件優先沿用既有 derived query，組合條件依既有慣例使用 Specification／Criteria，複雜固定查詢使用明確 JPQL／HQL；所有值須參數綁定，動態欄位及排序只接受後端白名單，不得拼接不可信 JPQL／HQL／SQL。native query 只限標準查詢無法正確表達或有已確認效能需求時使用，並固定 dialect、SQL、結果映射、count query、限制條件及整合測試。
    10. 單筆查詢須固定唯一性、找不到資料的行為及 `Optional`／例外契約，不得以任意第一筆掩蓋重複資料。分頁須固定 `Page`／`Slice`／`List`／scroll 選擇、單頁上限、溢出行為、總筆數語意及包含唯一 tie-breaker 的穩定排序；collection fetch join、native query 或複雜 projection 與分頁併用時，須固定可正確執行的資料查詢與 count 方案及測試。
    11. 交易邊界須依已確認架構置於完整業務工作單元；四層架構由業務 Service 協調，讀取流程優先使用 `readOnly = true`，寫入流程固定回滾行為。非預設 propagation、isolation、timeout 或 rollback 規則須固定理由與測試；延遲載入完成與 DTO 轉換須位於已固定邊界內，不得依賴 Open Session in View 補足未規劃的 fetch plan。
    12. 可能並行更新或合併 detached Entity 時，安全預設為使用 `@Version` 樂觀鎖並固定衝突契約與測試；不使用 version 時須固定一致性替代方案。悲觀鎖只在已確認競爭需求下使用，並固定 lock mode、鎖定順序、timeout、死鎖／重試行為、交易邊界及目標資料庫測試。
    13. 更新、刪除及 bulk DML 須固定條件、目標範圍、預期影響筆數、`@Modifying`、flush／clear 與 persistence context 過期資料處理；預設禁止全表操作。bulk／native 操作不得無意繞過 version、Entity listener、audit、邏輯刪除、租戶或資料權限，確需偏離時須固定影響及補償驗證。
    14. 大量寫入須固定資料量邊界、JDBC batch 設定、主鍵產生策略相容性、batch size、排序設定、定期 `flush`／`clear`、交易大小、記憶體上限及失敗／回滾／部分成功行為；不得只因使用 `saveAll` 就宣稱已批次化或以未受控迴圈逐筆寫入。
    15. 每個可能載入關聯的查詢須固定所需 fetch plan 與可觀察的 SQL／query count 上限，使用適用的 fetch join、Entity Graph、projection、batch fetch 或 subselect 避免 N+1；不得全域改為 EAGER。高資料量查詢須固定 projection、分頁／scroll、索引及記憶體邊界，效能例外須有代表性資料驗證。
    16. 除上層關聯式資料的 schema／migration 共通規則外，TASK 須固定 JPA 專屬的 Entity 映射與 schema validation，確認 Entity、constraint、index、foreign key、sequence 與實際 schema 及核准 migration 一致；正式環境不得以未核准的 `ddl-auto=create`、`create-drop` 或 `update` 取代 migration。建立資料表或欄位仍須遵循上層 comment 規則。
    17. 專案使用 auditing、Entity listener、邏輯刪除、租戶或資料權限時，須固定建立／更新者與時間來源、目前使用者傳遞、適用查詢條件、bulk／native 行為及測試；不得由 Entity 直接讀取 Controller、HTTP Session 或安全框架上下文。
    18. 測試至少覆蓋受影響的映射、constraint、Repository 查詢、null／唯一性、關聯擁有端、cascade／orphan、fetch plan／query count、分頁／count、交易／回滾、鎖衝突、bulk persistence context、batch、audit／邏輯刪除／租戶及 migration。只有專案既有且適用時才使用 `@DataJpaTest`；dialect、鎖、migration 或原生 SQL 行為相關時，須在 TASK 固定的目標資料庫或相容測試環境驗證。
    19. 不適用上述安全預設時，TASK 須固定例外原因、資料量與生命週期邊界、替代方案及直接驗證；不得為套用本規範主動重構未觸及的既有 JPA 程式。
