# Java 後端任務規劃規範

1. 唯讀確認 Java 版本、JDK／toolchain、既有 Maven／Gradle 建置系統、模組、建置檔與 DSL、可用 Wrapper／系統執行檔、JUnit、測試外掛、測試位置及既有命令；TASK 只保存確認事實與正式 `CMD/VAL`，並適用下列規則：
    1. 沿用專案既有且適用於目標模組的單一建置系統；不得自行由 Maven 切換為 Gradle、由 Gradle 切換為 Maven，或為同一變更新增另一套建置設定。
    2. 不得因目標為子模組而要求該子模組自備 Wrapper。Maven `CMD-*` 可使用適用的 Wrapper，或 TASK 明列的 `mvn`／`mvn.cmd` 絕對路徑。
    3. Gradle Wrapper 存在且適用時必須使用該 Wrapper；不存在時只能使用 TASK 已固定並預檢通過的系統 Gradle 執行檔與版本。TASK 必須固定目標 shell 適用的精確命令、工作目錄、Wrapper 根目錄或系統執行檔、Groovy／Kotlin DSL、模組或 Gradle project path、實際 task 名稱、參數／property，以及生效的 Java、JDK／toolchain 與測試位置。
    4. 不得假設專案一定提供 `test`、`check`、`build` 或其他通用 task；須由既有設定、實際 task 定義或已核准預檢固定唯一 task。可能初始化、下載或寫入資料的 Gradle 預檢仍須依通用授權規則處理。
    5. 產生或升級 Wrapper、Gradle、plugin、JDK／toolchain，或修改建置 DSL 與設定時，必須明列對應檔案、版本、步驟及 `CMD/VAL`；不得作為執行時順帶修正。
2. 僅當 TASK 新增或變更 Java／Spring、編譯 release、Wrapper、Maven／Gradle、依賴／外掛、JUnit、Surefire／Failsafe，或需求涉及版本相容性時，核准前依官方第一方資料固定唯一相容版本組合；來源不足、衝突或仍有候選時維持對話草案。其他 TASK 沿用可唯讀確認的既有固定版本，不另做相容性研究或建立版本基準。
3. 前款適用時，版本使用精確值或由精確 parent、BOM、Wrapper 唯一推導，不得使用 `latest`、範圍或候選版本；以正式 `CMD/VAL` 驗證實際版本與完整建置測試，官方資料或單獨的 `BUILD SUCCESS` 不得取代驗證。
4. 需要版本基準時，只影響一個 TASK 則在該 TASK 的 `決策` 編號清單使用 `版本基準：<元件=精確值或唯一推導來源>；相容性依據：<官方來源可重現定位與支持結論>`；影響至少兩個 TASK 則以相同內容建立文件層 `DECISION-*`，各適用 TASK 在 `決策` 清單只引用該 ID。不得建立 `版本基準`、`相容性依據` 等額外 TASK 欄位，亦不得在其他文字另訂第二組版本值。
5. 每個版本基準須有唯一相容性依據，逐項記錄官方第一方來源的可重現定位與支持結論；只有搜尋結果、來源名稱或無依據的「相容」不得核准。
6. 需要版本基準但靜態資訊不足時維持對話草案；可能產生建置輸出的 Maven／Gradle 預檢須先取得授權。
7. 使用 Spring Initializr 或其他專案產生器時，核准前須固定產生器版本與全部參數，並依目前實際回應或產物清單逐項核對 TASK 的「建立」路徑及必要建置設定；不得只依歷史範本或文件推測輸出。
8. CMD 依目標 shell 產生，PowerShell 使用參數陣列，zsh／bash 個別引用參數。使用 `mvn`、`mvnw` 或 `mvnw.cmd` 執行建置或測試時，須在其他 Maven goal／phase 前明列 `clean`，已有 `clean` 時不得重複加入；Maven reactor 使用 `-am` 指定測試時先分析上游，只有上游需要時才加入 `failIfNoSpecifiedTests=false`。使用 Gradle 時，須從 TASK 固定的工作目錄呼叫適用於目標 shell 的 Wrapper 或系統執行檔，並明列完整 project path、task、測試篩選及所有參數／property；不得由 Execute 補上或替換 task 與參數。
9. VAL 必須確認目標模組實際執行、指定測試類被發現且測試數大於 0；不得只以 `BUILD SUCCESS` 判定通過。
10. 除未觸及的既有程式不主動重構外，新增或修改流程必須遵循 TASK 依上層後端規範固定的已確認架構、依賴鏈路及責任邊界；只有 TASK 選用四層架構時才套用上層完整四層鏈路。TASK 只記本次必要的責任、交易、模型轉換及核准例外。
11. MyBatis／MyBatis-Plus TASK 核准前必須固定下列事項：
    1. 固定唯一映射責任、null 行為、enum 轉換、alias、`notNullColumn` 及對應測試。
    2. 唯讀確認既有 MyBatis-Plus 版本與持久層架構；符合既有架構及版本基準時，Mapper 優先繼承 `BaseMapper`。只有 TASK 選用 Persistence Service 層時，其介面才優先繼承 `IService`、實作優先繼承 `ServiceImpl`；既有專案採用其他抽象時須沿用，不得為套用本規範主動遷移至 `IRepository` 或新增層級。
    3. TASK 選用四層架構時，Persistence Service 查詢優先規劃使用 `IService.lambdaQuery()`，且新增或修改流程不得省略業務 Service 或 Persistence Service，也不得由 Controller 直接呼叫 Mapper。TASK 選用其他架構時，依已固定的責任邊界與呼叫鏈路規劃；只有 TASK 明確固定其原因、邊界與測試時才能使用直接 Mapper 路徑。未觸及的既有純 Mapper 流程不主動重構。只有既有通用介面無法表達需求時，才能規劃自訂 Mapper／XML，並固定原因、適用邊界及測試。
    4. Controller、RPC 或前端不得傳入 `Wrapper` 或 SQL 片段；動態欄位與排序欄位須使用後端白名單，`last()`、`apply()`、`inSql()`、`exists()` 等可接收 SQL 內容的 API 不得拼接不可信輸入。
    5. 更新與刪除須固定明確條件、目標範圍及預期影響筆數，預設禁止全表更新或刪除；確有必要時須固定原因、保護措施及驗證。
    6. 單筆查詢須固定唯一性或明確選取規則；不得以 `getOne(..., false)` 或任意 `LIMIT 1` 掩蓋資料重複。
    7. 分頁查詢參數使用 `Page<T>`，回傳型別可宣告為 `IPage<T>`；須固定單頁最大筆數、溢出行為、穩定排序及總筆數語意。
    8. 多筆或跨 Mapper 寫入須在 TASK 已確認架構的協調層固定交易邊界；四層架構使用業務 Service，其他架構使用 TASK 明列的責任層。大量寫入優先使用既有版本支援的批次 API，不得以迴圈逐筆寫入，並須固定失敗、回滾、部分成功行為及驗證。
    9. 專案使用邏輯刪除、租戶、資料權限或樂觀鎖時，須固定相關設定與預期條件；自訂 SQL 不得繞過，且須測試樂觀鎖衝突與實際影響筆數。
    10. 不適用前述優先原則或分頁要求時，TASK 須固定例外原因、資料量邊界、替代方案及對應驗證。
    11. 涉及資料庫日期欄位映射時，TASK 須依欄位語意固定 Java 型別與驗證：僅表示日期且不含時間與時區者使用 `java.time.LocalDate`；表示日期與時間且不含時區者使用 `java.time.LocalDateTime`。實際資料庫欄位型別須依目標資料庫、schema 與既有映射確認；純時間或含時區語意不適用本規則。
12. 專案已具備 Lombok 依賴與有效 annotation processor 建置設定時，對 TASK 新增或修改的程式碼，在不改變必要行為、公開 API 或框架契約且符合本規範白名單與限制的前提下，優先規劃使用 Lombok 減少樣板程式碼。規劃前須唯讀確認既有依賴、有效版本、annotation processor 建置設定及實際使用方式；適用的 `lombok.config` 存在時亦須確認，文件規範與既有設定取交集，任一方禁止即不得使用。沒有 `lombok.config` 不影響已核准的 Lombok 使用，亦不得為套用本規範建立；既有設定不得由本規範修改。
13. 原本未使用 Lombok 的專案可以新增，但 TASK 必須明確固定採用原因、精確版本或唯一版本來源、建置工具設定、影響範圍及 `CMD/VAL`；execute 不得自行新增或調整。
14. 正式碼與測試碼共用 Lombok 白名單：`@Getter`、`@Setter`、`@RequiredArgsConstructor`、`@NoArgsConstructor`、`@AllArgsConstructor`、`@Value`、`@Builder`、`@Builder.Default`、`@Singular`、`@With`、`@EqualsAndHashCode`、`@ToString`、`@Slf4j` 及 `@Jacksonized`。未列入的註解預設禁止；例外須在 TASK 固定註解、目標、產生行為、原因及驗證。
15. `@Data`、`@NonNull`、類別層級 `@Setter` 及 `@NoArgsConstructor(force = true)` 預設禁止；例外須由 TASK 個別核准其完整產生行為與物件有效性。
16. `@Getter` 可用於類別或欄位；類別層級使用前須確認每個產生的 getter 均應公開。`@Setter` 只用於確實需要可變性的個別欄位。
17. `@RequiredArgsConstructor` 只用於明確的必要依賴或不可變欄位；`@NoArgsConstructor` 只限框架要求並採最小必要存取權限；`@AllArgsConstructor` 只限所有欄位皆構成建構契約的 DTO 或 value object。
18. `@Value` 只用於確實需要不可變、全欄位相等性、全欄位 `toString` 及 final 類別語意的 value object 或 DTO；Java `record` 適用時優先使用 `record`。`@With` 只用於不可變 value object 或 DTO，且須固定全欄位建構契約、替換後驗證及相等性。
19. `@Builder` 優先標註於已明確定義的建構子或靜態工廠方法；類別層級預設禁止，例外須固定全部輸入、建構子可見性、預設值及驗證行為。`@Builder.Default` 與 `@Singular` 只在所屬 Builder 已核准時使用，並驗證適用的未賦值、單筆、多筆及空集合行為。
20. `@Jacksonized` 只限專案已使用 Jackson、所屬 Builder 已核准且 TASK 已固定序列化與反序列化契約，並依下列版本矩陣規劃：
    1. 有效 Lombok 版本低於 1.18.14 時不得使用。
    2. 有效 Lombok 版本為 1.18.14 至 1.18.42 時只限 Jackson 2。
    3. 有效 Lombok 版本為 1.18.44 以上且只使用 Jackson 2 時，可以不設定 `lombok.jacksonized.jacksonVersion`；TASK 須固定未設定時的預期警告、處理方式及驗證。
    4. 使用 Jackson 3 或同時支援 Jackson 2 與 Jackson 3 時，有效 Lombok 版本須至少為 1.18.46，適用的 Lombok 設定須明確包含 `lombok.jacksonized.jacksonVersion`，且 TASK 須固定精確值、設定範圍及驗證。
    5. 既有設定不符合前述條件，且 TASK 未核准建立或修改設定時，不得使用 `@Jacksonized`，改用明確 Jackson 註解。
21. `@EqualsAndHashCode` 只在 TASK 已固定相等性欄位及繼承行為時使用，並須採明確欄位包含方式及固定 `callSuper`。Entity 預設禁止；例外須固定識別碼、未持久化狀態及代理類別行為。
22. `@ToString` 須採明確欄位白名單；不得包含密碼、權杖、個資等敏感內容。Entity 關聯、延遲載入欄位及可能形成循環的物件預設不得包含。
23. `@Slf4j` 只限已使用 SLF4J 的專案；不得為使用該註解自行新增或更換日誌依賴。其他 Lombok 日誌註解不在白名單內。
24. Entity 只允許經檢查的 `@Getter`、框架要求的最小權限 `@NoArgsConstructor`，以及確實必要的個別欄位 `@Setter`；其他 Lombok 註解須個別核准。
25. Lombok 產生的 public／protected 建構子與方法視為正式 API；公開或跨模組類別使用時，TASK 須固定簽章並評估來源與二進位相容性。
26. 新程式碼及 TASK 觸及的既有 Lombok 使用皆須符合本規範；不主動重構未觸及程式碼。合規調整會擴大檔案或成果範圍時，維持草案或停止並重新確認。
27. VAL 須檢查修改檔案的註解符合白名單及存在的既有 `lombok.config`、確認編譯成功並執行相關既有測試；建構子、Builder、相等性、`toString` 或序列化行為有變更時，另須有直接覆蓋產生行為的測試。
28. 專案已使用 Swagger／OpenAPI 時，新增或修改 Controller API 的 TASK 必須依既有套件、版本及註解風格，固定 Controller 類別與端點、每個參數、各 HTTP 回應，以及 response DTO 與欄位所需的 Swagger／OpenAPI 註解與驗證；不得為符合本規範自行新增或升級 Swagger／OpenAPI 依賴。
