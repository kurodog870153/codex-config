# 後端任務執行規範

1. 嚴格依 TASK 固定的契約、責任、交易及資料行為執行。
2. TASK 明訂的 TDD Red 是驗證步驟；實際結果符合 VAL 預定失敗條件時，視為 Red 驗證通過而非非預期測試失敗，得繼續 Green。無法確認原因，或包含編譯、環境、工具、既有測試等非預期失敗時立即停止。
3. 完整回歸所需的外部條件不足時標記「受阻」，不得自行排除、停用或替換測試。
4. 建立資料表或新增欄位時，必須依 TASK 為每個新增資料表與欄位設定非空 comment，並執行 TASK 固定的驗證；TASK 未固定 comment 內容或驗證方式時，須回報規格不符並停止。
5. 新增或修改後端流程時，必須依 TASK 實作 `Controller → 業務 Service → Persistence Service → 資料庫存取層` 的完整依賴鏈路；各層只能呼叫下一層，不得跨層或反向依賴。未觸及的既有程式不主動重構。
    1. Controller 只處理傳輸協定、輸入驗證、目前使用者資訊、請求／回應轉換及呼叫業務 Service，不得包含業務規則或直接呼叫其他層。可取得目前使用者資訊時，須依專案既有風格由 Controller 取得並傳入業務 Service；預設只傳用例所需的使用者 ID，只有業務確實需要時才能傳既有使用者物件。業務 Service 不得直接存取 Controller、HTTP Session 或安全框架上下文。
    2. 業務 Service 實作所有業務規則、用例流程、跨 Persistence Service 協調及交易邊界，不得直接查詢或持久化資料。
    3. Persistence Service 只封裝資料操作並呼叫資料庫存取層，不得包含業務規則、用例流程或交易邊界。
    4. 資料庫存取層只執行查詢與持久化，不得包含資料操作編排或業務邏輯。
6. 實作前須唯讀確認專案既有命名與套件／目錄結構並優先沿用；沒有明確慣例時，依 TASK 使用下列預設：Controller 使用 `Controller` 後綴；業務 Service 使用 `Service` 後綴，但 `Service` 已代表封裝資料操作的層級時改用 `BusinessService`；Persistence Service 使用 `PersistenceService`；資料庫存取層使用 `Repository`；介面不加 `I` 前綴，實作類別使用 `Impl` 後綴。套件／目錄先依技術分層再依功能分組，使用 `controller/<功能>`、`service/<功能>`、`persistence/<功能>` 及 `repository/<功能>`。
